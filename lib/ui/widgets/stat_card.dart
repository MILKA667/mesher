import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import 'mono_text.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final Widget icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final color = valueColor ?? kAccent;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconTheme(
                  data: IconThemeData(size: 14, color: color),
                  child: icon,
                ),
                const SizedBox(width: 5),
                MonoText(label, fontSize: 9, color: kTextMuted),
              ],
            ),
            const SizedBox(height: 4),
            MonoText(value, fontSize: 13, color: color),
          ],
        ),
      ),
    );
  }
}
