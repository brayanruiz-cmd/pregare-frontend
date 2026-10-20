import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineManager {
  OfflineManager._();
  static final OfflineManager instance = OfflineManager._();
  factory OfflineManager() => instance;

  static const _prefix = 'offline_';
  static const _expiryKey = '${_prefix}expiry_';
  static const _defaultTtl = Duration(days: 30);

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> save(String key, dynamic data, {Duration? ttl}) async {
    final prefs = await _ensurePrefs();
    final expiry = DateTime.now().add(ttl ?? _defaultTtl);
    await prefs.setString('$_prefix$key', jsonEncode(data));
    await prefs.setString('$_expiryKey$key', expiry.toIso8601String());
  }

  dynamic get(String key, {bool allowExpired = true}) {
    if (_prefs == null) return null;

    final data = _prefs!.getString('$_prefix$key');
    if (data == null) return null;

    final expiryStr = _prefs!.getString('$_expiryKey$key');
    if (expiryStr != null) {
      final expiry = DateTime.tryParse(expiryStr);
      if (expiry != null && DateTime.now().isAfter(expiry)) {
        if (!allowExpired) {
          _prefs!.remove('$_prefix$key');
          _prefs!.remove('$_expiryKey$key');
          return null;
        }
      }
    }

    try {
      return jsonDecode(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    final prefs = await _ensurePrefs();
    await prefs.remove('$_prefix$key');
    await prefs.remove('$_expiryKey$key');
  }

  Future<void> clear() async {
    final prefs = await _ensurePrefs();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  bool hasValidCache(String key) {
    if (_prefs == null) return false;
    final expiryStr = _prefs!.getString('$_expiryKey$key');
    if (expiryStr == null) return false;
    final expiry = DateTime.tryParse(expiryStr);
    return expiry != null && DateTime.now().isBefore(expiry);
  }
}
