import '../models/file_transfer.dart';

abstract interface class DownloadFile {
  Stream<FileTransfer> call(String infoHash);
  Future<void> pause(String transferId);
  Future<void> resume(String transferId);
}
