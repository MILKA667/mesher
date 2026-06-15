import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import '../data/local/secure_storage.dart';

abstract interface class KeyManager {
  Future<void> init();

  String get nodeId; // первые 8 байт публичного ключа в HEX, напр. "7F2AE49C"
  List<int> get publicKeyBytes;

  Future<List<int>> sign(List<int> data);
  Future<bool> verify(
      List<int> data, List<int> signature, List<int> peerPublicKeyBytes);

  /// Ephemeral X25519 key pair для одной сессии.
  Future<({List<int> publicKey, List<int> privateKey})> generateSessionKeyPair();

  /// ECDH: вычислить общий секрет из нашего ephemeral private + их ephemeral public.
  Future<List<int>> computeSharedSecret(
      List<int> ourPrivateKey, List<int> theirPublicKey);
}

class KeyManagerImpl implements KeyManager {
  KeyManagerImpl(this._storage);
  final SecureStorage _storage;

  static const _kPrivate = 'node_ed25519_private';
  static const _kPublic = 'node_ed25519_public';

  late SimpleKeyPair _kp;
  late List<int> _publicBytes;

  final _ed = Ed25519();
  final _x25519 = X25519();

  @override
  Future<void> init() async {
    final stored = await _storage.read(_kPrivate);
    if (stored != null) {
      final seed = base64Decode(stored);
      _kp = await _ed.newKeyPairFromSeed(seed);
    } else {
      _kp = await _ed.newKeyPair();
      final seed = await _kp.extractPrivateKeyBytes();
      await _storage.write(_kPrivate, base64Encode(seed));
    }
    final pub = await _kp.extractPublicKey();
    _publicBytes = pub.bytes;
    await _storage.write(_kPublic, base64Encode(_publicBytes));
  }

  @override
  String get nodeId {
    final hex = _publicBytes
        .take(8)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
    return hex;
  }

  @override
  List<int> get publicKeyBytes => _publicBytes;

  @override
  Future<List<int>> sign(List<int> data) async {
    final sig = await _ed.sign(data, keyPair: _kp);
    return sig.bytes;
  }

  @override
  Future<bool> verify(
      List<int> data, List<int> signature, List<int> peerPublicKeyBytes) async {
    final pubKey = SimplePublicKey(peerPublicKeyBytes, type: KeyPairType.ed25519);
    final sig = Signature(signature, publicKey: pubKey);
    return _ed.verify(data, signature: sig);
  }

  @override
  Future<({List<int> publicKey, List<int> privateKey})>
      generateSessionKeyPair() async {
    final kp = await _x25519.newKeyPair();
    final pub = await kp.extractPublicKey();
    final priv = await kp.extractPrivateKeyBytes();
    return (publicKey: pub.bytes, privateKey: priv);
  }

  @override
  Future<List<int>> computeSharedSecret(
      List<int> ourPrivateKey, List<int> theirPublicKey) async {
    final kp = await _x25519.newKeyPairFromSeed(ourPrivateKey);
    final remotePub =
        SimplePublicKey(theirPublicKey, type: KeyPairType.x25519);
    final secret = await _x25519.sharedSecretKey(
        keyPair: kp, remotePublicKey: remotePub);
    return secret.extractBytes();
  }
}
