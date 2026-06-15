import 'key_manager.dart';

class Session {
  const Session({
    required this.peerId,
    required this.sharedKey,
    required this.sessionId,
    required this.establishedAt,
  });

  final String peerId;
  final List<int> sharedKey; // 32 bytes, AES-256 key
  final String sessionId;
  final DateTime establishedAt;
}

abstract interface class SessionManager {
  /// Start key-exchange: returns our ephemeral public key to send to peer.
  Future<List<int>> beginHandshake(String peerId);

  /// Finish key-exchange: got peer's ephemeral public key → create session.
  Future<Session> completeHandshake(String peerId, List<int> peerEphemeralPublic);

  bool hasPendingHandshake(String peerId);
  Session? getSession(String peerId);
  void removeSession(String peerId);
}

class SessionManagerImpl implements SessionManager {
  SessionManagerImpl(this._keys);
  final KeyManager _keys;

  final Map<String, List<int>> _pendingPrivate = {};
  final Map<String, Session> _sessions = {};

  @override
  Future<List<int>> beginHandshake(String peerId) async {
    final pair = await _keys.generateSessionKeyPair();
    _pendingPrivate[peerId] = pair.privateKey;
    return pair.publicKey;
  }

  @override
  Future<Session> completeHandshake(
      String peerId, List<int> peerEphemeralPublic) async {
    final ourPrivate = _pendingPrivate.remove(peerId);
    if (ourPrivate == null) throw StateError('No pending handshake for $peerId');

    final sharedKey =
        await _keys.computeSharedSecret(ourPrivate, peerEphemeralPublic);

    final sessionId = sharedKey
        .take(16)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    final session = Session(
      peerId: peerId,
      sharedKey: sharedKey,
      sessionId: sessionId,
      establishedAt: DateTime.now(),
    );
    _sessions[peerId] = session;
    return session;
  }

  @override
  bool hasPendingHandshake(String peerId) => _pendingPrivate.containsKey(peerId);

  @override
  Session? getSession(String peerId) => _sessions[peerId];

  @override
  void removeSession(String peerId) => _sessions.remove(peerId);
}
