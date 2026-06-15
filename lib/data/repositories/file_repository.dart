import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/file_transfer.dart';
import '../local/database/app_database.dart';

abstract interface class FileRepository {
  Stream<List<FileTransfer>> watchTransfers();
  Future<FileTransfer> createTransfer({
    required String name,
    required int sizeBytes,
    required TransferDirection direction,
    String? infoHash,
  });
  Future<void> updateProgress(String id, int percent, int speedBytesPerSec);
  Future<void> updateState(String id, TransferState state);
  Future<void> removeTransfer(String id);
}

class FileRepositoryImpl implements FileRepository {
  FileRepositoryImpl(this._db);
  final AppDatabase _db;

  @override
  Stream<List<FileTransfer>> watchTransfers() =>
      _db.watchTransfers().map((rows) =>
          rows.map(AppDatabase.transferFromRow).toList());

  @override
  Future<FileTransfer> createTransfer({
    required String name,
    required int sizeBytes,
    required TransferDirection direction,
    String? infoHash,
  }) async {
    final id = const Uuid().v4();
    final companion = FileTransfersCompanion.insert(
      id: id,
      name: name,
      sizeBytes: sizeBytes,
      direction: direction.index,
      state: TransferState.queued.index,
      infoHash: Value(infoHash),
    );
    await _db.upsertTransfer(companion);
    return FileTransfer(
      id: id,
      name: name,
      sizeBytes: sizeBytes,
      direction: direction,
      state: TransferState.queued,
      infoHash: infoHash,
    );
  }

  @override
  Future<void> updateProgress(String id, int percent, int speedBytesPerSec) =>
      _db.upsertTransfer(FileTransfersCompanion(
        id: Value(id),
        progressPercent: Value(percent),
        speedBytesPerSec: Value(speedBytesPerSec),
      ));

  @override
  Future<void> updateState(String id, TransferState state) =>
      _db.upsertTransfer(FileTransfersCompanion(
        id: Value(id),
        state: Value(state.index),
      ));

  @override
  Future<void> removeTransfer(String id) => _db.deleteTransfer(id);
}
