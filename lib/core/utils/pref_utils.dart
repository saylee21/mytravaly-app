import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  PrefUtils() {
    SharedPreferences.getInstance().then((value) {
      _sharedPreferences = value;
    });
  }

  static SharedPreferences? _sharedPreferences;

  Future<void> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    print('SharedPreference Initialized');
  }

  /// Will clear all the data stored in preference
  void clearPreferencesData() async {
    _sharedPreferences!.clear();
  }

  // ── VISITOR TOKEN ──
  Future<void> setVisitorToken(String value) {
    return _sharedPreferences!.setString('visitortoken', value);
  }

  String getVisitorToken() {
    try {
      return _sharedPreferences!.getString('visitortoken') ?? '';
    } catch (e) {
      return '';
    }
  }

  // ── DEVICE REGISTRATION FLAG ──
  /// Check if device is already registered
  bool isDeviceRegistered() {
    try {
      return _sharedPreferences!.getBool('device_registered') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Mark device as registered
  Future<void> setDeviceRegistered(bool value) {
    return _sharedPreferences!.setBool('device_registered', value);
  }

  /// Clear device registration flag (useful for testing/debugging)
  Future<void> clearDeviceRegistration() async {
    await _sharedPreferences!.remove('device_registered');
    await _sharedPreferences!.remove('visitortoken');
  }
}