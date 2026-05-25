import 'package:flutter/material.dart';
import '../theme/colors.dart';

class MeshAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MeshAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 72 : 56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              if (leading != null) leading! else const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: kText,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: subtitleColor ?? kTextMuted,
                          fontSize: 11,
                          fontFamily: 'monospace',
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ...actions,
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1, color: kLine),
        ],
      ),
    );
  }
}
