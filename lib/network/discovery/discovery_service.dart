import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../../crypto/key_manager.dart';
import '../../data/local/secure_storage.dart';
import '../../domain/models/peer.dart';
import '../../domain/models/user_profile.dart';
import '../../network/protocol/packet.dart';
import '../../network/routing/mesh_router.dart';
import '../../network/transport/transport.dart';

abstract interface class DiscoveryService {
  Future<void> start();
  Future<void> stop();
  Stream<List<UserProfile>> get nearbyUsers;
  Future<void> updateOwnProfile({String? nickname, Uint8List? avatar});

  /// Returns the best transport nodeId to use when routing packets to [userId].
  /// Prefers an actively connected transport; falls back to any known mapping.
  /// Returns null if the userId has never been seen.
  String? resolveRouteId(String userId);
}

class DiscoveryServiceImpl implements DiscoveryService {
  DiscoveryServiceImpl({
    required KeyManager keys,
    required SecureStorage storage,
    required MeshRouter router,
    required List<Transport> transports,
  })  : _keys = keys,
        _storage = storage,
        _router = router,
        _transports = transports;

  final KeyManager _keys;
  final SecureStorage _storage;
  final MeshRouter _router;
  final List<Transport> _transports;

  static const _kNickname = 'profile_nickname';
  static const _kAvatar = 'profile_avatar';

  // userId → UserProfile
  final _profiles = <String, UserProfile>{};
  // transport nodeId → userId
  final _nodeToUser = <String, String>{};

  final _usersController = StreamController<List<UserProfile>>.broadcast();
  final _peerSubs = <StreamSubscription>[];
  StreamSubscription? _packetSub;
  bool _started = false;

  String? _ownNickname;
  Uint8List? _ownAvatar;

  @override
  Stream<List<UserProfile>> get nearbyUsers => _usersController.stream;

  @override
  Future<void> start() async {
    if (_started) return;
    _started = true;

    _ownNickname = await _storage.read(_kNickname);
    final avatarB64 = await _storage.read(_kAvatar);
    if (avatarB64 != null) {
      try {
        _ownAvatar = base64Decode(avatarB64);
      } catch (_) {}
    }

    for (final transport in _transports) {
      final sub = transport.discoveredNodes.listen((peers) {
        for (final peer in peers) {
          _onTransportPeer(peer);
        }
      });
      _peerSubs.add(sub);
    }

    _packetSub = _router.incomingPackets.listen(_handlePacket);
  }

  @override
  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    await _packetSub?.cancel();
    for (final sub in _peerSubs) {
      await sub.cancel();
    }
    _peerSubs.clear();
    _profiles.clear();
    _nodeToUser.clear();
  }

  @override
  Future<void> updateOwnProfile({String? nickname, Uint8List? avatar}) async {
    if (nickname != null) {
      _ownNickname = nickname;
      await _storage.write(_kNickname, nickname);
    }
    if (avatar != null) {
      _ownAvatar = avatar;
      await _storage.write(_kAvatar, base64Encode(avatar));
    }
  }

  @override
  String? resolveRouteId(String userId) {
    // Prefer a transport that reports itself as connected.
    for (final entry in _nodeToUser.entries) {
      if (entry.value == userId) {
        for (final t in _transports) {
          if (t.isConnected(entry.key)) return entry.key;
        }
      }
    }
    // Fall back to any known mapping even if not currently "connected".
    for (final entry in _nodeToUser.entries) {
      if (entry.value == userId) return entry.key;
    }
    return null;
  }

  void _onTransportPeer(Peer peer) {
    // BT advertises the crypto-derived userId directly.
    _nodeToUser[peer.nodeId] = peer.nodeId;
    _upsertTransportData(userId: peer.nodeId, peer: peer);

    // Send our own profile packet so the remote learns our nickname/avatar.
    _sendOwnProfile(peer.nodeId);
  }

  Future<void> _sendOwnProfile(String toNodeId) async {
    final payload = <String, dynamic>{
      'userId': _keys.nodeId,
      'nickname': _ownNickname ?? 'Node-${_keys.nodeId.substring(0, 4)}',
      'version': 1,
    };
    if (_ownAvatar != null) {
      payload['avatar'] = base64Encode(_ownAvatar!);
    }

    try {
      await _router.route(Packet(
        type: PacketType.profileAnnounce,
        senderId: _keys.nodeId,
        recipientId: toNodeId,
        payload: utf8.encode(jsonEncode(payload)),
      ));
    } catch (_) {
      // Transport not yet ready — the remote will re-trigger on next discovery.
    }
  }

  void _handlePacket(Packet packet) {
    if (packet.type != PacketType.profileAnnounce) return;
    try {
      final map = jsonDecode(utf8.decode(packet.payload)) as Map<String, dynamic>;
      final userId = map['userId'] as String;
      final nickname = map['nickname'] as String;
      final avatarB64 = map['avatar'] as String?;
      final avatar = avatarB64 != null ? base64Decode(avatarB64) : null;

      _nodeToUser[packet.senderId] = userId;

      final existing = _profiles[userId];
      _profiles[userId] = UserProfile(
        userId: userId,
        nickname: nickname,
        avatar: avatar ?? existing?.avatar,
        lastSeen: DateTime.now().millisecondsSinceEpoch,
        signalLevel: existing?.signalLevel ?? 0,
        distanceMeters: existing?.distanceMeters ?? 0,
        seenVia: existing?.seenVia ?? const {},
        isKnownContact: existing?.isKnownContact ?? false,
      );
      _emit();
    } catch (_) {
      // Malformed profile announce — ignore.
    }
  }

  void _upsertTransportData({
    required String userId,
    required Peer peer,
  }) {
    final existing = _profiles[userId];
    // Use advertisedName from BLE scan response if we don't have a confirmed nickname yet.
    final nickname = existing?.nickname ??
        peer.advertisedName ??
        'Node-${userId.substring(0, 4)}';
    _profiles[userId] = UserProfile(
      userId: userId,
      nickname: nickname,
      avatar: existing?.avatar,
      lastSeen: DateTime.now().millisecondsSinceEpoch,
      signalLevel: peer.signalLevel,
      distanceMeters: peer.distanceMeters,
      seenVia: {...(existing?.seenVia ?? const {}), peer.mode},
      isKnownContact: existing?.isKnownContact ?? false,
    );
    _emit();
  }

  void _emit() => _usersController.add(_profiles.values.toList());

  void dispose() {
    _packetSub?.cancel();
    for (final sub in _peerSubs) {
      sub.cancel();
    }
    _usersController.close();
  }
}
