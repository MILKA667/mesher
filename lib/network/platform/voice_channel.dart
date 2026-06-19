import 'dart:async';
import 'package:flutter/services.dart';

class VoiceChannel {
  static const _methods = MethodChannel('meshlink/voice');
  static const _frames = EventChannel('meshlink/voice/frames');

  Stream<Uint8List>? _frameStream;

  Stream<Uint8List> get captureStream {
    return _frameStream ??= _frames
        .receiveBroadcastStream()
        .map((event) => Uint8List.fromList(event as List<int>));
  }

  Future<void> startCapture() => _methods.invokeMethod<void>('startCapture');
  Future<void> stopCapture() => _methods.invokeMethod<void>('stopCapture');

  Future<void> startPlayback() => _methods.invokeMethod<void>('startPlayback');
  Future<void> stopPlayback() => _methods.invokeMethod<void>('stopPlayback');

  Future<void> playFrame(Uint8List bytes) =>
      _methods.invokeMethod<void>('playFrame', bytes);

  Future<void> setSpeakerOn(bool on) =>
      _methods.invokeMethod<void>('setSpeakerOn', on);
}
