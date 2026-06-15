class Chat {
  const Chat({
    required this.id,
    required this.contactId,
    required this.displayName,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isGroup = false,
    this.memberCount,
  });

  final String id;
  final String contactId;
  final String displayName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isGroup;
  final int? memberCount;
}
