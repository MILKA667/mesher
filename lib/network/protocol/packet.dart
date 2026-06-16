import 'dart:math';

enum PacketType {
  message,
  fileChunk,
  fileAnnounce,
  ping,
  pong,
  // Index 5 — reserved (was video-call signaling; removed: WebRTC needs IP).
  reservedVideoCallSignal,
  profileAnnounce,
  messageAck,
  messageRead,
  // Swarm (torrent-like) file sharing:
  swarmAnnounce, // 9 — peer publishes which files it has
  swarmRequest,  // 10 — peer asks for one chunk by infoHash + index
  swarmChunk,    // 11 — peer delivers one chunk
  swarmCatalogQuery, // 12 — ask all peers to announce their catalog
  // Voice calls — raw PCM frames over BLE mesh.
  voiceCallOffer,   // 13
  voiceCallAccept,  // 14
  voiceCallReject,  // 15
  voiceCallFrame,   // 16
  voiceCallHangup,  // 17
  messageReaction,  // 18 — emoji add/remove on a message
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
  final int nonce; // unique per packet — prevents flood-router dedup false positives

  static final _rng = Random();
}
