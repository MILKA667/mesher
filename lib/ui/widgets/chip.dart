import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class MeshChip extends StatelessWidget {
  const MeshChip(
    this.label, {
    super.key,
    this.active = false,
    this.onTap,
    this.icon,
    this.activeColor,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;
  final Widget? icon;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? kAccent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color : kCard,
          borderRadius: BorderRadius.circular(100),
          border: active ? null : Border.all(color: kLine2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              IconTheme(
                data: IconThemeData(
                  size: 13,
                  color: active ? const Color(0xFF001218) : kText,
                ),
                child: icon!,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: active ? const Color(0xFF001218) : kText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
