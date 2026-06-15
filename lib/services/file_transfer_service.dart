import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import '../data/local/file_storage.dart';
import '../data/repositories/file_repository.dart';
import '../domain/models/file_transfer.dart';
import '../network/protocol/packet.dart';
import '../network/routing/mesh_router.dart';
import '../crypto/key_manager.dart';

const _kChunkSize = 8192; // 8 KB per chunk

class FileTransferService {
  FileTransferService({
    required KeyManager keys,
    required MeshRouter router,
    required FileRepository fileRepo,
    required FileStorage fileStorage,
  })  : _keys = keys,
        _router = router,
        _fileRepo = fileRepo,
        _fileStorage = fileStorage;

  final KeyManager _keys;
  final MeshRouter _router;
  final FileRepository _fileRepo;
  final FileStorage _fileStorage;

  final _incomingSub = <StreamSubscription>[];
  final _buffers = <String, _AssemblyBuffer>{};

  void startListening(Stream<Packet> incomingPackets) {
    _incomingSub.add(incomingPackets.listen(_handlePacket));
  }

  Future<void> sendFile(String recipientId, String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return;

    final fileName = p.basename(filePath);
    final bytes = await file.readAsBytes();
    final totalBytes = bytes.length;
    final totalChunks = (totalBytes + _kChunkSize - 1) ~/ _kChunkSize;

    final transfer = await _fileRepo.createTransfer(
      name: fileName,
      sizeBytes: totalBytes,
      direction: TransferDirection.upload,
    );
    await _fileRepo.updateState(transfer.id, TransferState.active);

    final idBytes = _uuidToBytes(transfer.id);

    await _sendPacket(recipientId, PacketType.fileAnnounce,
        _encodeAnnounce(idBytes, totalChunks, totalBytes, fileName));

    for (var i = 0; i < totalChunks; i++) {
      final start = i * _kChunkSize;
      final end = (start + _kChunkSize).clamp(0, totalBytes);
      final chunk = bytes.sublist(start, end);
      await _sendPacket(recipientId, PacketType.fileChunk, _encodeChunk(idBytes, i, chunk));
      final pct = ((i + 1) / totalChunks * 100).round();
      await _fileRepo.updateProgress(transfer.id, pct, chunk.length);
    }

    await _fileRepo.updateState(transfer.id, TransferState.seeding);
  }

  Future<void> _handlePacket(Packet packet) async {
    if (packet.type == PacketType.fileAnnounce) {
      await _handleAnnounce(packet.senderId, packet.payload);
    } else if (packet.type == PacketType.fileChunk) {
      await _handleChunk(packet.payload);
    }
  }

  Future<void> _handleAnnounce(String senderId, List<int> data) async {
    if (data.length < 30) return;
    final idBytes = data.sublist(0, 16);
    final transferId = _bytesToUuid(idBytes);
    final totalChunks = _readInt32(data, 16);
    final totalBytes = _readInt64(data, 20);
    final nameLen = _readInt16(data, 28);
    if (data.length < 30 + nameLen) return;
    final fileName = utf8.decode(data.sublist(30, 30 + nameLen));

    _buffers[transferId] = _AssemblyBuffer(
      transferId: transferId,
      totalChunks: totalChunks,
      totalBytes: totalBytes,
      fileName: fileName,
    );

    final transfer = await _fileRepo.createTransfer(
      name: fileName,
      sizeBytes: totalBytes,
      direction: TransferDirection.download,
    );
    _buffers[transferId]!.dbId = transfer.id;
    await _fileRepo.updateState(transfer.id, TransferState.active);
  }

