import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService with WidgetsBindingObserver {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _tapController = StreamController<String>.broadcast();

  AppLifecycleState _lifecycle = AppLifecycleState.resumed;
  String? _activeChatId;
  bool _initialized = false;

  Stream<String> get onChatTap => _tapController.stream;

  void bindLifecycle() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
  }

  bool get isAppForeground => _lifecycle == AppLifecycleState.resumed;

  void setActiveChat(String? chatId) => _activeChatId = chatId;
  String? get activeChatId => _activeChatId;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.startsWith('chat:')) {
          _tapController.add(payload.substring(5));
        }
      },
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    await android?.createNotificationChannel(const AndroidNotificationChannel(
      'messages',
      'Сообщения',
      description: 'Новые входящие сообщения по mesh-сети',
      importance: Importance.high,
    ));
    await android?.createNotificationChannel(const AndroidNotificationChannel(
      'calls',
      'Входящие звонки',
      description: 'Голосовые звонки от пиров mesh-сети',
      importance: Importance.max,
    ));
  }

  Future<void> showMessage({
    required String chatId,
    required String sender,
    required String text,
  }) async {

    if (isAppForeground && _activeChatId == chatId) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'messages',
        'Сообщения',
        channelDescription: 'Новые входящие сообщения по mesh-сети',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.message,
        styleInformation: BigTextStyleInformation(''),
      ),
    );
    await _plugin.show(
      _chatNotificationId(chatId),
      sender,
      text,
      details,
      payload: 'chat:$chatId',
    );
  }

  Future<void> showCall({
    required String peerId,
    required String peerName,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'calls',
        'Входящие звонки',
        channelDescription: 'Голосовые звонки от пиров mesh-сети',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.call,
        fullScreenIntent: true,
        ongoing: true,
        autoCancel: false,
      ),
    );
    await _plugin.show(
      _callNotificationId,
      'Входящий звонок',
      peerName,
      details,
      payload: 'call:$peerId',
    );
  }

  Future<void> cancelCall() => _plugin.cancel(_callNotificationId);

  Future<void> cancelChat(String chatId) =>
      _plugin.cancel(_chatNotificationId(chatId));

  static int _chatNotificationId(String chatId) {
    int hash = 0;
    for (final code in chatId.codeUnits) {
      hash = (hash * 31 + code) & 0x7FFFFFFF;
    }
    return 100 + (hash % 0x7FFFFF00);
  }

  static const _callNotificationId = 1;

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tapController.close();
  }
}
