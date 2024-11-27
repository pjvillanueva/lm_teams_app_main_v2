import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async' show Future;

class PreferenceUtils {
  static Future<SharedPreferences> get _instance async =>
      _prefsInstance ??= await SharedPreferences.getInstance();
  static SharedPreferences? _prefsInstance;

  Future<SharedPreferences> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance!;
  }

  void saveData(String key, dynamic value) async {
    try {
      if (value is int) {
        _prefsInstance!.setInt(key, value);
      } else if (value is String) {
        _prefsInstance!.setString(key, value);
      } else if (value is bool) {
        _prefsInstance!.setBool(key, value);
      } else {
        print("Storage: Invalid Type");
      }
    } catch (e) {
      print('PreferenceUtils saveData error: $e');
    }
  }

  //get dynamic data
  Future<dynamic> readData(String key) async {
    try {
      return _prefsInstance!.get(key);
    } catch (e) {
      print(e);
      return null;
    }
  }

  //get string data
  Future<String?> getString(String key) async {
    try {
      return _prefsInstance!.getString(key);
    } catch (e) {
      print(e);
      return null;
    }
  }

//get int data
  Future<int?> getInt(String key) async {
    try {
      return _prefsInstance!.getInt(key);
    } catch (e) {
      print(e);
      return null;
    }
  }

//get bool data
  Future<bool?> getBool(String key) async {
    try {
      return _prefsInstance!.getBool(key);
    } catch (e) {
      print(e);
      return null;
    }
  }

//delete data
  Future<bool> deleteData(String key) async {
    try {
      return _prefsInstance!.remove(key);
    } catch (e) {
      print(e);
      return false;
    }
  }

//check if storage contains key
  Future<bool> containsKey(String key) async {
    try {
      return _prefsInstance!.containsKey(key);
    } catch (e) {
      print(e);
      return false;
    }
  }
}
