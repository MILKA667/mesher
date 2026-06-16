import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

/// Curated list of frequently-used emojis. Splittable across composer
/// (insert) and reactions (toggle) without pulling in a heavyweight package.
const kCommonEmojis = <String>[
  '😀', '😂', '😊', '😍', '🥰', '😘', '😎', '🤔',
  '😅', '😇', '🙃', '😉', '😋', '🤗', '🤩', '😜',
  '😢', '😭', '😡', '😱', '🥺', '😴', '🤤', '🤐',
  '👍', '👎', '👌', '✌️', '🤝', '🙏', '👏', '🙌',
  '💪', '🤞', '🫶', '👀', '💀', '🔥', '✨', '⭐',
  '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '💔',
  '💯', '🎉', '🎊', '🥳', '🎁', '🎂', '🍕', '🍔',
  '☕', '🍺', '🍷', '🌹', '🌟', '⚡', '🌈', '☀️',
];

/// Most common reactions — shown first in the reactions sheet.
const kQuickReactions = <String>['👍', '❤️', '😂', '😮', '😢', '🙏', '🔥', '🎉'];

class EmojiSheet extends StatelessWidget {
  const EmojiSheet({super.key, required this.onSelected, this.title});

  final ValueChanged<String> onSelected;
  final String? title;

  static Future<String?> show(BuildContext context, {String? title}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => EmojiSheet(
        title: title,
        onSelected: (e) => Navigator.of(ctx).pop(e),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Text(
                  title!,
                  style: const TextStyle(
                    color: kTextMuted,
                    fontSize: 12,
                    fontFamily: 'JetBrainsMono',
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: kCommonEmojis.length,
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemBuilder: (_, i) {
                  final e = kCommonEmojis[i];
                  return GestureDetector(
                    onTap: () => onSelected(e),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kLine),
                      ),
                      alignment: Alignment.center,
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact horizontal strip for picking a quick reaction.
class QuickReactionBar extends StatelessWidget {
  const QuickReactionBar({super.key, required this.onSelected, this.onMore});

  final ValueChanged<String> onSelected;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final e in kQuickReactions)
            GestureDetector(
              onTap: () => onSelected(e),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(e, style: const TextStyle(fontSize: 26)),
              ),
            ),
          if (onMore != null)
            IconButton(
              tooltip: 'Ещё эмодзи',
              icon: const Icon(Icons.add, color: kTextMuted, size: 22),
              onPressed: onMore,
            ),
        ],
      ),
    );
  }
}
