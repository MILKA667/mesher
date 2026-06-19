import 'contact.dart';

class Peer {
  const Peer({
    required this.nodeId,
    required this.mode,
    required this.signalLevel,
    required this.distanceMeters,
    this.advertisedName,
  });

  final String nodeId;
  final ConnectionMode mode;
  final int signalLevel;
  final int distanceMeters;
  final String? advertisedName;
}
