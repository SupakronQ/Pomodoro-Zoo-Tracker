import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerSettingsProvider extends ChangeNotifier {
  static const _keyFocus = 'settings_focus_minutes';
  static const _keyShortBreak = 'settings_short_break_minutes';
  static const _keyLongBreak = 'settings_long_break_minutes';
  static const _keyVibrate = 'settings_vibrate_on_finish';
  static const _keyHaptic = 'settings_haptic_feedback';
  static const _keyAmbient = 'settings_ambient_sounds';
  static const _keyAmbientPreset = 'settings_ambient_preset';
  static const _keyNotifSound = 'settings_notification_sound';

  static const List<String> ambientPresets = [
    'Rainforest',
    'Soft Wind',
    'Stream',
    'Fireplace',
    'Ocean',
  ];
  static const List<String> notificationSounds = [
    'Zen Chime',
    'Bell',
    'Soft Ding',
    'None',
  ];

  int _focusMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  bool _vibrateOnFinish = true;
  bool _hapticFeedback = true;
  bool _ambientSounds = false;
  String _ambientPreset = 'Rainforest';
  String _notificationSound = 'Zen Chime';

  int get focusMinutes => _focusMinutes;
  int get shortBreakMinutes => _shortBreakMinutes;
  int get longBreakMinutes => _longBreakMinutes;
  bool get vibrateOnFinish => _vibrateOnFinish;
  bool get hapticFeedback => _hapticFeedback;
  bool get ambientSounds => _ambientSounds;
  String get ambientPreset => _ambientPreset;
  String get notificationSound => _notificationSound;

  TimerSettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _focusMinutes = prefs.getInt(_keyFocus) ?? 25;
    _shortBreakMinutes = prefs.getInt(_keyShortBreak) ?? 5;
    _longBreakMinutes = prefs.getInt(_keyLongBreak) ?? 15;
    _vibrateOnFinish = prefs.getBool(_keyVibrate) ?? true;
    _hapticFeedback = prefs.getBool(_keyHaptic) ?? true;
    _ambientSounds = prefs.getBool(_keyAmbient) ?? false;
    _ambientPreset = prefs.getString(_keyAmbientPreset) ?? 'Rainforest';
    _notificationSound = prefs.getString(_keyNotifSound) ?? 'Zen Chime';
    notifyListeners();
  }

  Future<void> setFocusMinutes(int value) async {
    _focusMinutes = value.clamp(5, 60);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFocus, _focusMinutes);
  }

  Future<void> setShortBreakMinutes(int value) async {
    _shortBreakMinutes = value.clamp(1, 15);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyShortBreak, _shortBreakMinutes);
  }

  Future<void> setLongBreakMinutes(int value) async {
    _longBreakMinutes = value.clamp(10, 45);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLongBreak, _longBreakMinutes);
  }

  Future<void> setVibrateOnFinish(bool value) async {
    _vibrateOnFinish = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVibrate, value);
  }

  Future<void> setHapticFeedback(bool value) async {
    _hapticFeedback = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHaptic, value);
  }

  Future<void> setAmbientSounds(bool value) async {
    _ambientSounds = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAmbient, value);
  }

  Future<void> setAmbientPreset(String value) async {
    _ambientPreset = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAmbientPreset, value);
  }

  Future<void> setNotificationSound(String value) async {
    _notificationSound = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNotifSound, value);
  }
}
