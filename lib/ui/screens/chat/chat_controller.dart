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
    final trimmed = text.trim();
    final msg = Message(
      id: const Uuid().v4(),
      chatId: chatId,
      kind: MessageKind.text,
      timestamp: DateTime.now(),
      isOutgoing: true,
      text: trimmed,
      status: MessageStatus.sending,
    );
    await _ref.read(chatRepoProvider).saveMessage(msg);

    final bytes = utf8.encode('${msg.id}|$trimmed');
    bool sent = false;
    for (int attempt = 0; attempt < 3 && !sent; attempt++) {
      if (attempt > 0) await Future.delayed(const Duration(seconds: 2));
      try {
        await _ref
            .read(meshServiceProvider)
            .send(chatId, bytes)
            .timeout(const Duration(seconds: 10));
        await _ref
            .read(appDatabaseProvider)
            .updateMessageStatus(msg.id, MessageStatus.sent.index);
        sent = true;
      } catch (_) {}
    }
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