  Future<void> _handleChunk(List<int> data) async {
    if (data.length < 20) return;
    final idBytes = data.sublist(0, 16);
    final transferId = _bytesToUuid(idBytes);
    final chunkIndex = _readInt32(data, 16);
    final chunk = data.sublist(20);

    final buf = _buffers[transferId];
    if (buf == null) return;

    buf.addChunk(chunkIndex, chunk);
    final pct = (buf.received / buf.totalChunks * 100).round();
    await _fileRepo.updateProgress(buf.dbId!, pct, chunk.length);

    if (buf.isComplete) {
      _buffers.remove(transferId);
      await _assembleFile(buf);
    }
  }

  Future<void> _assembleFile(_AssemblyBuffer buf) async {
    final destPath = await _fileStorage.pathFor(buf.fileName);
    final file = File(destPath);
    final sink = file.openWrite();
    for (var i = 0; i < buf.totalChunks; i++) {
      final chunk = buf.chunks[i];
      if (chunk != null) sink.add(chunk);
    }
    await sink.flush();
    await sink.close();
    if (buf.dbId != null) {
      await _fileRepo.updateState(buf.dbId!, TransferState.done);
    }
  }

  Future<void> _sendPacket(String recipientId, PacketType type, List<int> payload) async {
    await _router.route(Packet(
      type: type,
      senderId: _keys.nodeId,
      recipientId: recipientId,
      payload: payload,
    ));
  }

  static List<int> _encodeAnnounce(
      List<int> idBytes, int totalChunks, int totalBytes, String fileName) {
    final nameBytes = utf8.encode(fileName);
    final buf = BytesBuilder();
    buf.add(idBytes.take(16).toList());
    buf.add(_int32Bytes(totalChunks));
    buf.add(_int64Bytes(totalBytes));
    buf.add(_int16Bytes(nameBytes.length));
    buf.add(nameBytes);
    return buf.toBytes();
  }

  static List<int> _encodeChunk(List<int> idBytes, int chunkIndex, List<int> data) {
    final buf = BytesBuilder();
    buf.add(idBytes.take(16).toList());
    buf.add(_int32Bytes(chunkIndex));
    buf.add(data);
    return buf.toBytes();
  }

  static List<int> _int32Bytes(int v) =>
      [(v >> 24) & 0xFF, (v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF];

  static List<int> _int64Bytes(int v) => [
        (v >> 56) & 0xFF, (v >> 48) & 0xFF, (v >> 40) & 0xFF, (v >> 32) & 0xFF,
        (v >> 24) & 0xFF, (v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF,
      ];

  static List<int> _int16Bytes(int v) => [(v >> 8) & 0xFF, v & 0xFF];

  static int _readInt32(List<int> b, int off) =>
      ((b[off] & 0xFF) << 24) | ((b[off + 1] & 0xFF) << 16) |
      ((b[off + 2] & 0xFF) << 8) | (b[off + 3] & 0xFF);

  static int _readInt64(List<int> b, int off) {
    int v = 0;
    for (var i = 0; i < 8; i++) {
      v = (v << 8) | (b[off + i] & 0xFF);
    }
    return v;
  }

  static int _readInt16(List<int> b, int off) =>
      ((b[off] & 0xFF) << 8) | (b[off + 1] & 0xFF);

  static List<int> _uuidToBytes(String uuid) {
    final hex = uuid.replaceAll('-', '');
    return List.generate(
        16, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16));
  }

  static String _bytesToUuid(List<int> b) {
    final h = b.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-'
        '${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  void dispose() {
    for (final s in _incomingSub) {
      s.cancel();
    }
  }
}

class _AssemblyBuffer {
  _AssemblyBuffer({
    required this.transferId,
    required this.totalChunks,
    required this.totalBytes,
    required this.fileName,
  });

  final String transferId;
  final int totalChunks;
  final int totalBytes;
  final String fileName;
  String? dbId;

  final Map<int, List<int>> chunks = {};
  int received = 0;

  void addChunk(int index, List<int> data) {
    if (!chunks.containsKey(index)) {
      chunks[index] = data;
      received++;
    }
  }

  bool get isComplete => received >= totalChunks;
}
