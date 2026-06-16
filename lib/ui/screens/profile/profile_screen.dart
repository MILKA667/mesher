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
    final nickname =
        ownAsync.valueOrNull?.nickname ?? 'Node-${nodeId.substring(0, 4)}';
    final usersAsync = ref.watch(nearbyUsersProvider);
    final peerCount = usersAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: kBg,
      appBar: const TopBar(title: 'Профиль'),
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
                  SmallChip('$peerCount ПИРОВ'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Transport label
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

          const _BluetoothCard(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _BluetoothCard extends StatelessWidget {
  const _BluetoothCard();

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF5AD7FF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bluetooth, size: 18, color: activeColor),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Bluetooth LE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kText,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Активен · до 50 м',
            style: TextStyle(
              fontSize: 11,
              color: activeColor,
              fontFamily: 'JetBrainsMono',
            ),
          ),
        ],
      ),
    );
  }
}
