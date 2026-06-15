import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/foreground_service.dart';
import 'ui/providers/app_providers.dart';
import 'ui/widgets/bottom_nav.dart';
import 'ui/screens/chats/chats_screen.dart';
import 'ui/screens/radar/radar_screen.dart';
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
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _boot();
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
    await ref.read(discoveryServiceProvider).start();
    ref.read(incomingMessageHandlerProvider);

    try {
      await AndroidForegroundService().start(notificationTitle: 'MeshLink active');
    } catch (_) {}
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
