// TODO: implement with flutter_webrtc
// Manages P2P video/audio calls over the mesh transport.
//
// Flow:
//   caller → sendOffer → peer
//   peer   → sendAnswer → caller
//   both   → exchangeIceCandidates (via mesh)
//   → RTCPeerConnection established

abstract interface class CallManager {
  Future<void> startCall(String peerId);
  Future<void> answerCall(String peerId, String offerSdp);
  Future<void> endCall(String peerId);

  Stream<CallEvent> get events;

  bool get isMuted;
  bool get isCameraOff;
  Future<void> setMuted(bool muted);
  Future<void> setCameraOff(bool off);
}

sealed class CallEvent {}

class CallStarted extends CallEvent {
  CallStarted(this.peerId);
  final String peerId;
}

class CallEnded extends CallEvent {
  CallEnded(this.peerId);
  final String peerId;
}

class CallFailed extends CallEvent {
  CallFailed(this.peerId, this.reason);
  final String peerId;
  final String reason;
}
