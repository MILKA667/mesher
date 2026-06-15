import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/models/message.dart';
import '../../providers/app_providers.dart';

class ChatState {
  const ChatState({
    this.messages = const [],
    this.isSending = false,
  });

  final List<Message> messages;
  final bool isSending;

  ChatState copyWith({List<Message>? messages, bool? isSending}) =>
      ChatState(
        messages: messages ?? this.messages,
        isSending: isSending ?? this.isSending,
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._ref, this.chatId) : super(const ChatState());
  final Ref _ref;
  final String chatId;

  void updateMessages(List<Message> msgs) =>
      state = state.copyWith(messages: msgs);

  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    state = state.copyWith(isSending: true);
    final msg = Message(
      id: const Uuid().v4(),
      chatId: chatId,
      kind: MessageKind.text,
      timestamp: DateTime.now(),
      isOutgoing: true,
      text: text.trim(),
      status: MessageStatus.sending,
    );
    await _ref.read(chatRepoProvider).saveMessage(msg);
    try {
      await _ref
          .read(meshServiceProvider)
          .send(chatId, utf8.encode(text.trim()));
      await _ref
          .read(appDatabaseProvider)
          .updateMessageStatus(msg.id, MessageStatus.sent.index);
    } catch (_) {}
    state = state.copyWith(isSending: false);
  }
}

final chatNotifierProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, String>(
        (ref, chatId) {
  final notifier = ChatNotifier(ref, chatId);
  ref.listen(messagesStreamProvider(chatId), (_, next) {
    next.whenData((msgs) => notifier.updateMessages(msgs as List<Message>));
  });
  return notifier;
});
