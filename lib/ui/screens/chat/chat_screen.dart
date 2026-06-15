import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../domain/models/message.dart';
import '../../widgets/mono_text.dart';
import '../../widgets/top_bar.dart';
import 'chat_controller.dart';
import 'widgets/composer.dart';
import 'widgets/file_bubble.dart';
import 'widgets/message_bubble.dart';
import 'widgets/voice_bubble.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key, required this.chatId, this.contactName, this.nodeId});

  final String chatId;
  final String? contactName;
  final String? nodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatNotifierProvider(chatId));
    final messages = chatState.messages;

    return Scaffold(
      backgroundColor: kBg,
      appBar: TopBar(
        title: contactName ?? chatId,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kText, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [],
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
                ? _EmptyChat(contactName: contactName)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                    itemCount: messages.length + 1,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
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
          Composer(chatId: chatId),
        ],
      ),
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
          Icon(Icons.chat_bubble_outline, size: 32,
              color: kAccent.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          MonoText('MESH CONNECTED', fontSize: 10, color: kTextMuted),
          const SizedBox(height: 6),
          Text(
            'Начните переписку с ${contactName ?? 'пиром'}',
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
