import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/models/contact.dart';
import '../../providers/app_providers.dart';
import '../../widgets/avatar.dart';
import '../../widgets/mono_text.dart';
import '../../widgets/small_chip.dart';
import '../../widgets/top_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodeIdAsync = ref.watch(keyManagerInitProvider);
    final nodeId = nodeIdAsync.valueOrNull ?? '——·——';
    final ownAsync = ref.watch(ownProfileProvider);
    final nickname =
        ownAsync.valueOrNull?.nickname ?? 'Node-${nodeId.substring(0, 4)}';
    final usersAsync = ref.watch(nearbyUsersProvider);
    final peerCount = usersAsync.valueOrNull?.length ?? 0;

    final active = ref.watch(activeTransportProvider);

    return Scaffold(
      backgroundColor: kBg,
      appBar: const TopBar(title: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Avatar + name
          Row(
            children: [
              Avatar(name: nickname, size: 72, online: true),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nickname,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: kText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  MonoText(nodeId, fontSize: 11),
                  const SizedBox(height: 8),
                  SmallChip('$peerCount PEERS'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Transport selector label
          const Padding(
            padding: EdgeInsets.only(left: 2, bottom: 10),
            child: Text(
              'ТРАНСПОРТ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: kTextMuted,
                letterSpacing: 1.2,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ),

          // Transport toggle cards
          Row(
            children: [
              Expanded(
                child: _TransportCard(
                  icon: Icons.bluetooth,
                  label: 'Bluetooth',
                  subtitle: 'До 50 м',
                  active: active == ConnectionMode.bluetooth,
                  activeColor: const Color(0xFF5AD7FF),
                  onTap: () => _switchTo(ref, ConnectionMode.bluetooth, active),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TransportCard(
                  icon: Icons.wifi,
                  label: 'WiFi Direct',
                  subtitle: 'До 200 м',
                  active: active == ConnectionMode.wifi,
                  activeColor: kGood,
                  onTap: () => _switchTo(ref, ConnectionMode.wifi, active),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _switchTo(
    WidgetRef ref,
    ConnectionMode next,
    ConnectionMode current,
  ) async {
    if (next == current) return;

    final bt = ref.read(btTransportProvider);
    final wifi = ref.read(wifiTransportProvider);

    if (next == ConnectionMode.bluetooth) {
      await wifi.stopScan();
      await bt.startScan();
    } else {
      await bt.stopScan();
      await wifi.startScan();
    }

    ref.read(activeTransportProvider.notifier).state = next;
  }
}

class _TransportCard extends StatelessWidget {
  const _TransportCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: active ? activeColor.withValues(alpha: 0.09) : kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? activeColor.withValues(alpha: 0.5) : kLine,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: 18, color: active ? activeColor : kTextMuted),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? activeColor : kTextDim,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? kText : kTextMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              active ? 'Активен' : subtitle,
              style: TextStyle(
                fontSize: 11,
                color: active ? activeColor : kTextDim,
                fontFamily: 'JetBrainsMono',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
