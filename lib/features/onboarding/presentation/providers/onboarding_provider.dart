import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/infrastructure/http/http_client.dart';
import '../../domain/models/focus_area.dart';

class OnboardingProvider extends ChangeNotifier {
  static const String _keyCompleted = 'onboarding_completed';
  static const String _keyName = 'onboarding_name';
  static const String _keyGender = 'onboarding_gender';
  static const String _keyTopics = 'onboarding_topics';
  static const String _keyReminderTime = 'onboarding_reminder_time';
  static const String _keyReminderPeriod = 'onboarding_reminder_period';

  final PregareHttpClient? _httpClient;

  bool _isCompleted = false;
  bool get isCompleted => _isCompleted;

  String _name = '';
  String get name => _name;

  String _gender = 'mujeres';
  String get gender => _gender;

  final Set<String> _selectedTopics = {'Faith', 'Strength', 'Peace'};
  List<String> get selectedTopics => _selectedTopics.toList();

  String _reminderPeriod = 'Morning';
  String get reminderPeriod => _reminderPeriod;

  String _reminderTime = '6:15 AM';
  String get reminderTime => _reminderTime;

  List<FocusArea> _focusAreas = [];
  List<FocusArea> get focusAreas => _focusAreas;
  bool _isLoadingFocusAreas = false;
  bool get isLoadingFocusAreas => _isLoadingFocusAreas;

  // ignore: prefer_initializing_formals
  OnboardingProvider({PregareHttpClient? httpClient}) : _httpClient = httpClient {
    loadFromPreferences();
    loadFocusAreas();
  }

  Future<void> loadFocusAreas() async {
    if (_httpClient == null) return;
    _isLoadingFocusAreas = true;
    notifyListeners();
    try {
      final res = await _httpClient.get('/declarations/focus-areas', parser: (json) => json);
      if (res is List) {
        _focusAreas = res.map((f) => FocusArea.fromJson(f as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Graceful fallback
    } finally {
      _isLoadingFocusAreas = false;
      notifyListeners();
    }
  }

  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isCompleted = prefs.getBool(_keyCompleted) ?? false;
    _name = prefs.getString(_keyName) ?? '';
    _gender = prefs.getString(_keyGender) ?? 'mujeres';
    final savedTopics = prefs.getStringList(_keyTopics);
    if (savedTopics != null && savedTopics.isNotEmpty) {
      _selectedTopics.clear();
      _selectedTopics.addAll(savedTopics);
    }
    _reminderPeriod = prefs.getString(_keyReminderPeriod) ?? 'Morning';
    _reminderTime = prefs.getString(_keyReminderTime) ?? '6:15 AM';
    notifyListeners();
  }

  void setName(String value) {
    _name = value.trim();
    notifyListeners();
  }

  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void toggleTopic(String topic) {
    if (_selectedTopics.contains(topic)) {
      if (_selectedTopics.length > 1) {
        _selectedTopics.remove(topic);
      }
    } else {
      _selectedTopics.add(topic);
    }
    notifyListeners();
  }

  bool isTopicSelected(String topic) => _selectedTopics.contains(topic);

  void setReminderPeriod(String period) {
    _reminderPeriod = period;
    notifyListeners();
  }

  void setReminderTime(String time) {
    _reminderTime = time;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isCompleted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCompleted, true);
    await prefs.setString(_keyName, _name);
    await prefs.setString(_keyGender, _gender);
    await prefs.setStringList(_keyTopics, _selectedTopics.toList());
    await prefs.setString(_keyReminderPeriod, _reminderPeriod);
    await prefs.setString(_keyReminderTime, _reminderTime);
    notifyListeners();
  }

  String? getDisplayName() {
    if (_name.trim().isNotEmpty) {
      return _name.trim();
    }
    return null;
  }

  Future<void> clearUserData() async {
    _name = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    notifyListeners();
  }
}
