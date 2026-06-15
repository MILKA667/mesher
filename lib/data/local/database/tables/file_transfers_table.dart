import 'package:drift/drift.dart';

@DataClassName('FileTransferRow')
class FileTransfers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get sizeBytes => integer()();
  IntColumn get direction => integer()(); // TransferDirection.index
  IntColumn get state => integer()(); // TransferState.index
  IntColumn get progressPercent => integer().withDefault(const Constant(0))();
  IntColumn get peerCount => integer().withDefault(const Constant(0))();
  IntColumn get speedBytesPerSec => integer().withDefault(const Constant(0))();
  TextColumn get infoHash => text().nullable()();
  TextColumn get localPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
