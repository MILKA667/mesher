import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/colors.dart';
import 'domain/models/contact.dart';
import 'main.dart' show rootNavigatorKey;
import 'services/call_manager.dart';
import 'services/foreground_service.dart';
import 'ui/providers/app_providers.dart';
import 'ui/screens/call/video_call_screen.dart';
import 'ui/screens/chat/chat_screen.dart';
import 'ui/widgets/bottom_nav.dart';
import 'ui/screens/chats/chats_screen.dart';
import 'ui/screens/radar/radar_screen.dart';
import 'ui/screens/files/files_screen.dart';
import 'ui/screens/profile/profile_screen.dart';

class MeshApp extends ConsumerStatefulWidget {
  const MeshApp({super.key});

  @override
  ConsumerState<MeshApp> createState() => _MeshAppState();
}

class _MeshAppState extends ConsumerState<MeshApp> {
  static const _screens = [
    ChatsScreen(),
    RadarScreen(),
    FilesScreen(),
    ProfileScreen(),
  ];

  StreamSubscription? _incomingCallSub;
  StreamSubscription? _notificationTapSub;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _incomingCallSub?.cancel();
    _notificationTapSub?.cancel();
    super.dispose();
  }

  Future<void> _boot() async {
    await ref.read(keyManagerInitProvider.future);
    if (!mounted) return;

    final km = ref.read(keyManagerProvider);
    final nodeIdBytes = km.publicKeyBytes.take(8).toList();
    final storage = ref.read(secureStorageProvider);
    final nickname = await storage.read('profile_nickname') ??
        'Node-${km.nodeId.substring(0, 4)}';

    await ref.read(btChannelProvider).setProfile(nodeIdBytes, nickname);
    await ref.read(wifiChannelProvider).setNodeId(nodeIdBytes);

    await ref.read(meshServiceProvider).start();

    // Stop the transport that isn't selected (default = BT).
    if (ref.read(activeTransportProvider) == ConnectionMode.bluetooth) {
      await ref.read(wifiTransportProvider).stopScan();
    } else {
      await ref.read(btTransportProvider).stopScan();
    }

    await ref.read(discoveryServiceProvider).start();
    ref.read(incomingMessageHandlerProvider);
    // Boot swarm (file sharing) listener.
    ref.read(swarmServiceProvider);

    final notifications = ref.read(notificationServiceProvider);
    notifications.bindLifecycle();
    await notifications.init();

    _notificationTapSub = notifications.onChatTap.listen((chatId) {
      if (!mounted) return;
      _openChat(chatId);
    });

    final callManager = ref.read(callManagerProvider);
    _incomingCallSub = callManager.incomingCallStream.listen((info) {
      if (!mounted) return;
      notifications.showCall(peerId: info.peerId, peerName: info.peerName ?? info.peerId);
      _showIncomingCall(info);
    });

    try {
      await AndroidForegroundService().start(notificationTitle: 'MeshLink active');
    } catch (_) {}
  }

  Future<void> _openChat(String chatId) async {
    ref.read(currentTabProvider.notifier).state = 0;
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;
    final db = ref.read(appDatabaseProvider);
    final chat = await db.findChat(chatId);
    if (!mounted) return;
    navigator.push(MaterialPageRoute<void>(
      builder: (_) => ChatScreen(
        chatId: chatId,
        contactName: chat?.displayName,
      ),
    ));
  }

  void _showIncomingCall(IncomingCallInfo info) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => _IncomingCallSheet(
        info: info,
        onAccept: () {
          ref.read(notificationServiceProvider).cancelCall();
          Navigator.of(ctx).pop();
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => VideoCallScreen(
              peerId: info.peerId,
              peerName: info.peerName,
              isIncoming: true,
            ),
          ));
        },
        onReject: () {
          ref.read(notificationServiceProvider).cancelCall();
          ref.read(callManagerProvider).endCall();
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(currentTabProvider);
    return Scaffold(
      body: IndexedStack(
        index: tab,
        children: _screens,
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: tab,
        onTap: (i) => ref.read(currentTabProvider.notifier).state = i,
      ),
    );
  }
}

class _IncomingCallSheet extends StatelessWidget {
  const _IncomingCallSheet({
    required this.info,
    required this.onAccept,
    required this.onReject,
  });

  final IncomingCallInfo info;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 44),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: kAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: kAccent.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.videocam, color: kAccent, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            info.peerName ?? info.peerId,
            style: const TextStyle(
              color: kText,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Входящий видеозвонок',
            style: TextStyle(color: kTextMuted, fontSize: 12),
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CallAction(
                icon: Icons.call_end,
                color: kDanger,
                label: 'Отклонить',
                onTap: onReject,
              ),
              _CallAction(
                icon: Icons.videocam,
                color: kGood,
                label: 'Принять',
                onTap: onAccept,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CallAction extends StatelessWidget {
  const _CallAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.black87, size: 30),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: kTextMuted, fontSize: 12)),
      ],
    );
  }
}
