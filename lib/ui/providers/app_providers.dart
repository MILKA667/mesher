import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../crypto/key_manager.dart';
import '../../data/local/database/app_database.dart';
import '../../data/local/secure_storage.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/peer_repository.dart';
import '../../domain/models/chat.dart';
import '../../domain/models/message.dart';
import '../../domain/models/reaction.dart';
import '../../domain/models/user_profile.dart';
import '../../network/discovery/discovery_service.dart';
import '../../network/platform/bluetooth_channel.dart';
import '../../network/protocol/packet.dart';
import '../../network/protocol/packet_codec.dart';
import '../../network/routing/mesh_router.dart';
import '../../network/transport/bluetooth_transport.dart';
import '../../services/mesh_service.dart';
import '../../services/notification_service.dart';
import '../../services/reactions_service.dart';
import '../../services/voice_call_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final secureStorageProvider = Provider<SecureStorage>((_) => SecureStorageImpl());

final keyManagerProvider = Provider<KeyManager>((ref) {
  return KeyManagerImpl(ref.watch(secureStorageProvider));
});

final btChannelProvider = Provider((_) => BluetoothChannel());

final btTransportProvider = Provider((ref) {
  final t = BluetoothTransport(ref.watch(btChannelProvider));
  ref.onDispose(t.dispose);
  return t;
});

final packetCodecProvider = Provider<PacketCodec>((_) => CborPacketCodec());

final meshRouterProvider = Provider<MeshRouter>((ref) {
  final router = FloodRouter(ref.watch(packetCodecProvider));
  ref.onDispose(router.dispose);
  return router;
});

final chatRepoProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(appDatabaseProvider));
});

final peerRepoProvider = Provider<PeerRepository>((ref) {
  return PeerRepositoryImpl(ref.watch(appDatabaseProvider));
});

final meshServiceProvider = Provider<MeshService>((ref) {
  final service = MeshServiceImpl(
    keys: ref.watch(keyManagerProvider),
    router: ref.watch(meshRouterProvider),
    transports: [
      ref.watch(btTransportProvider),
    ],
  );
  ref.onDispose(service.dispose);
  return service;
});

final discoveryServiceProvider = Provider<DiscoveryService>((ref) {
  final svc = DiscoveryServiceImpl(
    keys: ref.watch(keyManagerProvider),
    storage: ref.watch(secureStorageProvider),
    router: ref.watch(meshRouterProvider),
    transports: [
      ref.watch(btTransportProvider),
    ],
  );
  ref.onDispose(svc.dispose);
  return svc;
});

final reactionsServiceProvider = Provider<ReactionsService>((ref) {
  final svc = ReactionsService(
    keys: ref.watch(keyManagerProvider),
    router: ref.watch(meshRouterProvider),
    db: ref.watch(appDatabaseProvider),
  );
  svc.bind();
  ref.onDispose(svc.dispose);
  return svc;
});

final chatReactionsProvider =
    StreamProvider.family<List<Reaction>, String>((ref, chatId) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchReactionsForChat(chatId).map(
      (rows) => rows.map(AppDatabase.reactionFromRow).toList());
});

final voiceCallServiceProvider = Provider<VoiceCallService>((ref) {
  final svc = VoiceCallService(
    keys: ref.watch(keyManagerProvider),
    router: ref.watch(meshRouterProvider),
  );
  svc.bind();
  ref.onDispose(svc.dispose);
  return svc;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

final chatsStreamProvider = StreamProvider<List<Chat>>((ref) {
  return ref.watch(chatRepoProvider).watchChats();
});

final nearbyUsersProvider = StreamProvider<List<UserProfile>>((ref) {
  return ref.watch(discoveryServiceProvider).nearbyUsers;
});

final messagesStreamProvider =
    StreamProvider.family<List<dynamic>, String>((ref, chatId) {
  return ref.watch(chatRepoProvider).watchMessages(chatId);
});

final keyManagerInitProvider = FutureProvider<String>((ref) async {
  final km = ref.watch(keyManagerProvider);
  await km.init();
  return km.nodeId;
});

final ownProfileProvider = FutureProvider<UserProfile>((ref) async {
  final nodeId = await ref.watch(keyManagerInitProvider.future);
  final storage = ref.watch(secureStorageProvider);
  final nickname = await storage.read('profile_nickname') ??
      'Node-${nodeId.substring(0, 4)}';
  final avatarB64 = await storage.read('profile_avatar');
  Uint8List? avatar;
  if (avatarB64 != null && avatarB64.isNotEmpty) {
    try {
      final decoded = base64Decode(avatarB64);
      if (decoded.isNotEmpty) avatar = decoded;
    } catch (_) {}
  }
  return UserProfile(
    userId: nodeId,
    nickname: nickname,
    avatar: avatar,
    lastSeen: DateTime.now().millisecondsSinceEpoch,
    seenVia: const {},
  );
});

final currentTabProvider = StateProvider<int>((_) => 0);

final incomingMessageHandlerProvider = Provider<void>((ref) {
  final router = ref.watch(meshRouterProvider);
  final db = ref.watch(appDatabaseProvider);
  final chatRepo = ref.watch(chatRepoProvider);
  final discovery = ref.watch(discoveryServiceProvider);
  final notifications = ref.watch(notificationServiceProvider);
  final keys = ref.watch(keyManagerProvider);

  Future<String> resolveName(String userId) async {
    final fallback =
        userId.length >= 8 ? userId.substring(0, 8) : userId;
    try {
      final users = await discovery.nearbyUsers.first.timeout(
        const Duration(milliseconds: 100),
        onTimeout: () => <UserProfile>[],
      );
      final match = users.where((u) => u.userId == userId).firstOrNull;
      return match?.nickname ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  final sub = router.incomingPackets.listen((packet) async {
    switch (packet.type) {
      case PacketType.message:
        final raw = utf8.decode(packet.payload, allowMalformed: true);
        final sep = raw.indexOf('|');
        final msgId = sep > 0 ? raw.substring(0, sep) : null;
        final text = sep > 0 ? raw.substring(sep + 1) : raw;

        final displayName = await resolveName(packet.senderId);

        await db.getOrCreateChat(
            nodeId: packet.senderId, displayName: displayName);
        await db.incrementUnread(packet.senderId);
        final msg = Message(
          id: msgId ?? const Uuid().v4(),
          chatId: packet.senderId,
          kind: MessageKind.text,
          timestamp: DateTime.now(),
          isOutgoing: false,
          text: text,
          status: MessageStatus.delivered,
        );
        await chatRepo.saveMessage(msg);

        await notifications.showMessage(
          chatId: packet.senderId,
          sender: displayName,
          text: text,
        );

        if (msgId != null) {
          router.route(Packet(
            type: PacketType.messageAck,
            senderId: keys.nodeId,
            recipientId: packet.senderId,
            payload: utf8.encode(msgId),
          ));
        }

      case PacketType.messageAck:
        final msgId = utf8.decode(packet.payload, allowMalformed: true).trim();
        if (msgId.isNotEmpty) {
          await db.updateMessageStatus(msgId, MessageStatus.delivered.index);
        }

      case PacketType.messageRead:
        await db.markOutgoingMessagesRead(packet.senderId);

      default:
        break;
    }
  });

  ref.onDispose(sub.cancel);
});
