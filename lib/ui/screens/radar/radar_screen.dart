import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/models/contact.dart';
import '../../../domain/models/user_profile.dart';
import '../../providers/app_providers.dart';
import '../../widgets/mono_text.dart';
import '../../widgets/top_bar.dart';
import 'widgets/nearby_row.dart';
import '../chat/chat_screen.dart';

class RadarScreen extends ConsumerStatefulWidget {
  const RadarScreen({super.key});

  @override
  ConsumerState<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends ConsumerState<RadarScreen> {
  int _filter = 0; // 0=ALL 1=BT 2=WIFI

  Future<void> _openChat(UserProfile profile) async {
    final db = ref.read(appDatabaseProvider);
    final chatId = await db.getOrCreateChat(
      nodeId: profile.userId,
      displayName: profile.nickname,
    );
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChatScreen(
        chatId: chatId,
        contactName: profile.nickname,
        nodeId: profile.userId,
      ),
    ));
  }

  List<UserProfile> _filtered(List<UserProfile> users) {
    return switch (_filter) {
      1 => users.where((u) => u.seenVia.contains(ConnectionMode.bluetooth)).toList(),
      2 => users.where((u) => u.seenVia.contains(ConnectionMode.wifi)).toList(),
      _ => users,
    };
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(nearbyUsersProvider);
    final allUsers = usersAsync.valueOrNull ?? [];
    final users = _filtered(allUsers);

    final btCount = allUsers.where((u) => u.seenVia.contains(ConnectionMode.bluetooth)).length;
    final wifiCount = allUsers.where((u) => u.seenVia.contains(ConnectionMode.wifi)).length;

    return Scaffold(
      backgroundColor: kBg,
      appBar: const TopBar(title: 'Nearby'),
      body: ListView(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                _FilterChip(
                  label: 'ALL · ${allUsers.length}',
                  active: _filter == 0,
                  onTap: () => setState(() => _filter = 0),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'BT · $btCount',
                  icon: Icons.bluetooth,
                  active: _filter == 1,
                  onTap: () => setState(() => _filter = 1),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'WIFI · $wifiCount',
                  icon: Icons.wifi,
                  active: _filter == 2,
                  onTap: () => setState(() => _filter = 2),
                ),
              ],
            ),
          ),
          // User list
          if (users.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 48, 14, 48),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radar, size: 48,
                        color: kAccent.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    const MonoText('НЕТ ПОЛЬЗОВАТЕЛЕЙ В ДИАПАЗОНЕ',
                        fontSize: 10, color: kTextMuted),
                  ],
                ),
              ),
            )
          else
            ...users.map((u) => NearbyRow(
                  profile: u,
                  onTap: () => _openChat(u),
                )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? kAccent.withValues(alpha: 0.12) : kCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: active ? kAccent.withValues(alpha: 0.4) : kLine),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: active ? kAccent : kTextMuted),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: active ? kAccent : kTextMuted,
                letterSpacing: 0.4,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
