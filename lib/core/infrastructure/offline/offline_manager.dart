import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineManager {
  static const _prefix = 'offline_';
  static const _expiryKey = '${_prefix}expiry_';
  static const _defaultTtl = Duration(hours: 24);

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> save(String key, dynamic data, {Duration? ttl}) async {
    final expiry = DateTime.now().add(ttl ?? _defaultTtl);
    await _prefs.setString('${_prefix}$key', jsonEncode(data));
    await _prefs.setString('${_expiryKey}$key', expiry.toIso8601String());
  }

  dynamic get(String key) {
    final expiryStr = _prefs.getString('${_expiryKey}$key');
    if (expiryStr == null) return null;

    final expiry = DateTime.parse(expiryStr);
    if (DateTime.now().isAfter(expiry)) {
      _prefs.remove('${_prefix}$key');
      _prefs.remove('${_expiryKey}$key');
      return null;
    }

    final data = _prefs.getString('${_prefix}$key');
    if (data == null) return null;
    return jsonDecode(data);
  }

  Future<void> remove(String key) async {
    await _prefs.remove('${_prefix}$key');
    await _prefs.remove('${_expiryKey}$key');
  }

  Future<void> clear() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  bool hasValidCache(String key) {
    final expiryStr = _prefs.getString('${_expiryKey}$key');
    if (expiryStr == null) return false;
    return DateTime.now().isBefore(DateTime.parse(expiryStr));
  }
}
