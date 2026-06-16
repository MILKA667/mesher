import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/models/message.dart';
import '../../../network/protocol/packet.dart';
import '../../providers/app_providers.dart';
import '../../widgets/mono_text.dart';
import '../../widgets/top_bar.dart';
import '../call/voice_call_screen.dart';
import 'chat_controller.dart';
import 'widgets/composer.dart';
import 'widgets/file_bubble.dart';
import 'widgets/message_bubble.dart';
import 'widgets/voice_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.chatId, this.contactName, this.nodeId});

  final String chatId;
  final String? contactName;
  final String? nodeId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    _markRead();
    ref.read(notificationServiceProvider)
      ..setActiveChat(widget.chatId)
      ..cancelChat(widget.chatId);
  }

  @override
  void dispose() {
    ref.read(notificationServiceProvider).setActiveChat(null);
    super.dispose();
  }

  Future<void> _markRead() async {
    await ref.read(chatRepoProvider).markRead(widget.chatId);
    final ownId = ref.read(keyManagerProvider).nodeId;
    if (ownId.isEmpty) return;
    ref.read(meshRouterProvider).route(Packet(
      type: PacketType.messageRead,
      senderId: ownId,
      recipientId: widget.chatId,
      payload: const [],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider(widget.chatId));
    final messages = chatState.messages;

    return Scaffold(
      backgroundColor: kBg,
      appBar: TopBar(
        title: widget.contactName ?? widget.chatId,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kText, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          _VoiceCallButton(chatId: widget.chatId, contactName: widget.contactName),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                Color(0x8800D8FF),
                Colors.transparent,
              ]),
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? _EmptyChat(contactName: widget.contactName)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                    itemCount: messages.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == 0) return const _DateChip('СЕГОДНЯ');
                      final msg = messages[index - 1];
                      return switch (msg.kind) {
                        MessageKind.file => FileBubble(message: msg),
                        MessageKind.voice => VoiceBubble(message: msg),
                        _ => MessageBubble(message: msg),
                      };
                    },
                  ),
          ),
          Composer(chatId: widget.chatId),
        ],
      ),
    );
  }
}

class _VoiceCallButton extends ConsumerWidget {
  const _VoiceCallButton({required this.chatId, this.contactName});
  final String chatId;
  final String? contactName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Голосовой звонок',
      icon: const Icon(
        Icons.call_outlined,
        color: kAccent,
        size: 22,
      ),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => VoiceCallScreen(
            peerId: chatId,
            peerName: contactName,
            isIncoming: false,
          ),
        ));
      },
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({this.contactName});
  final String? contactName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 32, color: kAccent.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          MonoText('ПОДКЛЮЧЕНО', fontSize: 10, color: kTextMuted),
          const SizedBox(height: 6),
          Text(
            'Начни переписку с ${contactName ?? 'пиром'}',
            style: const TextStyle(fontSize: 12, color: kTextDim),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: kLine),
        ),
        child: MonoText(label, fontSize: 9, color: kTextMuted),
      ),
    );
  }
}
