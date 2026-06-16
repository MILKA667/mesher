import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../crypto/key_manager.dart';
import '../data/local/file_storage.dart';
import '../data/repositories/file_repository.dart';
import '../domain/models/file_transfer.dart';
import '../network/protocol/packet.dart';
import '../network/routing/mesh_router.dart';
import 'notification_service.dart';

/// Chunk size for swarm transfers. Kept conservative so a single CBOR-encoded
/// packet stays well under BLE-MTU-aware reassembly limits on the Kotlin side.
const int kSwarmChunkSize = 4096;

/// One entry in the swarm catalog (a file someone in the mesh is offering).
class SwarmEntry {
  SwarmEntry({
    required this.infoHash,
    required this.name,
    required this.sizeBytes,
    required this.chunkCount,
    Set<String>? seeders,
    this.downloadProgress = 0,
    this.isLocal = false,
    this.localPath,
  }) : seeders = seeders ?? <String>{};

  final String infoHash;
  final String name;
  final int sizeBytes;
  final int chunkCount;
  final Set<String> seeders;
  int downloadProgress; // 0..100
  bool isLocal;
  String? localPath;

  int get peerCount => seeders.length;
}

class _DownloadJob {
  _DownloadJob({
    required this.entry,
    required this.transferId,
    required this.tempPath,
  });

  final SwarmEntry entry;
  final String transferId;
  final String tempPath;

  /// Chunks already written to disk.
  final received = <int>{};

  /// Indices currently in-flight, with their request timestamp.
  final inflight = <int, DateTime>{};

  RandomAccessFile? raf;
  bool finished = false;
}

class SwarmService {
  SwarmService({
    required KeyManager keys,
    required MeshRouter router,
    required FileStorage fileStorage,
    required FileRepository fileRepo,
    required NotificationService notifications,
  })  : _keys = keys,
        _router = router,
        _fileStorage = fileStorage,
        _fileRepo = fileRepo,
        _notifications = notifications;

  final KeyManager _keys;
  final MeshRouter _router;
  final FileStorage _fileStorage;
  final FileRepository _fileRepo;
  final NotificationService _notifications;

  // infoHash → SwarmEntry (everything known in the swarm: ours + remote)
  final _entries = <String, SwarmEntry>{};

  // infoHash → in-progress download
  final _downloads = <String, _DownloadJob>{};

  final _catalogController = StreamController<List<SwarmEntry>>.broadcast();
  StreamSubscription? _packetSub;
  Timer? _announceTimer;
  Timer? _retryTimer;
  bool _started = false;

  static const _kReqWindow = 8; // parallel chunk requests per file
  static const _kReqTimeout = Duration(seconds: 12);

  final _rng = Random.secure();

  Stream<List<SwarmEntry>> get catalog => _catalogController.stream;
  List<SwarmEntry> get currentCatalog => _entries.values.toList();

