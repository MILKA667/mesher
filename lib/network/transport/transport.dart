import '../../domain/models/contact.dart';
import '../../domain/models/peer.dart';

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

  List<String> get knownPeers;

  void registerSender(String nodeId, String senderAddr) {}
}
