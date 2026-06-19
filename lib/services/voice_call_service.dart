import 'dart:async';
import 'dart:typed_data';

import '../crypto/key_manager.dart';
import '../network/platform/voice_channel.dart';
import '../network/protocol/packet.dart';
import '../network/routing/mesh_router.dart';

enum VoiceCallState { idle, dialing, ringing, active, ended }

class VoiceCallInfo {
  const VoiceCallInfo({required this.peerId, this.peerName});
  final String peerId;
  final String? peerName;
}

class VoiceCallService {
  VoiceCallService({
    required KeyManager keys,
    required MeshRouter router,
    VoiceChannel? voiceChannel,
  })  : _keys = keys,
        _router = router,
        _voice = voiceChannel ?? VoiceChannel();

  final KeyManager _keys;
  final MeshRouter _router;
  final VoiceChannel _voice;

  String? _peerId;
  String? _peerName;
  VoiceCallState _state = VoiceCallState.idle;
  bool _speakerOn = false;
  bool _micMuted = false;

  StreamSubscription? _packetSub;
  StreamSubscription? _captureSub;

  final _stateController = StreamController<VoiceCallState>.broadcast();
  final _incomingController = StreamController<VoiceCallInfo>.broadcast();

  Stream<VoiceCallState> get stateStream => _stateController.stream;
  Stream<VoiceCallInfo> get incomingCallStream => _incomingController.stream;

  VoiceCallState get currentState => _state;
  String? get peerId => _peerId;
  String? get peerName => _peerName;
  bool get isSpeakerOn => _speakerOn;
  bool get isMicMuted => _micMuted;

  void bind() {
    _packetSub ??= _router.incomingPackets.listen(_handlePacket);
  }

  Future<void> startCall(String peerId, {String? peerName}) async {
    if (_state != VoiceCallState.idle && _state != VoiceCallState.ended) {
      return;
    }
    _peerId = peerId;
    _peerName = peerName;
    _setState(VoiceCallState.dialing);
    await _router.route(Packet(
      type: PacketType.voiceCallOffer,
      senderId: _keys.nodeId,
      recipientId: peerId,
      payload: const [],
    ));
  }

  Future<void> acceptCall() async {
    if (_state != VoiceCallState.ringing || _peerId == null) return;
    await _router.route(Packet(
      type: PacketType.voiceCallAccept,
      senderId: _keys.nodeId,
      recipientId: _peerId,
      payload: const [],
    ));
    await _startAudio();
    _setState(VoiceCallState.active);
  }

  Future<void> rejectCall() async {
    if (_peerId != null) {
      await _router.route(Packet(
        type: PacketType.voiceCallReject,
        senderId: _keys.nodeId,
        recipientId: _peerId,
        payload: const [],
      ));
    }
    await _teardown();
  }

  Future<void> hangup() async {
    if (_peerId != null) {
      await _router.route(Packet(
        type: PacketType.voiceCallHangup,
        senderId: _keys.nodeId,
        recipientId: _peerId,
        payload: const [],
      ));
    }
    await _teardown();
  }

  Future<void> toggleSpeaker() async {
    _speakerOn = !_speakerOn;
    await _voice.setSpeakerOn(_speakerOn);
  }

  Future<void> toggleMute() async {
    _micMuted = !_micMuted;

  }

  void _setState(VoiceCallState s) {
    _state = s;
    _stateController.add(s);
  }

  Future<void> _handlePacket(Packet packet) async {
    switch (packet.type) {
      case PacketType.voiceCallOffer:

        if (_state == VoiceCallState.active ||
            _state == VoiceCallState.dialing) {
          await _router.route(Packet(
            type: PacketType.voiceCallReject,
            senderId: _keys.nodeId,
            recipientId: packet.senderId,
            payload: const [],
          ));
          return;
        }
        _peerId = packet.senderId;
        _setState(VoiceCallState.ringing);
        _incomingController
            .add(VoiceCallInfo(peerId: packet.senderId, peerName: _peerName));

      case PacketType.voiceCallAccept:
        if (_state != VoiceCallState.dialing) return;
        await _startAudio();
        _setState(VoiceCallState.active);

      case PacketType.voiceCallReject:
        await _teardown();

      case PacketType.voiceCallHangup:
        await _teardown();

      case PacketType.voiceCallFrame:
        if (_state == VoiceCallState.active && packet.payload.isNotEmpty) {
          await _voice.playFrame(Uint8List.fromList(packet.payload));
        }

      default:
        break;
    }
  }

  Future<void> _startAudio() async {
    await _voice.startPlayback();
    await _voice.startCapture();
    _captureSub = _voice.captureStream.listen((frame) {
      if (_micMuted || _peerId == null) return;
      _router.route(Packet(
        type: PacketType.voiceCallFrame,
        senderId: _keys.nodeId,
        recipientId: _peerId,
        payload: frame,
      ));
    });
  }

  Future<void> _teardown() async {
    await _captureSub?.cancel();
    _captureSub = null;
    try { await _voice.stopCapture(); } catch (_) {}
    try { await _voice.stopPlayback(); } catch (_) {}
    _peerId = null;
    _peerName = null;
    _speakerOn = false;
    _micMuted = false;
    _setState(VoiceCallState.ended);
  }

  Future<void> dispose() async {
    await _packetSub?.cancel();
    await _teardown();
    await _stateController.close();
    await _incomingController.close();
  }
}
