import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/reminder_settings_service.dart';

class ReminderSettingsScreen extends StatelessWidget {
  static const routeName = '/reminder-settings';

  const ReminderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder settings'),
      ),
      body: SafeArea(
        child: Consumer<ReminderSettingsService>(
          builder: (context, settings, _) {
            final timeText =
                '${settings.hour.toString().padLeft(2, '0')}:${settings.minute.toString().padLeft(2, '0')}';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Daily reminder time'),
                  subtitle: Text(timeText),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: settings.hour, minute: settings.minute),
                    );
                    if (picked == null) return;
                    await settings.setTime(hour: picked.hour, minute: picked.minute);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reminder time updated')),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


