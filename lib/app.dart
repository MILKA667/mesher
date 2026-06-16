import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/colors.dart';
import 'main.dart' show rootNavigatorKey;
import 'services/foreground_service.dart';
import 'services/voice_call_service.dart';
import 'ui/providers/app_providers.dart';
import 'ui/screens/call/voice_call_screen.dart';
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

  StreamSubscription? _incomingVoiceCallSub;
  StreamSubscription? _notificationTapSub;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _incomingVoiceCallSub?.cancel();
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

    await ref.read(meshServiceProvider).start();

    await ref.read(discoveryServiceProvider).start();
    ref.read(incomingMessageHandlerProvider);
    // Boot swarm (file sharing) listener.
    ref.read(swarmServiceProvider);
    // Boot reactions listener.
    ref.read(reactionsServiceProvider);

    final notifications = ref.read(notificationServiceProvider);
    notifications.bindLifecycle();
    await notifications.init();

    _notificationTapSub = notifications.onChatTap.listen((chatId) {
      if (!mounted) return;
      _openChat(chatId);
    });

    final voiceService = ref.read(voiceCallServiceProvider);
    _incomingVoiceCallSub = voiceService.incomingCallStream.listen((info) {
      if (!mounted) return;
      notifications.showCall(
          peerId: info.peerId, peerName: info.peerName ?? info.peerId);
      _showIncomingVoiceCall(info);
    });

    try {
      await AndroidForegroundService().start(notificationTitle: 'MeshLink — в эфире');
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

  void _showIncomingVoiceCall(VoiceCallInfo info) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => _IncomingVoiceCallSheet(
        info: info,
        onAccept: () {
          ref.read(notificationServiceProvider).cancelCall();
          Navigator.of(ctx).pop();
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => VoiceCallScreen(
              peerId: info.peerId,
              peerName: info.peerName,
              isIncoming: true,
            ),
          ));
        },
        onReject: () {
          ref.read(notificationServiceProvider).cancelCall();
          ref.read(voiceCallServiceProvider).rejectCall();
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

class _IncomingVoiceCallSheet extends StatelessWidget {
  const _IncomingVoiceCallSheet({
    required this.info,
    required this.onAccept,
    required this.onReject,
  });

  final VoiceCallInfo info;
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
            child: const Icon(Icons.call, color: kAccent, size: 32),
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
            'Входящий голосовой звонок',
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
                icon: Icons.call,
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
