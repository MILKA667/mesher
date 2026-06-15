import 'contact.dart';

/// Pure transport-layer peer. Carries only network-level signal data.
/// User identity (nickname, avatar, userId) lives in UserProfile.
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
  final int signalLevel; // 0–4
  final int distanceMeters;
  final String? advertisedName; // nickname embedded in BLE scan response
}
