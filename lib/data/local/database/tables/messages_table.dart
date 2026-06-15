import 'package:drift/drift.dart';

@DataClassName('MessageRow')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text()();
  IntColumn get kind => integer()(); // MessageKind.index
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isOutgoing => boolean()();
  TextColumn get body => text().nullable()(); // message text content
  TextColumn get filePath => text().nullable()();
  TextColumn get fileName => text().nullable()();
  IntColumn get fileSizeBytes => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  IntColumn get status => integer().withDefault(const Constant(1))(); // MessageStatus.sent

  @override
  Set<Column> get primaryKey => {id};
}
