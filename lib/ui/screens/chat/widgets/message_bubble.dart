import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../domain/models/message.dart';
import '../../../../domain/models/reaction.dart';
import '../../../providers/app_providers.dart';
import '../../../widgets/mono_text.dart';
import 'emoji_picker.dart';

class MessageBubble extends ConsumerWidget {
  const MessageBubble({super.key, required this.message});
  final Message message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMe = message.isOutgoing;
    final bg = isMe ? kAccent.withValues(alpha: 0.13) : kCard;
    final border = isMe ? kAccent.withValues(alpha: 0.25) : kLine;

    final reactionsAsync = ref.watch(chatReactionsProvider(message.chatId));
    final reactions = (reactionsAsync.valueOrNull ?? const <Reaction>[])
        .where((r) => r.messageId == message.id)
        .toList();

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: () => _showReactionPicker(context, ref),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: bg,
                  border: Border.all(color: border),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: Radius.circular(isMe ? 14 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 14),
                  ),
                ),
                child: Text(
                  message.text ?? '',
                  style: const TextStyle(
                      fontSize: 14, color: kText, height: 1.4),
                ),
              ),
            ),
            if (reactions.isNotEmpty) ...[
              const SizedBox(height: 4),
              _ReactionsRow(
                isMe: isMe,
                reactions: reactions,
                onTap: (emoji) => _toggle(ref, emoji),
              ),
            ],
            _Meta(
              isMe: isMe,
              status: message.status,
              time: _formatTime(message.timestamp),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReactionPicker(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuickReactionBar(
              onSelected: (emoji) {
                Navigator.of(sheetCtx).pop();
                _toggle(ref, emoji);
              },
              onMore: () async {
                Navigator.of(sheetCtx).pop();
                final picked = await EmojiSheet.show(context,
                    title: 'РЕАКЦИЯ НА СООБЩЕНИЕ');
                if (picked != null) _toggle(ref, picked);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggle(WidgetRef ref, String emoji) {
    ref.read(reactionsServiceProvider).toggle(
          chatId: message.chatId,
          messageId: message.id,
          emoji: emoji,
        );
  }

  static String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _ReactionsRow extends ConsumerWidget {
  const _ReactionsRow({
    required this.isMe,
    required this.reactions,
    required this.onTap,
  });

  final bool isMe;
  final List<Reaction> reactions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownId = ref.watch(keyManagerProvider).nodeId;
    // Group reactions by emoji.
    final grouped = <String, List<Reaction>>{};
    for (final r in reactions) {
      grouped.putIfAbsent(r.emoji, () => []).add(r);
    }
    return Wrap(
      alignment: isMe ? WrapAlignment.end : WrapAlignment.start,
      spacing: 4,
      runSpacing: 4,
      children: grouped.entries.map((e) {
        final mine = e.value.any((r) => r.userId == ownId);
        return GestureDetector(
          onTap: () => onTap(e.key),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: mine
                  ? kAccent.withValues(alpha: 0.18)
                  : kBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: mine
                    ? kAccent.withValues(alpha: 0.5)
                    : kLine,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.key, style: const TextStyle(fontSize: 13)),
                if (e.value.length > 1) ...[
                  const SizedBox(width: 4),
                  Text(
                    '${e.value.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'JetBrainsMono',
                      color: mine ? kAccent : kTextMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.isMe, required this.status, required this.time});
  final bool isMe;
  final MessageStatus status;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 3, 4, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MonoText(time, fontSize: 10, color: kTextDim),
          if (isMe) ...[
            const SizedBox(width: 4),
            _StatusIcon(status: status),
          ],
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});
  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      MessageStatus.sending => const SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            strokeWidth: 1.2,
            color: kTextDim,
          ),
        ),
      MessageStatus.sent => const Icon(Icons.done, size: 12, color: kTextDim),
      MessageStatus.delivered =>
        const Icon(Icons.done_all, size: 12, color: kTextDim),
      MessageStatus.read =>
        const Icon(Icons.done_all, size: 12, color: kAccent),
    };
  }
}
