import 'dart:async';
import '../../domain/models/contact.dart';
import '../../domain/models/peer.dart';
import '../platform/bluetooth_channel.dart';
import 'transport.dart';

class BluetoothTransport implements Transport {
  BluetoothTransport(this._channel);
  final BluetoothChannel _channel;

  final _connectedNodes = <String>{};
  final _gattConnected = <String>{};
  final _peerCache = <String, Peer>{};
  final _peerController = StreamController<List<Peer>>.broadcast();

  late final StreamSubscription _peerSub;
  bool _started = false;

  void _init() {
    if (_started) return;
    _started = true;
    _peerSub = _channel.peerStream.listen((map) {
      final peer = peerFromAdvert(map);
      _connectedNodes.add(peer.nodeId);
      _peerCache[peer.nodeId] = peer;
      _peerController.add(_peerCache.values.toList());
    });
  }

  @override
  ConnectionMode get mode => ConnectionMode.bluetooth;

  @override
  Future<void> startScan() {
    _init();
    return _channel.startScan();
  }

  @override
  Future<void> stopScan() => _channel.stopScan();

  @override
  Stream<List<Peer>> get discoveredNodes => _peerController.stream;

  @override
  Future<void> connect(String nodeId) => _channel.connect(nodeId);

  @override
  Future<void> disconnect(String nodeId) {
    _connectedNodes.remove(nodeId);
    _gattConnected.remove(nodeId);
    return _channel.disconnect(nodeId);
  }

  Future<void> _ensureGatt(String nodeId) async {
    if (_gattConnected.contains(nodeId)) return;
    await _channel.connect(nodeId);
    _gattConnected.add(nodeId);
  }

  @override
  Future<void> send(String nodeId, List<int> data) async {
    try {
      await _ensureGatt(nodeId);
      await _channel.send(nodeId, data);
    } catch (e) {
      // Force re-connect on the next send attempt.
      _gattConnected.remove(nodeId);
      rethrow;
    }
  }

  @override
  Stream<(String, List<int>)> get received => _channel.rxStream;

  @override
  bool get isScanning => _channel.isScanning;

  @override
  bool isConnected(String nodeId) => _connectedNodes.contains(nodeId);

  @override
  List<String> get knownPeers => _peerCache.keys.toList();

  /// Called by the router when a packet arrives from [mac] (BLE MAC address)
  /// and decodes to [nodeId]. Registers the reverse route so we can GATT-connect
  /// back without waiting for a scan advertisement.
  @override
  void registerSender(String nodeId, String mac) {
    if (_peerCache.containsKey(nodeId)) return;
    _connectedNodes.add(nodeId);
    _peerCache[nodeId] = Peer(
      nodeId: nodeId,
      mode: ConnectionMode.bluetooth,
      signalLevel: 1,
      distanceMeters: 0,
    );
    _peerController.add(_peerCache.values.toList());
    _channel.registerPeer(nodeId, mac); // fire-and-forget
  }

  /// Convert raw BLE advertisement map to a Peer domain object.
  /// Caller provides rssi→distance formula.
  static Peer peerFromAdvert(Map<String, dynamic> map) {
    final rssi = map['rssi'] as int? ?? -90;
    final dist = (10.0 * (((-59.0) - rssi) / 20.0)).round().clamp(0, 999);
    final signalLevel = rssi > -60
        ? 4
        : rssi > -70
            ? 3
            : rssi > -80
                ? 2
                : 1;
    final nick = map['nickname'] as String?;
    return Peer(
      nodeId: map['nodeId'] as String,
      mode: ConnectionMode.bluetooth,
      signalLevel: signalLevel,
      distanceMeters: dist,
      advertisedName: (nick != null && nick.isNotEmpty) ? nick : null,
    );
  }

  void dispose() {
    _peerSub.cancel();
    _peerController.close();
  }
}
