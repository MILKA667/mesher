import '../models/peer.dart';

abstract interface class ScanNearby {
  Stream<List<Peer>> call();
  Future<void> stop();
}
