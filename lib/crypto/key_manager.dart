import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import '../data/local/secure_storage.dart';

abstract interface class KeyManager {
  Future<void> init();

  String get nodeId;

  List<int> get nodeIdBytes;
}

class KeyManagerImpl implements KeyManager {
  KeyManagerImpl(this._storage);
  final SecureStorage _storage;

  static const _kNodeId = 'node_id';

  static const _kLegacyPublic = 'node_ed25519_public';
  static const _kLegacyPrivate = 'node_ed25519_private';

  late Uint8List _bytes;

  @override
  Future<void> init() async {
    final stored = await _storage.read(_kNodeId);
    if (stored != null) {
      try {
        final decoded = base64Decode(stored);
        if (decoded.length == 8) {
          _bytes = decoded;
          return;
        }
      } catch (_) {}
    }

    final legacyPub = await _storage.read(_kLegacyPublic);
    if (legacyPub != null) {
      try {
        final pubBytes = base64Decode(legacyPub);
        if (pubBytes.length >= 8) {
          _bytes = Uint8List.fromList(pubBytes.take(8).toList());
          await _storage.write(_kNodeId, base64Encode(_bytes));
          await _storage.delete(_kLegacyPublic);
          await _storage.delete(_kLegacyPrivate);
          return;
        }
      } catch (_) {}
    }

    final rng = Random.secure();
    _bytes = Uint8List(8);
    for (var i = 0; i < 8; i++) {
      _bytes[i] = rng.nextInt(256);
    }
    await _storage.write(_kNodeId, base64Encode(_bytes));
  }

  @override
  String get nodeId => _bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join()
      .toUpperCase();

  @override
  List<int> get nodeIdBytes => _bytes;
}
