import 'package:drift/drift.dart';

@DataClassName('ReactionRow')
class Reactions extends Table {
  TextColumn get messageId => text()();
  TextColumn get chatId => text()();
  TextColumn get userId => text()(); // who reacted
  TextColumn get emoji => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {messageId, userId, emoji};
}
