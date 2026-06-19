import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class SignalIndicator extends StatelessWidget {
  const SignalIndicator({super.key, this.level = 3, this.size = 14});

  final int level;
  final double size;

  @override
  Widget build(BuildContext context) {
    const barHeights = [3.0, 6.0, 9.0, 12.0];
    final barWidth = size * 0.18;
    final gap = size * 0.08;

    return SizedBox(
      width: size,
      height: size,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (i) {
          final active = i < level;
          return Container(
            width: barWidth,
            height: barHeights[i] * size / 14,
            margin: EdgeInsets.only(left: i == 0 ? 0 : gap),
            decoration: BoxDecoration(
              color: active ? kAccent : kTextDim,
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }),
      ),
    );
  }
}
