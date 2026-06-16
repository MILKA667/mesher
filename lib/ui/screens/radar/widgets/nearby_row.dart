import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../domain/models/user_profile.dart';
import '../../../widgets/avatar.dart';
import '../../../widgets/mono_text.dart';
import '../../../widgets/signal_indicator.dart';

class NearbyRow extends StatelessWidget {
  const NearbyRow({super.key, required this.profile, this.onTap});

  final UserProfile profile;
  final VoidCallback? onTap;

  String _relativeTime() {
    final diff = DateTime.now().millisecondsSinceEpoch - profile.lastSeen;
    final secs = diff ~/ 1000;
    if (secs < 60) return 'только что';
    final mins = secs ~/ 60;
    if (mins < 60) return '$mins мин назад';
    return '${mins ~/ 60} ч назад';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kLine)),
        ),
        child: Row(
          children: [
            Avatar(
              name: profile.nickname,
              mode: profile.bestTransport,
              online: true,
              size: 44,
              avatarBytes: profile.avatar,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile.nickname,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: kText,
                          ),
                        ),
                      ),
                      if (!profile.isKnownContact)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: kWarn.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const MonoText('НОВ',
                              fontSize: 9, color: kWarn),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: kGood.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const MonoText('РЯДОМ',
                            fontSize: 9, color: kGood),
                      ),
                      const SizedBox(width: 6),
                      MonoText(_relativeTime(), fontSize: 10),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${profile.distanceMeters}',
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kAccent,
                      ),
                    ),
                    const Text(
                      'm',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 9,
                        color: kAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SignalIndicator(level: profile.signalLevel, size: 11),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
