import 'dart:async';
import '../../domain/models/contact.dart';
import '../../domain/models/peer.dart';
import '../platform/wifi_direct_channel.dart';
import 'transport.dart';

class WifiDirectTransport implements Transport {
  WifiDirectTransport(this._channel);
  final WifiDirectChannel _channel;

  final _connectedNodes = <String>{};
  final _peerCache = <String, Peer>{};
  final _peerController = StreamController<List<Peer>>.broadcast();
  StreamSubscription? _peerSub;

  void _init() {
    _peerSub ??= _channel.peerStream.listen((map) {
      final nodeId = map['nodeId'] as String;
      _connectedNodes.add(nodeId);
      _peerCache[nodeId] = Peer(
        nodeId: nodeId,
        mode: ConnectionMode.wifi,
        signalLevel: 3,
        distanceMeters: 0,
      );
      _peerController.add(_peerCache.values.toList());
    });
  }

  @override
  ConnectionMode get mode => ConnectionMode.wifi;

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
    return _channel.disconnect(nodeId);
  }

  @override
  Future<void> send(String nodeId, List<int> data) =>
      _channel.send(nodeId, data);

  @override
  Stream<(String, List<int>)> get received => _channel.rxStream;

  @override
  bool get isScanning => _channel.isScanning;

  @override
  bool isConnected(String nodeId) => _connectedNodes.contains(nodeId);

  @override
  List<String> get knownPeers => _peerCache.keys.toList();

  void dispose() {
    _peerSub?.cancel();
    _peerController.close();
  }
}
