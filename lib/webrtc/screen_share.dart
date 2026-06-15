// TODO: implement with flutter_webrtc MediaDevices.getDisplayMedia
abstract interface class ScreenShare {
  bool get isSharing;
  Future<void> startSharing();
  Future<void> stopSharing();
}
