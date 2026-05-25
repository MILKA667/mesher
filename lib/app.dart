import 'package:flutter/material.dart';
import 'theme/colors.dart';
import 'screens/chats_screen.dart';
import 'screens/radar_screen.dart';
import 'screens/files_screen.dart';
import 'screens/profile_screen.dart';

class MeshApp extends StatefulWidget {
  const MeshApp({super.key});

  @override
  State<MeshApp> createState() => _MeshAppState();
}

class _MeshAppState extends State<MeshApp> {
  int _currentIndex = 0;

  static const _screens = [
    ChatsScreen(),
    RadarScreen(),
    FilesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _MeshBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _MeshBottomNav extends StatelessWidget {
  const _MeshBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    _TabItem(icon: Icons.chat_bubble_outline, label: 'CHATS'),
    _TabItem(icon: Icons.radar, label: 'NEARBY'),
    _TabItem(icon: Icons.folder_outlined, label: 'FILES'),
    _TabItem(icon: Icons.person_outline, label: 'PROFILE'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kBg,
        border: Border(top: BorderSide(color: kLine, width: 1)),
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
                      // top indicator line for active tab
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
                          Icon(
                            tab.icon,
                            size: 22,
                            color: active ? kAccent : kTextMuted,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            tab.label,
                            style: TextStyle(
                              color: active ? kAccent : kTextMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              fontFamily: 'monospace',
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

class _TabItem {
  const _TabItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
