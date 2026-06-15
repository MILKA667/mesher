import 'package:drift/drift.dart';

@DataClassName('ChatRow')
class Chats extends Table {
  TextColumn get id => text()();
  TextColumn get contactId => text()();
  TextColumn get displayName => text()();
  TextColumn get lastMessage => text().nullable()();
  DateTimeColumn get lastMessageTime => dateTime().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  BoolColumn get isGroup => boolean().withDefault(const Constant(false))();
  IntColumn get memberCount => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
