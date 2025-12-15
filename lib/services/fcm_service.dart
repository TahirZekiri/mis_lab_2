import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FcmService {
  final NotificationService _notifications;

  FcmService(this._notifications);

  Future<void> init({
    required Future<void> Function(String payload) onOpen,
  }) async {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) async {
      final title = message.notification?.title ?? 'Recipe App';
      final body = message.notification?.body ?? 'Open the app';
      final payload = _payloadFromMessage(message) ?? 'random';
      await _notifications.show(id: DateTime.now().millisecondsSinceEpoch ~/ 1000, title: title, body: body, payload: payload);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      final payload = _payloadFromMessage(message);
      if (payload == null || payload.isEmpty) return;
      await onOpen(payload);
    });

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      final payload = _payloadFromMessage(initial);
      if (payload != null && payload.isNotEmpty) {
        await onOpen(payload);
      }
    }
  }

  String? _payloadFromMessage(RemoteMessage message) {
    final data = message.data;
    final mealId = data['mealId']?.toString();
    if (mealId != null && mealId.isNotEmpty) return 'meal:$mealId';
    final type = data['type']?.toString();
    if (type == 'random') return 'random';
    final payload = data['payload']?.toString();
    return payload;
  }
}


