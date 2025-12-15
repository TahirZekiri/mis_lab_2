import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

class ReminderSettingsService extends ChangeNotifier {
  static const _hourKey = 'reminder_hour';
  static const _minuteKey = 'reminder_minute';

  final NotificationService _notifications;

  int _hour = 20;
  int _minute = 0;

  ReminderSettingsService(this._notifications);

  int get hour => _hour;
  int get minute => _minute;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _hour = prefs.getInt(_hourKey) ?? _hour;
    _minute = prefs.getInt(_minuteKey) ?? _minute;
    notifyListeners();
  }

  Future<void> setTime({
    required int hour,
    required int minute,
  }) async {
    _hour = hour;
    _minute = minute;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey, _hour);
    await prefs.setInt(_minuteKey, _minute);

    await _notifications.scheduleDailyRandomReminder(hour: _hour, minute: _minute);
  }

  Future<void> scheduleDaily() async {
    await _notifications.scheduleDailyRandomReminder(hour: _hour, minute: _minute);
  }
}


