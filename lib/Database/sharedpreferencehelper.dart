import 'package:shared_preferences/shared_preferences.dart';


enum PrefKey {
  currencySymbol,
  pin,
  password,
}


class SharedPreferenceHelper {
  static Future<void> save({
    required String value,
    required PrefKey prefKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(prefKey.name, value);
  }

  static Future<String?> get({required PrefKey prefKey}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(prefKey.name);
  }
}