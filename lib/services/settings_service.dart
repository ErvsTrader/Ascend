import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _keyName = 'user_name';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keySound = 'notification_sound';
  static const String _keyDarkMode = 'dark_mode_enabled';
  static const String _keyReminderHour = 'reminder_hour';
  static const String _keyReminderMinute = 'reminder_minute';

  SharedPreferences? _prefs;

  String _userName = 'Alex';
  bool _notificationsEnabled = true;
  String _notificationSound = 'default';
  bool _isDarkMode = false;
  TimeOfDay _defaultReminderTime = const TimeOfDay(hour: 8, minute: 0);

  String get userName => _userName;
  bool get notificationsEnabled => _notificationsEnabled;
  String get notificationSound => _notificationSound;
  bool get isDarkMode => _isDarkMode;
  TimeOfDay get defaultReminderTime => _defaultReminderTime;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _userName = _prefs?.getString(_keyName) ?? 'Alex';
    _notificationsEnabled = _prefs?.getBool(_keyNotifications) ?? true;
    _notificationSound = _prefs?.getString(_keySound) ?? 'default';
    _isDarkMode = _prefs?.getBool(_keyDarkMode) ?? false;
    
    final hour = _prefs?.getInt(_keyReminderHour) ?? 8;
    final minute = _prefs?.getInt(_keyReminderMinute) ?? 0;
    _defaultReminderTime = TimeOfDay(hour: hour, minute: minute);
    
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await _prefs?.setString(_keyName, name);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _prefs?.setBool(_keyNotifications, value);
    notifyListeners();
  }

  Future<void> setNotificationSound(String sound) async {
    _notificationSound = sound;
    await _prefs?.setString(_keySound, sound);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs?.setBool(_keyDarkMode, value);
    notifyListeners();
  }

  Future<void> setDefaultReminderTime(TimeOfDay time) async {
    _defaultReminderTime = time;
    await _prefs?.setInt(_keyReminderHour, time.hour);
    await _prefs?.setInt(_keyReminderMinute, time.minute);
    notifyListeners();
  }
}
