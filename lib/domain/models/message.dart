enum MessageKind { text, file, voice, image }

enum MessageStatus { sending, sent, delivered, read }

class Message {
  const Message({
    required this.id,
    required this.chatId,
    required this.kind,
    required this.timestamp,
    required this.isOutgoing,
    this.text,
    this.filePath,
    this.fileName,
    this.fileSizeBytes,
    this.durationSeconds,
    this.status = MessageStatus.sent,
  });

  final String id;
  final String chatId;
  final MessageKind kind;
  final DateTime timestamp;
  final bool isOutgoing;
  final String? text;
  final String? filePath;
  final String? fileName;
  final int? fileSizeBytes;
  final int? durationSeconds;
  final MessageStatus status;
}
