
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  SharedPreferences? _prefs;

  // Initialize the SharedPreferences instance
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Write data to shared preferences
  Future<void> setData(String key, dynamic value) async {
    if (_prefs == null) {
      await init();
    }

    if (value is String) {
      _prefs!.setString(key, value);
    } else if (value is int) {
      _prefs!.setInt(key, value);
    } else if (value is double) {
      _prefs!.setDouble(key, value);
    } else if (value is bool) {
      _prefs!.setBool(key, value);
    } else {
      throw ArgumentError('Unsupported value type: ${value.runtimeType}');
    }
  }

  // Read data from shared preferences

  Future<T?> getData<T>(String key) async {
    if (_prefs == null) {
      await init();
    }

    // Use type checking to return the appropriate data based on T
    if (T == String) {
      return _prefs!.getString(key) as T?;
    } else if (T == bool) {
      return _prefs!.getBool(key) as T?;
    } else if (T == int) {
      return _prefs!.getInt(key) as T?;
    } else if (T == double) {
      return _prefs!.getDouble(key) as T?;
    } else {
      throw ArgumentError('Unsupported type: $T');
    }
  }

}
