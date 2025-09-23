import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageProvider extends ChangeNotifier {
  static const String _keyLastSync = 'last_sync';
  static const String _keyAutoBackup = 'auto_backup';
  static const String _keyNotifications = 'notifications';

  DateTime? _lastSync;
  bool _autoBackup = true;
  bool _notificationsEnabled = true;

  DateTime? get lastSync => _lastSync;
  bool get autoBackup => _autoBackup;
  bool get notificationsEnabled => _notificationsEnabled;

  StorageProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final lastSyncMillis = prefs.getInt(_keyLastSync);
    if (lastSyncMillis != null) {
      _lastSync = DateTime.fromMillisecondsSinceEpoch(lastSyncMillis);
    }

    _autoBackup = prefs.getBool(_keyAutoBackup) ?? true;
    _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;

    notifyListeners();
  }

  Future<void> updateLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    _lastSync = DateTime.now();
    await prefs.setInt(_keyLastSync, _lastSync!.millisecondsSinceEpoch);
    notifyListeners();
  }

  Future<void> setAutoBackup(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _autoBackup = value;
    await prefs.setBool(_keyAutoBackup, value);
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = value;
    await prefs.setBool(_keyNotifications, value);
    notifyListeners();
  }
}