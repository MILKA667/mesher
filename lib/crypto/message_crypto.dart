import 'package:cryptography/cryptography.dart';

abstract interface class MessageCrypto {
  /// Encrypt plaintext. Returns nonce(12) + ciphertext + mac(16).
  Future<List<int>> encrypt(List<int> plaintext, List<int> sharedKey);

  /// Decrypt. Expects nonce(12) + ciphertext + mac(16).
  Future<List<int>> decrypt(List<int> ciphertext, List<int> sharedKey);
}

class MessageCryptoImpl implements MessageCrypto {
  final _aes = AesGcm.with256bits();

  SecretKey _toKey(List<int> bytes) => SecretKey(bytes);

  @override
  Future<List<int>> encrypt(List<int> plaintext, List<int> sharedKey) async {
    final box = await _aes.encrypt(plaintext, secretKey: _toKey(sharedKey));
    // Concatenation: nonce || cipherText || mac
    return [
      ...box.nonce,
      ...box.cipherText,
      ...box.mac.bytes,
    ];
  }

  @override
  Future<List<int>> decrypt(List<int> ciphertext, List<int> sharedKey) async {
    // Parse: nonce(12) || cipherText || mac(16)
    const nonceLen = 12;
    const macLen = 16;
    if (ciphertext.length < nonceLen + macLen) {
      throw const FormatException('Ciphertext too short');
    }
    final nonce = ciphertext.sublist(0, nonceLen);
    final mac = Mac(ciphertext.sublist(ciphertext.length - macLen));
    final body = ciphertext.sublist(nonceLen, ciphertext.length - macLen);
    final box = SecretBox(body, nonce: nonce, mac: mac);
    return _aes.decrypt(box, secretKey: _toKey(sharedKey));
  }
}
