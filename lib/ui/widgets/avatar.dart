import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../domain/models/contact.dart';
import 'conn_badge.dart';

/// Geometric avatar — colored square with initials, online dot, mode badge.
/// Pass [avatarBytes] to display a real photo; falls back to initials.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    this.size = 44,
    this.online = true,
    this.mode,
    this.avatarBytes,
  });

  final String name;
  final double size;
  final bool online;
  final ConnectionMode? mode;
  final Uint8List? avatarBytes;

  static const _palette = [
    (Color(0xFF00D8FF), Color(0xFF003A4A)),
    (Color(0xFF7CFFC4), Color(0xFF00382B)),
    (Color(0xFFFFB454), Color(0xFF3A2400)),
    (Color(0xFFC49BFF), Color(0xFF21123A)),
    (Color(0xFFFF5577), Color(0xFF3A0D1A)),
    (Color(0xFF5AD7FF), Color(0xFF003049)),
  ];

  String get _initials => name
      .split(' ')
      .take(2)
      .map((s) => s.isNotEmpty ? s[0].toUpperCase() : '')
      .join();

  @override
  Widget build(BuildContext context) {
    final hash = name.isNotEmpty
        ? name.codeUnitAt(0) + name.codeUnitAt(name.length - 1)
        : 0;
    final (fg, bg) = _palette[hash % _palette.length];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (avatarBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.27),
              child: Image.memory(
                avatarBytes!,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(size * 0.27),
                border: Border.all(color: fg.withValues(alpha: 0.2)),
              ),
              alignment: Alignment.center,
              child: Text(
                _initials,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  color: fg,
                  fontSize: size * 0.36,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          if (online)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: kGood,
                  shape: BoxShape.circle,
                  border: Border.all(color: kBg, width: 2),
                ),
              ),
            ),
          if (mode != null)
            Positioned(
              left: -4,
              top: -4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: kLine2),
                ),
                alignment: Alignment.center,
                child: ConnBadge(mode: mode!, size: 10),
              ),
            ),
        ],
      ),
    );
  }
}
