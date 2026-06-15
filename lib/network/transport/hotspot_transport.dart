import 'dart:async';
import '../../domain/models/contact.dart';
import '../../domain/models/peer.dart';
import '../platform/hotspot_channel.dart';
import 'transport.dart';

class HotspotTransport implements Transport {
  HotspotTransport(this._channel);
  final HotspotChannel _channel;

  final _peerController = StreamController<List<Peer>>.broadcast();

  @override
  ConnectionMode get mode => ConnectionMode.hotspot;

  @override
  Future<void> startScan() => _channel.startHotspot();

  @override
  Future<void> stopScan() => _channel.stopHotspot();

  @override
  Stream<List<Peer>> get discoveredNodes => _peerController.stream;

  @override
  Future<void> connect(String nodeId) async {}

  @override
  Future<void> disconnect(String nodeId) async {}

  @override
  Future<void> send(String nodeId, List<int> data) =>
      _channel.send(nodeId, data);

  @override
  Stream<(String, List<int>)> get received => _channel.rxStream;

  @override
  bool get isScanning => _channel.isActive;

  @override
  bool isConnected(String nodeId) => true; // всегда видно через hotspot AP

  void dispose() => _peerController.close();
}
