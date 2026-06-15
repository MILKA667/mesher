import '../../../core/utils/hex.dart';
import '../../../domain/models/chat.dart';
import '../../../domain/models/contact.dart';
import '../../../domain/models/message.dart';

/// Flattened view model for a single chat list row.
/// Built in ChatsNotifier by joining Chat + Contact rows.
class ChatViewModel {
  const ChatViewModel({
    required this.id,
    required this.displayName,
    required this.nodeId,
    required this.lastMessage,
    required this.timeLabel,
    required this.unreadCount,
    required this.mode,
    required this.signalLevel,
    required this.isOnline,
    required this.isGroup,
    this.memberCount,
    this.lastMessageKind,
    this.lastMessageOutgoing = false,
    this.lastMessageStatus,
  });

  final String id;
  final String displayName;
  final String nodeId;   // formatted, e.g. "7F2A·E4"
  final String? lastMessage;
  final String timeLabel;
  final int unreadCount;
  final ConnectionMode mode;
  final int signalLevel;
  final bool isOnline;
  final bool isGroup;
  final int? memberCount;
  final MessageKind? lastMessageKind;
  final bool lastMessageOutgoing;
  final MessageStatus? lastMessageStatus;

  static ChatViewModel fromChat(Chat chat, {Contact? contact}) {
    final mode = contact?.mode ?? ConnectionMode.wifi;
    final signal = contact?.signalLevel ?? 0;
    final online = contact?.isOnline ?? false;
    final nodeId = contact != null
        ? formatNodeId(contact.nodeId)
        : '——·——·——';

    return ChatViewModel(
      id: chat.id,
      displayName: chat.displayName,
      nodeId: nodeId,
      lastMessage: chat.lastMessage,
      timeLabel: _formatTime(chat.lastMessageTime),
      unreadCount: chat.unreadCount,
      mode: mode,
      signalLevel: signal,
      isOnline: online,
      isGroup: chat.isGroup,
      memberCount: chat.memberCount,
    );
  }

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(msgDay).inDays;
    if (diff == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff == 1) {
      return 'Вчера';
    } else if (diff < 7) {
      const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
      return days[dt.weekday - 1];
    }
    return '${dt.day}.${dt.month}';
  }
}
