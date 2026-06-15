import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

class SecureStorageImpl implements SecureStorage {
  static const _android = AndroidOptions(encryptedSharedPreferences: true);
  final _s = const FlutterSecureStorage(aOptions: _android);

  @override
  Future<void> write(String key, String value) =>
      _s.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _s.read(key: key);

  @override
  Future<void> delete(String key) => _s.delete(key: key);

  @override
  Future<void> deleteAll() => _s.deleteAll();
}
