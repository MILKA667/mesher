import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// Inline JetBrains Mono text — used for node IDs, bytes, speeds, timestamps.
class MonoText extends StatelessWidget {
  const MonoText(
    this.data, {
    super.key,
    this.style,
    this.color,
    this.fontSize = 11,
  });

  final String data;
  final TextStyle? style;
  final Color? color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: fontSize,
        color: color ?? kTextMuted,
        letterSpacing: -0.1,
      ).merge(style),
    );
  }
}
