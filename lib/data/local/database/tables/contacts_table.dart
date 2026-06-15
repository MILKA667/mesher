import 'package:drift/drift.dart';

@DataClassName('ContactRow')
class Contacts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nodeId => text()();
  BlobColumn get publicKey => blob()();
  IntColumn get mode => integer().withDefault(const Constant(1))(); // ConnectionMode.index
  IntColumn get signalLevel => integer().withDefault(const Constant(0))();
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();
  IntColumn get distanceMeters => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
