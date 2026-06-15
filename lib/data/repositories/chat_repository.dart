import 'package:drift/drift.dart';
import '../../domain/models/chat.dart';
import '../../domain/models/message.dart';
import '../local/database/app_database.dart';

abstract interface class ChatRepository {
  Stream<List<Chat>> watchChats();
  Stream<List<Message>> watchMessages(String chatId);
  Future<void> saveMessage(Message message);
  Future<void> markRead(String chatId);
  Future<void> deleteChat(String chatId);
}

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._db);
  final AppDatabase _db;

  @override
  Stream<List<Chat>> watchChats() =>
      _db.watchChats().map((rows) => rows.map(AppDatabase.chatFromRow).toList());

  @override
  Stream<List<Message>> watchMessages(String chatId) =>
      _db.watchMessages(chatId).map((rows) =>
          rows.map(AppDatabase.messageFromRow).toList());

  @override
  Future<void> saveMessage(Message m) async {
    await _db.insertMessage(MessagesCompanion.insert(
      id: m.id,
      chatId: m.chatId,
      kind: m.kind.index,
      timestamp: m.timestamp,
      isOutgoing: m.isOutgoing,
      body: Value(m.text),
      filePath: Value(m.filePath),
      fileName: Value(m.fileName),
      fileSizeBytes: Value(m.fileSizeBytes),
      durationSeconds: Value(m.durationSeconds),
      status: Value(m.status.index),
    ));
    // Update chat preview
    await _db.upsertChat(ChatsCompanion(
      id: Value(m.chatId),
      contactId: const Value(''),
      displayName: const Value(''),
      lastMessage: Value(m.text ?? m.fileName ?? ''),
      lastMessageTime: Value(m.timestamp),
    ));
  }

  @override
  Future<void> markRead(String chatId) => _db.markChatRead(chatId);

  @override
  Future<void> deleteChat(String chatId) async {
    await ((_db.delete(_db.messages))
          ..where((t) => t.chatId.equals(chatId)))
        .go();
    await ((_db.delete(_db.chats))
          ..where((t) => t.id.equals(chatId)))
        .go();
  }
}
