import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class SmallChip extends StatelessWidget {
  const SmallChip(this.label, {super.key, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? kAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: active ? null : Border.all(color: kLine2),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: active ? const Color(0xFF001218) : kTextMuted,
        ),
      ),
    );
  }
}
