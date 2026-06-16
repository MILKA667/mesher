import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../crypto/key_manager.dart';
import '../data/local/database/app_database.dart';
import '../network/protocol/packet.dart';
import '../network/routing/mesh_router.dart';

class ReactionsService {
  ReactionsService({
    required KeyManager keys,
    required MeshRouter router,
    required AppDatabase db,
  })  : _keys = keys,
        _router = router,
        _db = db;

  final KeyManager _keys;
  final MeshRouter _router;
  final AppDatabase _db;

  StreamSubscription? _sub;

  void bind() {
    _sub ??= _router.incomingPackets.listen(_handlePacket);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  /// Toggle a reaction by the local user on [messageId] in [chatId].
  /// If the same emoji already exists, it's removed; otherwise added.
  Future<void> toggle({
    required String chatId,
    required String messageId,
    required String emoji,
  }) async {
    final userId = _keys.nodeId;
    final existing = (await (_db.select(_db.reactions)
              ..where((t) => t.messageId.equals(messageId) &
                  t.userId.equals(userId) &
                  t.emoji.equals(emoji)))
            .get())
        .isNotEmpty;
    if (existing) {
      await _db.deleteReaction(
          messageId: messageId, userId: userId, emoji: emoji);
      await _broadcast(chatId, messageId, emoji, add: false);
    } else {
      await _db.upsertReaction(ReactionsCompanion.insert(
        messageId: messageId,
        chatId: chatId,
        userId: userId,
        emoji: emoji,
      ));
      await _broadcast(chatId, messageId, emoji, add: true);
    }
  }

  Future<void> _broadcast(
    String chatId,
    String messageId,
    String emoji, {
    required bool add,
  }) async {
    final payload = utf8.encode(jsonEncode({
      'c': chatId,
      'm': messageId,
      'e': emoji,
      'op': add ? 'add' : 'remove',
    }));
    await _router.route(Packet(
      type: PacketType.messageReaction,
      senderId: _keys.nodeId,
      recipientId: chatId, // 1:1 chat: chatId == peer userId
      payload: payload,
    ));
  }

  Future<void> _handlePacket(Packet packet) async {
    if (packet.type != PacketType.messageReaction) return;
    try {
      final map =
          jsonDecode(utf8.decode(packet.payload)) as Map<String, dynamic>;
      final messageId = map['m'] as String;
      final emoji = map['e'] as String;
      final op = (map['op'] as String?) ?? 'add';
      // We always store the reaction under the sender's chat — for a 1:1 chat
      // that's the senderId from the packet (the remote peer == our chatId).
      final chatId = packet.senderId;
      final userId = packet.senderId;
      if (op == 'remove') {
        await _db.deleteReaction(
            messageId: messageId, userId: userId, emoji: emoji);
      } else {
        await _db.upsertReaction(ReactionsCompanion(
          messageId: Value(messageId),
          chatId: Value(chatId),
          userId: Value(userId),
          emoji: Value(emoji),
        ));
      }
    } catch (_) {
      // Malformed payload — ignore.
    }
  }
}
