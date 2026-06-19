import 'package:flutter/services.dart';

abstract interface class ForegroundService {
  Future<void> start({required String notificationTitle});
  Future<void> stop();
  bool get isRunning;
}

class AndroidForegroundService implements ForegroundService {
  static const _ch = MethodChannel('meshlink/foreground');

  bool _running = false;

  @override
  bool get isRunning => _running;

  @override
  Future<void> start({required String notificationTitle}) async {
    await _ch.invokeMethod('start', {'title': notificationTitle});
    _running = true;
  }

  @override
  Future<void> stop() async {
    await _ch.invokeMethod('stop');
    _running = false;
  }
}
