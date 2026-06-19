import 'dart:math';

enum PacketType {
  message,
  reservedFileChunk,
  reservedFileAnnounce,
  ping,
  pong,
  reservedVideoCallSignal,
  profileAnnounce,
  messageAck,
  messageRead,
  reservedSwarmAnnounce,
  reservedSwarmRequest,
  reservedSwarmChunk,
  reservedSwarmCatalogQuery,
  voiceCallOffer,
  voiceCallAccept,
  voiceCallReject,
  voiceCallFrame,
  voiceCallHangup,
  messageReaction,
}

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
  final int nonce;

  static final _rng = Random();
}
