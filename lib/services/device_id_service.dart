import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdService {
  static const _key = 'device_id_v1';

  Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) return existing;

    final id = '${DateTime.now().millisecondsSinceEpoch}${prefs.hashCode}';
    await prefs.setString(_key, id);
    return id;
  }
}


