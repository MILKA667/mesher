class Reaction {
  const Reaction({
    required this.messageId,
    required this.chatId,
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  final String messageId;
  final String chatId;
  final String userId;
  final String emoji;
  final DateTime createdAt;
}
