enum ConnectionMode { bluetooth }

class Contact {
  const Contact({
    required this.id,
    required this.name,
    required this.nodeId,
    this.mode = ConnectionMode.bluetooth,
    this.signalLevel = 0,
    this.isOnline = false,
    this.distanceMeters,
  });

  final String id;
  final String name;
  final String nodeId;
  final ConnectionMode mode;
  final int signalLevel; // 0–4
  final bool isOnline;
  final int? distanceMeters;

  Contact copyWith({
    String? name,
    ConnectionMode? mode,
    int? signalLevel,
    bool? isOnline,
    int? distanceMeters,
  }) =>
      Contact(
        id: id,
        name: name ?? this.name,
        nodeId: nodeId,
        mode: mode ?? this.mode,
        signalLevel: signalLevel ?? this.signalLevel,
        isOnline: isOnline ?? this.isOnline,
        distanceMeters: distanceMeters ?? this.distanceMeters,
      );
}
