import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../../../domain/models/chat.dart' as domain;
import '../../../domain/models/contact.dart' as domain;
import '../../../domain/models/message.dart' as domain;
import '../../../domain/models/reaction.dart' as domain;
import 'tables/contacts_table.dart';
import 'tables/chats_table.dart';
import 'tables/messages_table.dart';
import 'tables/reactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Contacts, Chats, Messages, Reactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(reactions);
          }
          if (from < 3) {
            await customStatement('DROP TABLE IF EXISTS file_transfers');
          }
        },
      );

  static QueryExecutor _openConnection() =>
      driftDatabase(name: 'mesher_db');

  Stream<List<ContactRow>> watchContacts() => select(contacts).watch();

  Future<ContactRow?> findContact(String id) =>
      (select(contacts)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertContact(ContactsCompanion c) =>
      into(contacts).insertOnConflictUpdate(c);

  Future<int> deleteContact(String id) =>
      (delete(contacts)..where((t) => t.id.equals(id))).go();

  Stream<List<ChatRow>> watchChats() => (select(chats)
        ..orderBy([(t) => OrderingTerm.desc(t.lastMessageTime)]))
      .watch();

  Future<ChatRow?> findChat(String id) =>
      (select(chats)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertChat(ChatsCompanion c) =>
      into(chats).insertOnConflictUpdate(c);

  Future<void> markChatRead(String chatId) => (update(chats)
        ..where((t) => t.id.equals(chatId)))
      .write(const ChatsCompanion(unreadCount: Value(0)));

  Future<void> updateChatPreview({
    required String chatId,
    required String lastMessage,
    required DateTime lastMessageTime,
  }) async {
    final updated = await (update(chats)..where((t) => t.id.equals(chatId)))
        .write(ChatsCompanion(
      lastMessage: Value(lastMessage),
      lastMessageTime: Value(lastMessageTime),
    ));

    if (updated == 0) {
      await into(chats).insert(ChatsCompanion.insert(
        id: chatId,
        contactId: chatId,
        displayName: chatId.length >= 8 ? chatId.substring(0, 8) : chatId,
        lastMessage: Value(lastMessage),
        lastMessageTime: Value(lastMessageTime),
      ));
    }
  }

  Future<String> getOrCreateChat({
    required String nodeId,
    required String displayName,
  }) async {
    final existing = await findChat(nodeId);
    if (existing != null) return nodeId;
    await upsertChat(ChatsCompanion.insert(
      id: nodeId,
      contactId: nodeId,
      displayName: displayName,
      lastMessage: const Value(''),
      lastMessageTime: Value(DateTime.now()),
    ));
    return nodeId;
  }

  Stream<List<MessageRow>> watchMessages(String chatId) =>
      (select(messages)
            ..where((t) => t.chatId.equals(chatId))
            ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
          .watch();

  Future<void> insertMessage(MessagesCompanion m) =>
      into(messages).insert(m);

  Future<void> updateMessageStatus(String messageId, int status) =>
      (update(messages)..where((t) => t.id.equals(messageId)))
          .write(MessagesCompanion(status: Value(status)));

  Future<void> incrementUnread(String chatId) => customUpdate(
        'UPDATE chats SET unread_count = unread_count + 1 WHERE id = ?',
        variables: [Variable(chatId)],
        updates: {chats},
      );

  Future<void> markOutgoingMessagesRead(String chatId) => customUpdate(
        'UPDATE messages SET status = ? WHERE chat_id = ? AND is_outgoing = 1',
        variables: [Variable(domain.MessageStatus.read.index), Variable(chatId)],
        updates: {messages},
      );

  Stream<List<ReactionRow>> watchReactionsForChat(String chatId) =>
      (select(reactions)..where((t) => t.chatId.equals(chatId))).watch();

  Future<void> upsertReaction(ReactionsCompanion r) =>
      into(reactions).insertOnConflictUpdate(r);

  Future<void> deleteReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) =>
      (delete(reactions)
            ..where((t) =>
                t.messageId.equals(messageId) &
                t.userId.equals(userId) &
                t.emoji.equals(emoji)))
          .go();

  static domain.Contact contactFromRow(ContactRow r) => domain.Contact(
        id: r.id,
        name: r.name,
        nodeId: r.nodeId,

        mode: r.mode < domain.ConnectionMode.values.length
            ? domain.ConnectionMode.values[r.mode]
            : domain.ConnectionMode.bluetooth,
        signalLevel: r.signalLevel,
        isOnline: r.isOnline,
        distanceMeters: r.distanceMeters,
      );

  static domain.Chat chatFromRow(ChatRow r) => domain.Chat(
        id: r.id,
        contactId: r.contactId,
        displayName: r.displayName,
        lastMessage: r.lastMessage,
        lastMessageTime: r.lastMessageTime,
        unreadCount: r.unreadCount,
        isGroup: r.isGroup,
        memberCount: r.memberCount,
      );

  static domain.Message messageFromRow(MessageRow r) => domain.Message(
        id: r.id,
        chatId: r.chatId,
        kind: domain.MessageKind.values[r.kind],
        timestamp: r.timestamp,
        isOutgoing: r.isOutgoing,
        text: r.body,
        filePath: r.filePath,
        fileName: r.fileName,
        fileSizeBytes: r.fileSizeBytes,
        durationSeconds: r.durationSeconds,
        status: domain.MessageStatus.values[r.status],
      );

  static domain.Reaction reactionFromRow(ReactionRow r) => domain.Reaction(
        messageId: r.messageId,
        chatId: r.chatId,
        userId: r.userId,
        emoji: r.emoji,
        createdAt: r.createdAt,
      );
}
