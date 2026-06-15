import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract interface class FileStorage {
  Future<String> get downloadsDir;
  Future<String> get uploadsDir;
  Future<String> pathFor(String fileName, {bool isUpload = false});
}

class FileStorageImpl implements FileStorage {
  @override
  Future<String> get downloadsDir async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'transfers', 'downloads'));
    await dir.create(recursive: true);
    return dir.path;
  }

  @override
  Future<String> get uploadsDir async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'transfers', 'uploads'));
    await dir.create(recursive: true);
    return dir.path;
  }

  @override
  Future<String> pathFor(String fileName, {bool isUpload = false}) async {
    final base = isUpload ? await uploadsDir : await downloadsDir;
    return p.join(base, fileName);
  }
}
