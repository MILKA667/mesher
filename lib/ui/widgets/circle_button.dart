import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class CircleButton extends StatelessWidget {
  const CircleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.accent = false,
    this.size = 38,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: accent
            ? kAccent.withValues(alpha: 0.13)
            : Colors.white.withValues(alpha: 0.04),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: IconTheme(
            data: IconThemeData(
              color: accent ? kAccent : kText,
              size: size * 0.52,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