  Future<void> start() async {
    if (_started) return;
    _started = true;
    _packetSub = _router.incomingPackets.listen(_handlePacket);

    // Periodically announce our catalog so newly arrived peers learn what we have.
    _announceTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      _broadcastCatalog();
    });

    // Retry stuck chunks.
    _retryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _tickDownloads();
    });

    // Ask any already-connected peers to send us their catalogs.
    Future.delayed(const Duration(milliseconds: 800), () {
      _broadcastCatalogQuery();
      _broadcastCatalog();
    });
  }

  /// Add a local file to the swarm. Computes hash, registers it, and announces
  /// it to peers.
  Future<SwarmEntry?> shareFile(String localPath) async {
    final file = File(localPath);
    if (!await file.exists()) return null;

    final bytes = await file.readAsBytes();
    final infoHash = sha256.convert(bytes).toString();
    final name = p.basename(localPath);
    final chunkCount = (bytes.length + kSwarmChunkSize - 1) ~/ kSwarmChunkSize;

    // Persist a copy in the uploads dir so the original location can change.
    final destPath = await _fileStorage.pathFor(name, isUpload: true);
    final dest = File(destPath);
    if (!await dest.exists() ||
        (await dest.length()) != bytes.length) {
      await dest.writeAsBytes(bytes);
    }

    final existing = _entries[infoHash];
    final entry = SwarmEntry(
      infoHash: infoHash,
      name: name,
      sizeBytes: bytes.length,
      chunkCount: chunkCount,
      seeders: {...(existing?.seeders ?? const {}), _keys.nodeId},
      isLocal: true,
      localPath: destPath,
      downloadProgress: 100,
    );
    _entries[infoHash] = entry;

    // Mirror to file_transfers table so it shows in FilesScreen.
    await _fileRepo.createTransfer(
      name: name,
      sizeBytes: bytes.length,
      direction: TransferDirection.upload,
      infoHash: infoHash,
    );

    _emit();
    _broadcastCatalog();

    await _notifications.showFileEvent(
      title: 'Файл доступен в mesh-сети',
      body: '$name (${_humanSize(bytes.length)}) — ты раздаёшь',
    );
    return entry;
  }

  /// Begin downloading a file from the swarm by its info hash.
  Future<void> downloadFile(String infoHash) async {
    final entry = _entries[infoHash];
    if (entry == null) return;
    if (entry.isLocal) return; // already have it
    if (_downloads.containsKey(infoHash)) return; // already downloading

    final downloadsDir = await _fileStorage.downloadsDir;
    final tempPath = p.join(downloadsDir, '$infoHash.part');
    final finalPath = p.join(downloadsDir, entry.name);

    final tempFile = File(tempPath);
    if (!await tempFile.exists()) {
      await tempFile.create(recursive: true);
    }
    // Open in FileMode.write (O_RDWR | O_CREAT | O_TRUNC). This is the only
    // Dart mode that lets us seek and write at arbitrary offsets. Keep the
    // handle open for the whole download — chunk arrivals are random-access.
    final raf = await tempFile.open(mode: FileMode.write);
    // Pre-size the file so writes at the last chunk offset don't underflow.
    if (entry.sizeBytes > 0) {
      await raf.setPosition(entry.sizeBytes - 1);
      await raf.writeByte(0);
    }

    final transfer = await _fileRepo.createTransfer(
      name: entry.name,
      sizeBytes: entry.sizeBytes,
      direction: TransferDirection.download,
      infoHash: infoHash,
    );
    await _fileRepo.updateState(transfer.id, TransferState.active);

    final job = _DownloadJob(
      entry: entry,
      transferId: transfer.id,
      tempPath: tempPath,
    );
    job.raf = raf;
    _downloads[infoHash] = job;

    // Fan out initial chunk requests.
    _scheduleRequests(job);

    // Move file to final name when download completes. We'll do this in
    // _handleChunk when finished. Stash final path on the job by name.
    job.entry.localPath = finalPath;
  }

  Future<void> _handlePacket(Packet packet) async {
    switch (packet.type) {
      case PacketType.swarmAnnounce:
        _handleAnnounce(packet);
      case PacketType.swarmCatalogQuery:
        _broadcastCatalog();
      case PacketType.swarmRequest:
        await _handleRequest(packet);
      case PacketType.swarmChunk:
        await _handleChunk(packet);
      default:
        break;
    }
  }

  void _handleAnnounce(Packet packet) {
    try {
      final map = jsonDecode(utf8.decode(packet.payload)) as Map<String, dynamic>;
      final entries = (map['entries'] as List).cast<Map<String, dynamic>>();
      var changed = false;
      for (final e in entries) {
        final infoHash = e['h'] as String;
        final name = e['n'] as String;
        final size = e['s'] as int;
        final chunkCount = e['c'] as int;
        final existing = _entries[infoHash];
        if (existing != null) {
          if (!existing.seeders.contains(packet.senderId)) {
            existing.seeders.add(packet.senderId);
            changed = true;
          }
        } else {
          _entries[infoHash] = SwarmEntry(
            infoHash: infoHash,
            name: name,
            sizeBytes: size,
            chunkCount: chunkCount,
            seeders: {packet.senderId},
          );
          changed = true;
        }
      }
      if (changed) _emit();
    } catch (_) {
      // Malformed announce — ignore.
    }
  }

  Future<void> _handleRequest(Packet packet) async {
    try {
      final map = jsonDecode(utf8.decode(packet.payload)) as Map<String, dynamic>;
      final infoHash = map['h'] as String;
      final chunkIndex = map['i'] as int;
      final entry = _entries[infoHash];
      if (entry == null || !entry.isLocal || entry.localPath == null) {
        return;
      }
      final file = File(entry.localPath!);
      if (!await file.exists()) return;
      final raf = await file.open();
      final start = chunkIndex * kSwarmChunkSize;
      if (start >= entry.sizeBytes) {
        await raf.close();
        return;
      }
      final end = min(start + kSwarmChunkSize, entry.sizeBytes);
      await raf.setPosition(start);
      final data = await raf.read(end - start);
      await raf.close();

      final replyPayload = utf8.encode(jsonEncode({
        'h': infoHash,
        'i': chunkIndex,
        'd': base64Encode(data),
      }));
      await _router.route(Packet(
        type: PacketType.swarmChunk,
        senderId: _keys.nodeId,
        recipientId: packet.senderId,
        payload: replyPayload,
      ));
    } catch (_) {}
  }

  Future<void> _handleChunk(Packet packet) async {
    try {
      final map = jsonDecode(utf8.decode(packet.payload)) as Map<String, dynamic>;
      final infoHash = map['h'] as String;
      final chunkIndex = map['i'] as int;
      final data = base64Decode(map['d'] as String);

      final job = _downloads[infoHash];
      if (job == null || job.finished) return;
      if (job.received.contains(chunkIndex)) return;

      final raf = job.raf;
      if (raf == null) return;
      await raf.setPosition(chunkIndex * kSwarmChunkSize);
      await raf.writeFrom(data);
      await raf.flush();
      job.received.add(chunkIndex);
      job.inflight.remove(chunkIndex);

      final pct =
          (job.received.length / job.entry.chunkCount * 100).round();
      job.entry.downloadProgress = pct;
      await _fileRepo.updateProgress(
          job.transferId, pct, data.length * 2);
      _emit();

      if (job.received.length >= job.entry.chunkCount) {
        await _finishDownload(job);
      } else {
        _scheduleRequests(job);
      }
    } catch (_) {}
  }

  Future<void> _finishDownload(_DownloadJob job) async {
    if (job.finished) return;
    job.finished = true;
    // Release the open RAF before renaming the file (Windows requires it; on
    // POSIX it's also cleaner).
    try {
      await job.raf?.close();
    } catch (_) {}
    job.raf = null;
    final finalPath =
        p.join(p.dirname(job.tempPath), job.entry.name);
    final tempFile = File(job.tempPath);
    final finalFile = File(finalPath);
    if (await finalFile.exists()) {
      await finalFile.delete();
    }
    await tempFile.rename(finalPath);
    job.entry.localPath = finalPath;
    job.entry.isLocal = true;
    job.entry.seeders.add(_keys.nodeId);
    job.entry.downloadProgress = 100;
    await _fileRepo.updateState(job.transferId, TransferState.done);
    _downloads.remove(job.entry.infoHash);
    _emit();
    _broadcastCatalog();

    await _notifications.showFileEvent(
      title: 'Файл загружен',
      body: '${job.entry.name} — получен из mesh-сети',
    );
  }

  void _scheduleRequests(_DownloadJob job) {
    if (job.entry.seeders.isEmpty) return;
    // Drop the local node from the seeder list when choosing remote sources.
    final remoteSeeders = job.entry.seeders
        .where((id) => id != _keys.nodeId)
        .toList();
    if (remoteSeeders.isEmpty) return;

    while (job.inflight.length < _kReqWindow) {
      final next = _nextMissingChunk(job);
      if (next == null) break;
      final seeder = remoteSeeders[_rng.nextInt(remoteSeeders.length)];
      job.inflight[next] = DateTime.now();
      _sendChunkRequest(seeder, job.entry.infoHash, next);
    }
  }

  void _tickDownloads() {
    final now = DateTime.now();
    for (final job in _downloads.values) {
      final expired = job.inflight.entries
          .where((e) => now.difference(e.value) > _kReqTimeout)
          .map((e) => e.key)
          .toList();
      for (final idx in expired) {
        job.inflight.remove(idx);
      }
      _scheduleRequests(job);
    }
  }

  int? _nextMissingChunk(_DownloadJob job) {
    for (var i = 0; i < job.entry.chunkCount; i++) {
      if (job.received.contains(i)) continue;
      if (job.inflight.containsKey(i)) continue;
      return i;
    }
    return null;
  }

  void _sendChunkRequest(String seederId, String infoHash, int chunkIndex) {
    final payload = utf8.encode(jsonEncode({
      'h': infoHash,
      'i': chunkIndex,
    }));
    _router.route(Packet(
      type: PacketType.swarmRequest,
      senderId: _keys.nodeId,
      recipientId: seederId,
      payload: payload,
    ));
  }

  void _broadcastCatalog() {
    final local = _entries.values.where((e) => e.isLocal).toList();
    if (local.isEmpty) return;
    final payload = utf8.encode(jsonEncode({
      'entries': local
          .map((e) => {
                'h': e.infoHash,
                'n': e.name,
                's': e.sizeBytes,
                'c': e.chunkCount,
              })
          .toList(),
    }));
    _router.route(Packet(
      type: PacketType.swarmAnnounce,
      senderId: _keys.nodeId,
      payload: payload,
    ));
  }

  void _broadcastCatalogQuery() {
    _router.route(Packet(
      type: PacketType.swarmCatalogQuery,
      senderId: _keys.nodeId,
      payload: const [],
    ));
  }

  void _emit() => _catalogController.add(currentCatalog);

  static String _humanSize(int bytes) {
    if (bytes < 1024) return '$bytes Б';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} КБ';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} ГБ';
  }

  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    _announceTimer?.cancel();
    _retryTimer?.cancel();
    await _packetSub?.cancel();
  }

  Future<void> dispose() async {
    await stop();
    await _catalogController.close();
    for (final job in _downloads.values) {
      try {
        await job.raf?.close();
      } catch (_) {}
    }
  }
}
