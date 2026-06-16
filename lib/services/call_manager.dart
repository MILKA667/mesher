import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../network/protocol/packet.dart';
import '../network/routing/mesh_router.dart';
import '../crypto/key_manager.dart';

enum CallState { idle, calling, incoming, connected, ended }

class CallSignalType {
  static const offer = 0;
  static const answer = 1;
  static const iceCandidate = 2;
  static const hangup = 3;
}

class IncomingCallInfo {
  const IncomingCallInfo({required this.peerId, required this.peerName});
  final String peerId;
  final String? peerName;
}

class CallManager {
  CallManager({required KeyManager keys, required MeshRouter router})
      : _keys = keys,
        _router = router;

  final KeyManager _keys;
  final MeshRouter _router;

  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  String? _remotePeerId;
  bool _renderersReady = false;
  bool _remoteDescriptionSet = false;
  final _pendingCandidates = <RTCIceCandidate>[];

  final _stateController = StreamController<CallState>.broadcast();
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  final _incomingController = StreamController<IncomingCallInfo>.broadcast();

  Stream<CallState> get stateStream => _stateController.stream;
  Stream<IncomingCallInfo> get incomingCallStream => _incomingController.stream;
  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  // Pending offer received before user accepts.
  (String, Map<String, dynamic>)? _pendingOffer;

  // Configuration: local-mesh only, but include public STUN as fallback when
  // peers happen to share a LAN/internet route (helps WiFi Direct group owners).
  static const _pcConfig = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };

  Future<void> init() async {
    if (_renderersReady) return;
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    _renderersReady = true;
  }

  /// Start an outgoing call to [peerId].
  Future<void> startCall(String peerId) async {
    await init();
    _remotePeerId = peerId;
    _remoteDescriptionSet = false;
    _pendingCandidates.clear();
    await _setupPeerConnection();
    _localStream = await navigator.mediaDevices
        .getUserMedia({'audio': true, 'video': true});
    for (final track in _localStream!.getTracks()) {
      await _pc!.addTrack(track, _localStream!);
    }
    _localRenderer.srcObject = _localStream;

    final offer = await _pc!.createOffer();
    await _pc!.setLocalDescription(offer);
    _sendSignal(peerId, CallSignalType.offer, offer.toMap());
    _stateController.add(CallState.calling);
  }

  /// Accept an incoming call. [sdpOffer] is the remote SDP offer map.
  Future<void> answerCall(String peerId, Map<String, dynamic> sdpOffer) async {
    await init();
    _remotePeerId = peerId;
    _remoteDescriptionSet = false;
    await _setupPeerConnection();
    _localStream = await navigator.mediaDevices
        .getUserMedia({'audio': true, 'video': true});
    for (final track in _localStream!.getTracks()) {
      await _pc!.addTrack(track, _localStream!);
    }
    _localRenderer.srcObject = _localStream;

    await _pc!.setRemoteDescription(
        RTCSessionDescription(sdpOffer['sdp'], sdpOffer['type']));
    _remoteDescriptionSet = true;
    await _drainPendingCandidates();
    final answer = await _pc!.createAnswer();
    await _pc!.setLocalDescription(answer);
    _sendSignal(peerId, CallSignalType.answer, answer.toMap());
    _stateController.add(CallState.connected);
  }

  /// End the current call.
  Future<void> endCall() async {
    if (_remotePeerId != null) {
      _sendSignal(_remotePeerId!, CallSignalType.hangup, {});
    }
    await _teardown();
    _stateController.add(CallState.ended);
  }

  /// Mute/unmute the local microphone.
  void setMicEnabled(bool enabled) {
    final tracks = _localStream?.getAudioTracks() ?? const [];
    for (final t in tracks) {
      t.enabled = enabled;
    }
  }

  /// Enable/disable the local camera.
  void setCameraEnabled(bool enabled) {
    final tracks = _localStream?.getVideoTracks() ?? const [];
    for (final t in tracks) {
      t.enabled = enabled;
    }
  }

  /// Switch between front and rear camera.
  Future<void> switchCamera() async {
    final tracks = _localStream?.getVideoTracks() ?? const [];
    if (tracks.isEmpty) return;
    try {
      await Helper.switchCamera(tracks.first);
    } catch (_) {}
  }

  /// Handle a received call signal packet. Called by message handler.
  Future<void> handleSignal(
    String peerId,
    List<int> payload, {
    String Function()? resolveName,
  }) async {
    if (payload.isEmpty) return;
    final signalType = payload[0];
    final jsonStr = utf8.decode(payload.sublist(1));
    final data = jsonStr.isEmpty
        ? <String, dynamic>{}
        : json.decode(jsonStr) as Map<String, dynamic>;

    switch (signalType) {
      case CallSignalType.offer:
        _pendingOffer = (peerId, data);
        _pendingCandidates.clear();
        _remoteDescriptionSet = false;
        _stateController.add(CallState.incoming);
        _incomingController.add(IncomingCallInfo(
          peerId: peerId,
          peerName: resolveName?.call(),
        ));

      case CallSignalType.answer:
        if (_pc == null) return;
        await _pc!.setRemoteDescription(
            RTCSessionDescription(data['sdp'], data['type']));
        _remoteDescriptionSet = true;
        await _drainPendingCandidates();
        _stateController.add(CallState.connected);

      case CallSignalType.iceCandidate:
        final candidate = RTCIceCandidate(
            data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
        if (_pc != null && _remoteDescriptionSet) {
          await _pc!.addCandidate(candidate);
        } else {
          _pendingCandidates.add(candidate);
        }

      case CallSignalType.hangup:
        await _teardown();
        _stateController.add(CallState.ended);
    }
  }

  Future<void> acceptPendingCall() async {
    final p = _pendingOffer;
    if (p == null) return;
    _pendingOffer = null;
    await answerCall(p.$1, p.$2);
  }

  void rejectPendingCall() {
    final p = _pendingOffer;
    _pendingOffer = null;
    if (p != null) {
      _sendSignal(p.$1, CallSignalType.hangup, {});
    }
    _stateController.add(CallState.ended);
  }

  Future<void> _setupPeerConnection() async {
    _pc = await createPeerConnection(_pcConfig);

    _pc!.onIceCandidate = (candidate) {
      if (_remotePeerId == null) return;
      if (candidate.candidate == null) return;
      _sendSignal(_remotePeerId!, CallSignalType.iceCandidate, candidate.toMap());
    };

    _pc!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams.first;
      }
    };

    _pc!.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _stateController.add(CallState.connected);
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _stateController.add(CallState.ended);
      }
    };
  }

  Future<void> _drainPendingCandidates() async {
    if (_pc == null || !_remoteDescriptionSet) return;
    for (final c in _pendingCandidates) {
      await _pc!.addCandidate(c);
    }
    _pendingCandidates.clear();
  }

  void _sendSignal(String peerId, int signalType, Map<String, dynamic> data) {
    final jsonBytes = utf8.encode(json.encode(data));
    final payload = [signalType, ...jsonBytes];
    _router.route(Packet(
      type: PacketType.callSignal,
      senderId: _keys.nodeId,
      recipientId: peerId,
      payload: payload,
    ));
  }

  Future<void> _teardown() async {
    _localStream?.getTracks().forEach((t) => t.stop());
    await _localStream?.dispose();
    _localStream = null;
    await _pc?.close();
    _pc = null;
    _remotePeerId = null;
    _remoteDescriptionSet = false;
    _pendingCandidates.clear();
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
  }

  void dispose() {
    _teardown();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _stateController.close();
    _incomingController.close();
  }
}
