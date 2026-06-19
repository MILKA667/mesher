import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../widgets/avatar.dart';
import '../../../widgets/mono_text.dart';
import '../../../widgets/signal_indicator.dart';
import '../../../../domain/models/message.dart';
import '../chat_view_model.dart';

class ChatRow extends StatelessWidget {
  const ChatRow({super.key, required this.vm, this.onTap});

  final ChatViewModel vm;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kLine)),
        ),
        child: Row(
          children: [
            Avatar(
              name: vm.displayName,
              mode: vm.mode,
              online: vm.isOnline,
              size: 46,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vm.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: kText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      MonoText(
                        vm.timeLabel,
                        fontSize: 10,
                        color: vm.unreadCount > 0 ? kAccent : kTextDim,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  Row(
                    children: [
                      if (vm.lastMessageOutgoing &&
                          vm.lastMessageStatus == MessageStatus.read)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.done_all, size: 14, color: kAccent),
                        ),
                      Expanded(child: _preview()),
                      const SizedBox(width: 6),
                      SignalIndicator(level: vm.signalLevel, size: 12),
                      if (vm.unreadCount > 0) ...[
                        const SizedBox(width: 6),
                        _UnreadBadge(count: vm.unreadCount),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preview() {
    switch (vm.lastMessageKind) {
      case MessageKind.file:
        return Row(
          children: const [
            Icon(Icons.attach_file, size: 13, color: kTextMuted),
            SizedBox(width: 3),
            Expanded(
              child: Text('файл',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: kTextMuted)),
            ),
          ],
        );
      case MessageKind.voice:
        return Row(
          children: const [
            Icon(Icons.mic, size: 13, color: kTextMuted),
            SizedBox(width: 3),
            Expanded(
              child: Text('голосовое',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: kTextMuted)),
            ),
          ],
        );
      default:
        return Text(
          vm.lastMessage ?? '',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: kTextMuted),
        );
    }
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: kAccent,
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: const TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF001218),
        ),
      ),
    );
  }
}
