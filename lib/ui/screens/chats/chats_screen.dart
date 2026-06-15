import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/models/contact.dart';
import '../../../domain/models/user_profile.dart';
import '../../providers/app_providers.dart';
import '../../widgets/mono_text.dart';
import '../../widgets/small_chip.dart';
import '../../widgets/top_bar.dart';
import '../chat/chat_screen.dart';
import 'chats_controller.dart';
import 'widgets/chat_row.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatsNotifierProvider);
    final nearbyAsync = ref.watch(nearbyUsersProvider);

    return Scaffold(
      backgroundColor: kBg,
      appBar: const TopBar(title: 'Mesh'),
      body: Stack(
        children: [
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                child: _MeshStrip(nearby: nearbyAsync.valueOrNull ?? []),
              ),
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: kAccent),
                  ),
                )
              else if (state.filtered.isEmpty)
                const _EmptyChats()
              else
                ...state.filtered.map((vm) => ChatRow(
                      vm: vm,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: vm.id,
                            contactName: vm.displayName,
                          ),
                        ),
                      ),
                    )),
              const SizedBox(height: 88),
            ],
          ),
          Positioned(
            right: 18,
            bottom: 18,
            child: _Fab(
              onTap: () => ref.read(currentTabProvider.notifier).state = 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeshStrip extends StatelessWidget {
  const _MeshStrip({required this.nearby});
  final List<UserProfile> nearby;

  @override
  Widget build(BuildContext context) {
    final bt = nearby.where((u) => u.seenVia.contains(ConnectionMode.bluetooth)).length;
    final wifi = nearby.where((u) => u.seenVia.contains(ConnectionMode.wifi)).length;
    final isActive = nearby.isNotEmpty;

    final parts = <String>[
      if (bt > 0) '$bt BT',
      if (wifi > 0) '$wifi WiFi',
    ];
    final subtitle = isActive ? parts.join(' · ') : 'Scanning…';

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kLine),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kAccent.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kAccent.withValues(alpha: 0.2)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.radar, size: 20, color: kAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? 'Local mesh active' : 'Searching for peers…',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: kText),
                ),
                const SizedBox(height: 2),
                MonoText(subtitle, fontSize: 11),
              ],
            ),
          ),
          SmallChip(isActive ? 'ON' : 'SCAN', active: isActive),
        ],
      ),
    );
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 64, 32, 0),
      child: Column(
        children: [
          Icon(Icons.chat_bubble_outline, size: 48,
              color: kAccent.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          const MonoText('НЕТ ЧАТОВ', fontSize: 11, color: kTextMuted),
          const SizedBox(height: 6),
          const Text(
            'Подключитесь к пиру через Radar\nи начните переписку',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: kTextDim, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  const _Fab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: kAccent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: kAccent.withValues(alpha: 0.25),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.add, size: 26, color: Color(0xFF001218)),
      ),
    );
  }
}
