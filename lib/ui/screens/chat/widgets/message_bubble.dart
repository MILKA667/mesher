import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../domain/models/message.dart';
import '../../../widgets/mono_text.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isOutgoing;
    final bg = isMe ? kAccent.withValues(alpha: 0.13) : kCard;
    final border = isMe ? kAccent.withValues(alpha: 0.25) : kLine;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            _Meta(isMe: isMe, status: message.status,
                time: _formatTime(message.timestamp)),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
