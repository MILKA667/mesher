import 'dart:async';
import 'package:flutter/services.dart';
import '../../core/constants.dart';

class BluetoothChannel {
  static const _cmd = MethodChannel(AppConstants.chBluetoothName);
  static const _peerEvents =
      EventChannel('${AppConstants.chBluetoothName}/peers');
  static const _rxEvents =
      EventChannel('${AppConstants.chBluetoothName}/rx');

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

  Future<void> setProfile(List<int> nodeIdBytes, String nickname) =>
      _cmd.invokeMethod<void>('setProfile', {
        'nodeIdBytes': Uint8List.fromList(nodeIdBytes),
        'nickname': nickname,
      });

  Future<void> startScan() async {
    await _cmd.invokeMethod<void>('startScan');
    _scanning = true;
  }

  Future<void> stopScan() async {
    await _cmd.invokeMethod<void>('stopScan');
    _scanning = false;
  }

  Future<void> connect(String nodeId) =>
      _cmd.invokeMethod<void>('connect', {'nodeId': nodeId});

  Future<void> disconnect(String nodeId) =>
      _cmd.invokeMethod<void>('disconnect', {'nodeId': nodeId});

  Future<void> send(String nodeId, List<int> data) =>
      _cmd.invokeMethod<void>(
          'send', {'nodeId': nodeId, 'data': Uint8List.fromList(data)});

  Future<void> registerPeer(String nodeId, String mac) =>
      _cmd.invokeMethod<void>('registerPeer', {'nodeId': nodeId, 'mac': mac});
}
