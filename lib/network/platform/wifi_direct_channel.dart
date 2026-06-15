import 'package:flutter/services.dart';
import '../../core/constants.dart';

class WifiDirectChannel {
  static const _cmd = MethodChannel(AppConstants.chWifiDirectName);
  static const _peerEvents =
      EventChannel('${AppConstants.chWifiDirectName}/peers');
  static const _rxEvents =
      EventChannel('${AppConstants.chWifiDirectName}/rx');

  bool _scanning = false;
  bool get isScanning => _scanning;

  Stream<Map<String, dynamic>> get peerStream => _peerEvents
      .receiveBroadcastStream()
      .map((e) => Map<String, dynamic>.from(e as Map));

  Stream<(String, List<int>)> get rxStream =>
      _rxEvents.receiveBroadcastStream().map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return (m['nodeId'] as String, List<int>.from(m['data'] as List));
      });

  Future<void> setNodeId(List<int> nodeIdBytes) =>
      _cmd.invokeMethod<void>('setNodeId',
          {'nodeIdBytes': Uint8List.fromList(nodeIdBytes)});

  Future<void> startScan() async {
    await _cmd.invokeMethod<void>('startScan');
    _scanning = true;
  }

  Future<void> stopScan() async {
    await _cmd.invokeMethod<void>('stopScan');
    _scanning = false;
  }

  Future<void> connect(String address) =>
      _cmd.invokeMethod<void>('connect', {'address': address});

  Future<void> disconnect(String address) =>
      _cmd.invokeMethod<void>('disconnect', {'address': address});

  Future<void> send(String nodeId, List<int> data) =>
      _cmd.invokeMethod<void>(
          'send', {'nodeId': nodeId, 'data': Uint8List.fromList(data)});
}
