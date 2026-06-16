import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    _Tab(icon: Icons.chat_bubble_outline, label: 'CHATS'),
    _Tab(icon: Icons.radar, label: 'NEARBY'),
    _Tab(icon: Icons.share_outlined, label: 'SWARM'),
    _Tab(icon: Icons.person_outline, label: 'PROFILE'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kBg,
        border: Border(top: BorderSide(color: kLine)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      if (active)
                        Positioned(
                          top: 0,
                          child: Container(
                            width: 24,
                            height: 2,
                            decoration: BoxDecoration(
                              color: kAccent,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: kAccent.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(tab.icon, size: 22,
                              color: active ? kAccent : kTextMuted),
                          const SizedBox(height: 5),
                          Text(
                            tab.label,
                            style: TextStyle(
                              color: active ? kAccent : kTextMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              fontFamily: 'JetBrainsMono',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
