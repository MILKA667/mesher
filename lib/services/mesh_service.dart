import 'dart:async';
import '../crypto/key_manager.dart';
import '../network/transport/transport.dart';
import '../network/routing/mesh_router.dart';
import '../network/protocol/packet.dart';

abstract interface class MeshService {
  Future<void> start();
  Future<void> stop();
  bool get isRunning;
  String get nodeId;
  Future<void> send(String peerId, List<int> bytes);
  Stream<(String peerId, List<int> bytes)> get messages;
}

class MeshServiceImpl implements MeshService {
  MeshServiceImpl({
    required KeyManager keys,
    required MeshRouter router,
    required List<Transport> transports,
  })  : _keys = keys,
        _router = router,
        _transports = transports;

  final KeyManager _keys;
  final MeshRouter _router;
  final List<Transport> _transports;

  bool _running = false;
  StreamSubscription? _incomingSub;
  final _msgController = StreamController<(String, List<int>)>.broadcast();

  @override
  bool get isRunning => _running;

  @override
  String get nodeId => _keys.nodeId;

  @override
  Stream<(String, List<int>)> get messages => _msgController.stream;

  @override
  Future<void> start() async {
    if (_running) return;
    _running = true;
    for (final t in _transports) {
      _router.addTransport(t);
      await t.startScan();
    }
    _incomingSub = _router.incomingPackets.listen(_handlePacket);
  }

  @override
  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    await _incomingSub?.cancel();
    for (final t in _transports) {
      await t.stopScan();
    }
  }

  @override
  Future<void> send(String peerId, List<int> bytes) async {
    await _router.route(Packet(
      type: PacketType.message,
      senderId: _keys.nodeId,
      recipientId: peerId,
      payload: bytes,
    ));
  }

  void _handlePacket(Packet packet) {
    if (packet.type == PacketType.message) {
      _msgController.add((packet.senderId, packet.payload));
    }
  }

  void dispose() {
    _incomingSub?.cancel();
    _msgController.close();
  }
}
