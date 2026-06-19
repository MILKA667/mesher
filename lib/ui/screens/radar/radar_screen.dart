import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../domain/models/user_profile.dart';
import '../../providers/app_providers.dart';
import '../../widgets/mono_text.dart';
import '../../widgets/top_bar.dart';
import 'widgets/nearby_row.dart';
import 'widgets/radar_canvas.dart';
import '../chat/chat_screen.dart';

class RadarScreen extends ConsumerStatefulWidget {
  const RadarScreen({super.key});

  @override
  ConsumerState<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends ConsumerState<RadarScreen> {
  String? _selectedUserId;

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

  void _tapRadarDot(UserProfile profile) {
    setState(() => _selectedUserId = profile.userId);
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(nearbyUsersProvider);
    final users = (usersAsync.valueOrNull ?? const <UserProfile>[])
        .toList()
      ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

    final closest = users.isEmpty ? null : users.first;
    final knownCount = users.where((u) => u.isKnownContact).length;
    final maxDist = users.isEmpty
        ? 50
        : (users.map((u) => u.distanceMeters).reduce((a, b) => a > b ? a : b))
            .clamp(20, 999);

    final scaffold = Scaffold(
      backgroundColor: kBg,
      appBar: const TopBar(title: 'Рядом'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
        children: [
          _StatusBar(
            total: users.length,
            known: knownCount,
            closestMeters: closest?.distanceMeters,
            isScanning: users.isEmpty,
          ),
          const SizedBox(height: 14),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: kCard.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kLine),
              ),
              padding: const EdgeInsets.all(12),
              child: RadarCanvas(
                users: users,
                maxDistanceMeters: maxDist,
                selectedUserId: _selectedUserId,
                onTapPeer: _tapRadarDot,
              ),
            ),
          ),
          const SizedBox(height: 6),
          _Legend(),
          const SizedBox(height: 18),
          if (users.isEmpty)
            const _EmptyRadar()
          else ...[
            const _SectionLabel('В РАДИУСЕ'),
            const SizedBox(height: 4),
            ...users.map((u) => _SelectableRow(
                  profile: u,
                  selected: _selectedUserId == u.userId,
                  onTap: () => _openChat(u),
                  onLongPress: () =>
                      setState(() => _selectedUserId = u.userId),
                )),
          ],
        ],
      ),
    );

    return scaffold;
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.total,
    required this.known,
    required this.closestMeters,
    required this.isScanning,
  });

  final int total;
  final int known;
  final int? closestMeters;
  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kLine),
      ),
      child: Row(
        children: [
          _PulseDot(active: !isScanning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isScanning
                      ? 'Сканирование Bluetooth…'
                      : 'Mesh активен',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: kText),
                ),
                const SizedBox(height: 2),
                MonoText(
                  isScanning
                      ? 'Ищем пиров в радиусе ~50 м'
                      : 'Найдено $total · знакомых $known'
                          '${closestMeters != null ? ' · ближайший $closestMeters м' : ''}',
                  fontSize: 10,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isScanning
                  ? kWarn.withValues(alpha: 0.15)
                  : kGood.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isScanning
                    ? kWarn.withValues(alpha: 0.4)
                    : kGood.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              isScanning ? 'СКАН' : 'ОНЛАЙН',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isScanning ? kWarn : kGood,
                fontFamily: 'JetBrainsMono',
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.active});
  final bool active;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.active ? kGood : kWarn;
    return SizedBox(
      width: 18,
      height: 18,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          final t = _ctrl.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 6 + 12 * t,
                height: 6 + 12 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: (1 - t) * 0.3),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: const [
          _LegendDot(color: kAccent),
          SizedBox(width: 5),
          Text('новый', style: TextStyle(color: kTextMuted, fontSize: 10)),
          SizedBox(width: 12),
          _LegendDot(color: kGood),
          SizedBox(width: 5),
          Text('знакомый', style: TextStyle(color: kTextMuted, fontSize: 10)),
          Spacer(),
          Text('Тап по точке — выделить',
              style: TextStyle(color: kTextDim, fontSize: 10)),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: kTextMuted,
            letterSpacing: 1.2,
            fontFamily: 'JetBrainsMono',
          ),
        ),
      );
}

class _SelectableRow extends StatelessWidget {
  const _SelectableRow({
    required this.profile,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final UserProfile profile;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? kAccent.withValues(alpha: 0.08) : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: selected ? kAccent : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: NearbyRow(profile: profile, onTap: onTap),
      ),
    );
  }
}

class _EmptyRadar extends StatelessWidget {
  const _EmptyRadar();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        children: [
          const MonoText('РЯДОМ НИКОГО НЕТ',
              fontSize: 10, color: kTextMuted),
          const SizedBox(height: 6),
          const Text(
            'Убедись, что Bluetooth включён —\nприложение само найдёт ближайших пиров.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: kTextDim, height: 1.5),
          ),
        ],
      ),
    );
  }
}
