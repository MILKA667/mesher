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

  final _stateController = StreamController<CallState>.broadcast();
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  final _incomingController = StreamController<IncomingCallInfo>.broadcast();

  Stream<CallState> get stateStream => _stateController.stream;
  Stream<IncomingCallInfo> get incomingCallStream => _incomingController.stream;
  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  static const _pcConfig = {
    'iceServers': <Map>[], // local mesh — no STUN/TURN needed
  };

  Future<void> init() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  /// Start an outgoing call to [peerId].
  Future<void> startCall(String peerId) async {
    _remotePeerId = peerId;
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
    _remotePeerId = peerId;
    await _setupPeerConnection();
    _localStream = await navigator.mediaDevices
        .getUserMedia({'audio': true, 'video': true});
    for (final track in _localStream!.getTracks()) {
      await _pc!.addTrack(track, _localStream!);
    }
    _localRenderer.srcObject = _localStream;

    await _pc!.setRemoteDescription(
        RTCSessionDescription(sdpOffer['sdp'], sdpOffer['type']));
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

  /// Handle a received call signal packet. Called by MeshService.
  Future<void> handleSignal(String peerId, List<int> payload) async {
    if (payload.isEmpty) return;
    final signalType = payload[0];
    final jsonStr = utf8.decode(payload.sublist(1));
    final data = json.decode(jsonStr) as Map<String, dynamic>;

    switch (signalType) {
      case CallSignalType.offer:
        _incomingController.add(IncomingCallInfo(peerId: peerId, peerName: null));
        _stateController.add(CallState.incoming);
        // Store offer for answerCall
        _pendingOffer = (peerId, data);

      case CallSignalType.answer:
        if (_pc == null) return;
        await _pc!.setRemoteDescription(
            RTCSessionDescription(data['sdp'], data['type']));
        _stateController.add(CallState.connected);

      case CallSignalType.iceCandidate:
        if (_pc == null) return;
        await _pc!.addCandidate(RTCIceCandidate(
            data['candidate'], data['sdpMid'], data['sdpMLineIndex']));

      case CallSignalType.hangup:
        await _teardown();
        _stateController.add(CallState.ended);
    }
  }

  // Pending offer from remote while we haven't answered yet.
  (String, Map<String, dynamic>)? _pendingOffer;

  Future<void> acceptPendingCall() async {
    final p = _pendingOffer;
    if (p == null) return;
    _pendingOffer = null;
    await answerCall(p.$1, p.$2);
  }

  Future<void> _setupPeerConnection() async {
    _pc = await createPeerConnection(_pcConfig);

    _pc!.onIceCandidate = (candidate) {
      if (_remotePeerId == null) return;
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
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _stateController.add(CallState.ended);
      }
    };
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
    _localStream?.dispose();
    _localStream = null;
    await _pc?.close();
    _pc = null;
    _remotePeerId = null;
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
