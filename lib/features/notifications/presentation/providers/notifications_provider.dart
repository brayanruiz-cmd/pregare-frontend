import 'package:flutter/material.dart';
import '../../../../core/state/async_state.dart';
import '../../domain/models/notification_preferences.dart';
import '../../domain/ports/notifications_repository.dart';

class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider({required NotificationsRepository repository})
      : _repository = repository;

  final NotificationsRepository _repository;

  AsyncState<NotificationPreferences> _preferences = const AsyncInitial();
  AsyncState<NotificationPreferences> get preferences => _preferences;

  NotificationPreferences? get currentPreferences {
    if (_preferences is AsyncData) {
      return (_preferences as AsyncData).data;
    }
    return null;
  }

  Future<void> loadPreferences() async {
    _preferences = const AsyncLoading();
    notifyListeners();

    try {
      final result = await _repository.getPreferences();
      _preferences = AsyncData(result);
    } catch (e) {
      _preferences = AsyncError(e.toString());
    }
    notifyListeners();
  }

  Future<void> updatePreference({
    bool? dailyVerse,
    bool? declarations,
    bool? streakReminder,
    String? reminderTime,
  }) async {
    final current = currentPreferences;
    if (current == null) return;

    final updated = current.copyWith(
      dailyVerse: dailyVerse,
      declarations: declarations,
      streakReminder: streakReminder,
      reminderTime: reminderTime,
    );

    _preferences = AsyncData(updated);
    notifyListeners();

    try {
      await _repository.updatePreferences(updated);
    } catch (e) {
      _preferences = AsyncData(current);
      notifyListeners();
    }
  }
}
