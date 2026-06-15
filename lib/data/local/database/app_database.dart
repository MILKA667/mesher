import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../../../domain/models/chat.dart' as domain;
import '../../../domain/models/contact.dart' as domain;
import '../../../domain/models/message.dart' as domain;
import '../../../domain/models/file_transfer.dart' as domain;
import 'tables/contacts_table.dart';
import 'tables/chats_table.dart';
import 'tables/messages_table.dart';
import 'tables/file_transfers_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Contacts, Chats, Messages, FileTransfers])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() =>
      driftDatabase(name: 'mesher_db');

  // ── Contacts ──────────────────────────────────────────────────────────────

  Stream<List<ContactRow>> watchContacts() => select(contacts).watch();

  Future<ContactRow?> findContact(String id) =>
      (select(contacts)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertContact(ContactsCompanion c) =>
      into(contacts).insertOnConflictUpdate(c);

  Future<int> deleteContact(String id) =>
      (delete(contacts)..where((t) => t.id.equals(id))).go();

  // ── Chats ─────────────────────────────────────────────────────────────────

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

  /// Returns chatId (= nodeId) for a 1:1 chat, creating it if it doesn't exist.
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

  // ── Messages ──────────────────────────────────────────────────────────────

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

  // ── FileTransfers ─────────────────────────────────────────────────────────

  Stream<List<FileTransferRow>> watchTransfers() =>
      select(fileTransfers).watch();

  Future<void> upsertTransfer(FileTransfersCompanion c) =>
      into(fileTransfers).insertOnConflictUpdate(c);

  Future<int> deleteTransfer(String id) =>
      (delete(fileTransfers)..where((t) => t.id.equals(id))).go();

  // ── Domain mappers ────────────────────────────────────────────────────────

  static domain.Contact contactFromRow(ContactRow r) => domain.Contact(
        id: r.id,
        name: r.name,
        nodeId: r.nodeId,
        mode: domain.ConnectionMode.values[r.mode],
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

  static domain.FileTransfer transferFromRow(FileTransferRow r) =>
      domain.FileTransfer(
        id: r.id,
        name: r.name,
        sizeBytes: r.sizeBytes,
        direction: domain.TransferDirection.values[r.direction],
        state: domain.TransferState.values[r.state],
        progressPercent: r.progressPercent,
        peerCount: r.peerCount,
        speedBytesPerSec: r.speedBytesPerSec,
        infoHash: r.infoHash,
      );
}
