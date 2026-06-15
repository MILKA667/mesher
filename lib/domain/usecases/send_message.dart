import '../models/message.dart';

abstract interface class SendMessage {
  Future<void> call({
    required String chatId,
    required MessageKind kind,
    String? text,
    String? filePath,
  });
}
