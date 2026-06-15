import 'package:flutter/services.dart';
import '../../core/constants.dart';

class HotspotChannel {
  static const _cmd = MethodChannel(AppConstants.chHotspotName);
  static const _rxEvents =
      EventChannel('${AppConstants.chHotspotName}/rx');

  bool _active = false;
  bool get isActive => _active;

  Stream<(String, List<int>)> get rxStream =>
      _rxEvents.receiveBroadcastStream().map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return (m['nodeId'] as String, List<int>.from(m['data'] as List));
      });

  Future<void> startHotspot() async {
    await _cmd.invokeMethod<void>('startHotspot');
    _active = true;
  }

  Future<void> stopHotspot() async {
    await _cmd.invokeMethod<void>('stopHotspot');
    _active = false;
  }

  Future<void> send(String nodeId, List<int> data) =>
      _cmd.invokeMethod<void>(
          'send', {'nodeId': nodeId, 'data': Uint8List.fromList(data)});
}
