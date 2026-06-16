import '../../domain/models/contact.dart';
import '../../domain/models/peer.dart';

/// Common interface for all P2P transports (BT, WiFi Direct, Hotspot).
abstract class Transport {
  ConnectionMode get mode;

  Future<void> startScan();
  Future<void> stopScan();

  Stream<List<Peer>> get discoveredNodes;

  Future<void> connect(String nodeId);
  Future<void> disconnect(String nodeId);

  Future<void> send(String nodeId, List<int> data);
  Stream<(String nodeId, List<int> data)> get received;

  bool get isScanning;
  bool isConnected(String nodeId);

  /// All node IDs currently in the local scan cache (regardless of GATT state).
  List<String> get knownPeers;

  /// Called by the router when a packet is received from [senderAddr] on this
  /// transport and decoded to [nodeId]. Transports can use this to register a
  /// reverse route so they can later send back to this node without needing a
  /// prior scan/discovery event. Default is a no-op.
  void registerSender(String nodeId, String senderAddr) {}
}
