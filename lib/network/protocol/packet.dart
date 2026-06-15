import 'dart:math';

enum PacketType { message, fileChunk, fileAnnounce, ping, pong, callSignal, profileAnnounce }

class Packet {
  Packet({
    required this.type,
    required this.senderId,
    required this.payload,
    this.recipientId,
    int? nonce,
  }) : nonce = nonce ?? _rng.nextInt(0x7FFFFFFF);

  final PacketType type;
  final String senderId;
  final String? recipientId;
  final List<int> payload;
  final int nonce; // unique per packet — prevents flood-router dedup false positives

  static final _rng = Random();
}
