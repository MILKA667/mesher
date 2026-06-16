import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../crypto/key_manager.dart';
import '../../domain/models/contact.dart';
import '../../data/local/database/app_database.dart';
import '../../data/local/file_storage.dart';
import '../../data/local/secure_storage.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/file_repository.dart';
import '../../data/repositories/peer_repository.dart';
import '../../domain/models/chat.dart';
import '../../domain/models/file_transfer.dart';
import '../../domain/models/message.dart';
import '../../domain/models/user_profile.dart';
import '../../network/discovery/discovery_service.dart';
import '../../network/platform/bluetooth_channel.dart';
import '../../network/platform/wifi_direct_channel.dart';
import '../../network/protocol/packet.dart';
import '../../network/protocol/packet_codec.dart';
import '../../network/routing/mesh_router.dart';
import '../../network/transport/bluetooth_transport.dart';
import '../../network/transport/wifi_direct_transport.dart';
import '../../services/call_manager.dart';
import '../../services/file_transfer_service.dart';
import '../../services/mesh_service.dart';
import '../../services/notification_service.dart';
import '../../services/swarm_service.dart';

// ── Infrastructure ─────────────────────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final secureStorageProvider = Provider<SecureStorage>((_) => SecureStorageImpl());

final fileStorageProvider = Provider<FileStorage>((_) => FileStorageImpl());

// ── Crypto (only for node identity) ────────────────────────────────────────

final keyManagerProvider = Provider<KeyManager>((ref) {
  return KeyManagerImpl(ref.watch(secureStorageProvider));
});

// ── Network ────────────────────────────────────────────────────────────────

final btChannelProvider = Provider((_) => BluetoothChannel());
final wifiChannelProvider = Provider((_) => WifiDirectChannel());

final btTransportProvider = Provider((ref) {
  final t = BluetoothTransport(ref.watch(btChannelProvider));
  ref.onDispose(t.dispose);
  return t;
});

final wifiTransportProvider = Provider((ref) {
  final t = WifiDirectTransport(ref.watch(wifiChannelProvider));
  ref.onDispose(t.dispose);
  return t;
});

final packetCodecProvider = Provider<PacketCodec>((_) => CborPacketCodec());

final meshRouterProvider = Provider<MeshRouter>((ref) {
  final router = FloodRouter(ref.watch(packetCodecProvider));
  ref.onDispose(router.dispose);
  return router;
});

// ── Repositories ───────────────────────────────────────────────────────────

final chatRepoProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(appDatabaseProvider));
});

final peerRepoProvider = Provider<PeerRepository>((ref) {
  return PeerRepositoryImpl(ref.watch(appDatabaseProvider));
});

final fileRepoProvider = Provider<FileRepository>((ref) {
  return FileRepositoryImpl(ref.watch(appDatabaseProvider));
});

// ── MeshService ────────────────────────────────────────────────────────────

final meshServiceProvider = Provider<MeshService>((ref) {
  final service = MeshServiceImpl(
    keys: ref.watch(keyManagerProvider),
    router: ref.watch(meshRouterProvider),
    transports: [
      ref.watch(btTransportProvider),
      ref.watch(wifiTransportProvider),
    ],
  );
  ref.onDispose(service.dispose);
  return service;
});

// ── DiscoveryService ───────────────────────────────────────────────────────

final discoveryServiceProvider = Provider<DiscoveryService>((ref) {
  final svc = DiscoveryServiceImpl(
    keys: ref.watch(keyManagerProvider),
    storage: ref.watch(secureStorageProvider),
    router: ref.watch(meshRouterProvider),
    transports: [
      ref.watch(btTransportProvider),
      ref.watch(wifiTransportProvider),
    ],
  );
  ref.onDispose(svc.dispose);
  return svc;
});

// ── FileTransferService ────────────────────────────────────────────────────

final fileTransferServiceProvider = Provider<FileTransferService>((ref) {
  final svc = FileTransferService(
    keys: ref.watch(keyManagerProvider),
    router: ref.watch(meshRouterProvider),
    fileRepo: ref.watch(fileRepoProvider),
    fileStorage: ref.watch(fileStorageProvider),
  );
  svc.startListening(ref.watch(meshRouterProvider).incomingPackets);
  ref.onDispose(svc.dispose);
  return svc;
});

// ── CallManager ────────────────────────────────────────────────────────────

final callManagerProvider = Provider<CallManager>((ref) {
  final manager = CallManager(
    keys: ref.watch(keyManagerProvider),
    router: ref.watch(meshRouterProvider),
  );
  ref.onDispose(manager.dispose);
  return manager;
});

// ── NotificationService ────────────────────────────────────────────────────

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

// ── SwarmService (torrent-like file sharing) ───────────────────────────────

final swarmServiceProvider = Provider<SwarmService>((ref) {
  final svc = SwarmService(
    keys: ref.watch(keyManagerProvider),
    router: ref.watch(meshRouterProvider),
    fileStorage: ref.watch(fileStorageProvider),
    fileRepo: ref.watch(fileRepoProvider),
    notifications: ref.watch(notificationServiceProvider),
  );
  svc.start();
  ref.onDispose(svc.dispose);
  return svc;
});

final swarmCatalogProvider = StreamProvider<List<SwarmEntry>>((ref) {
  return ref.watch(swarmServiceProvider).catalog;
});

// ── Screen state streams ───────────────────────────────────────────────────

final chatsStreamProvider = StreamProvider<List<Chat>>((ref) {
  return ref.watch(chatRepoProvider).watchChats();
});

final nearbyUsersProvider = StreamProvider<List<UserProfile>>((ref) {
  return ref.watch(discoveryServiceProvider).nearbyUsers;
});

final transfersStreamProvider = StreamProvider<List<FileTransfer>>((ref) {
  return ref.watch(fileRepoProvider).watchTransfers();
});

final messagesStreamProvider =
    StreamProvider.family<List<dynamic>, String>((ref, chatId) {
  return ref.watch(chatRepoProvider).watchMessages(chatId);
});

// ── Own profile ────────────────────────────────────────────────────────────

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
  return UserProfile(
    userId: nodeId,
    nickname: nickname,
    lastSeen: DateTime.now().millisecondsSinceEpoch,
    seenVia: const {},
  );
});

// ── Active transport (only one at a time) ──────────────────────────────────

final activeTransportProvider =
    StateProvider<ConnectionMode>((_) => ConnectionMode.bluetooth);

// ── Current bottom nav tab ─────────────────────────────────────────────────

final currentTabProvider = StateProvider<int>((_) => 0);

// ── Unified mesh packet handler (message / ack / read / call) ─────────────

final incomingMessageHandlerProvider = Provider<void>((ref) {
  final router = ref.watch(meshRouterProvider);
  final db = ref.watch(appDatabaseProvider);
  final chatRepo = ref.watch(chatRepoProvider);
  final discovery = ref.watch(discoveryServiceProvider);
  final callManager = ref.watch(callManagerProvider);
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

      case PacketType.callSignal:
        final name = await resolveName(packet.senderId);
        await callManager.handleSignal(packet.senderId, packet.payload,
            resolveName: () => name);

      default:
        break;
    }
  });

  ref.onDispose(sub.cancel);
});
