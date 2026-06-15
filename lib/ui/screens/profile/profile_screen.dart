import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
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
    final nickname = ownAsync.valueOrNull?.nickname ?? 'Node-${nodeId.substring(0, 4)}';
    final usersAsync = ref.watch(nearbyUsersProvider);
    final peerCount = usersAsync.valueOrNull?.length ?? 0;

    final btOn = ref.watch(btRunningProvider);
    final wifiOn = ref.watch(wifiRunningProvider);

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
          // Transport toggles
          _TransportRow(
            icon: Icons.bluetooth,
            label: 'Bluetooth',
            active: btOn,
            activeColor: const Color(0xFF5AD7FF),
            onTap: () => _toggleBt(ref, btOn),
          ),
          const SizedBox(height: 10),
          _TransportRow(
            icon: Icons.wifi,
            label: 'WiFi Direct',
            active: wifiOn,
            activeColor: kGood,
            onTap: () => _toggleWifi(ref, wifiOn),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _toggleBt(WidgetRef ref, bool current) async {
    final transport = ref.read(btTransportProvider);
    if (current) {
      await transport.stopScan();
      ref.read(btRunningProvider.notifier).state = false;
    } else {
      await transport.startScan();
      ref.read(btRunningProvider.notifier).state = true;
    }
  }

  Future<void> _toggleWifi(WidgetRef ref, bool current) async {
    final transport = ref.read(wifiTransportProvider);
    if (current) {
      await transport.stopScan();
      ref.read(wifiRunningProvider.notifier).state = false;
    } else {
      await transport.startScan();
      ref.read(wifiRunningProvider.notifier).state = true;
    }
  }
}

class _TransportRow extends StatelessWidget {
  const _TransportRow({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? activeColor.withValues(alpha: 0.35) : kLine,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: active ? activeColor : kTextMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: active ? kText : kTextMuted,
                ),
              ),
            ),
            Switch.adaptive(
              value: active,
              onChanged: (_) => onTap(),
              activeThumbColor: activeColor,
              activeTrackColor: activeColor.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
