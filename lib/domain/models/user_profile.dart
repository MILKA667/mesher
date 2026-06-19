import 'dart:typed_data';
import 'contact.dart';

class UserProfile {
  const UserProfile({
    required this.userId,
    required this.nickname,
    this.avatar,
    required this.lastSeen,
    this.signalLevel = 0,
    this.distanceMeters = 0,
    this.seenVia = const {},
    this.isKnownContact = false,
  });

  final String userId;
  final String nickname;
  final Uint8List? avatar;
  final int lastSeen;
  final int signalLevel;
  final int distanceMeters;
  final Set<ConnectionMode> seenVia;
  final bool isKnownContact;

  ConnectionMode get bestTransport => ConnectionMode.bluetooth;

  UserProfile copyWith({
    String? nickname,
    Uint8List? avatar,
    int? lastSeen,
    int? signalLevel,
    int? distanceMeters,
    Set<ConnectionMode>? seenVia,
    bool? isKnownContact,
  }) =>
      UserProfile(
        userId: userId,
        nickname: nickname ?? this.nickname,
        avatar: avatar ?? this.avatar,
        lastSeen: lastSeen ?? this.lastSeen,
        signalLevel: signalLevel ?? this.signalLevel,
        distanceMeters: distanceMeters ?? this.distanceMeters,
        seenVia: seenVia ?? this.seenVia,
        isKnownContact: isKnownContact ?? this.isKnownContact,
      );
}
