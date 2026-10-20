import 'package:flutter/material.dart';
import '../../../../core/state/async_state.dart';
import '../../domain/models/streak.dart';
import '../../domain/models/streak_activity.dart';
import '../../domain/ports/streaks_repository.dart';

import '../../domain/models/user_badge_model.dart';

class StreaksProvider extends ChangeNotifier {
  StreaksProvider({required StreaksRepository repository})
      // ignore: prefer_initializing_formals
      : _repository = repository {
    loadStreak();
    loadBadges();
  }

  final StreaksRepository _repository;

  AsyncState<Streak> _streak = const AsyncInitial();
  AsyncState<Streak> get streak => _streak;

  AsyncState<MonthActivity> _monthActivity = const AsyncInitial();
  AsyncState<MonthActivity> get monthActivity => _monthActivity;

  AsyncState<List<UserBadgeModel>> _badges = const AsyncInitial();
  AsyncState<List<UserBadgeModel>> get badges => _badges;

  void reset() {
    _streak = const AsyncInitial();
    _badges = const AsyncInitial();
    _monthActivity = const AsyncInitial();
    _proclaimedDeclarationIds = [];
    notifyListeners();
  }
  List<UserBadgeModel> get currentBadges {
    if (_badges is AsyncData) {
      return (_badges as AsyncData).data;
    }
    return [];
  }

  Streak? get currentStreak {
    if (_streak is AsyncData) {
      return (_streak as AsyncData).data;
    }
    return null;
  }

  int get streakCount => currentStreak?.currentStreak ?? 0;

  MonthActivity? get currentMonthActivity {
    if (_monthActivity is AsyncData) {
      return (_monthActivity as AsyncData).data;
    }
    return null;
  }

  Future<void> loadStreak() async {
    _streak = const AsyncLoading();
    notifyListeners();

    try {
      final result = await _repository.getStreak();
      _streak = AsyncData(result);
    } catch (e) {
      _streak = AsyncError(e.toString());
    }
    notifyListeners();
  }

  Future<void> checkIn() async {
    try {
      final result = await _repository.checkIn();
      _streak = AsyncData(result);
      notifyListeners();
    } catch (e) {
      _streak = AsyncError(e.toString());
      notifyListeners();
    }
  }

  Future<void> loadMonthActivity({int? year, int? month}) async {
    _monthActivity = const AsyncLoading();
    notifyListeners();

    try {
      final result = await _repository.getMonthActivity(year: year, month: month);
      _monthActivity = AsyncData(result);
    } catch (e) {
      _monthActivity = AsyncError(e.toString());
    }
    notifyListeners();
  }

  Future<void> loadBadges() async {
    _badges = const AsyncLoading();
    notifyListeners();

    try {
      final list = await _repository.getBadges();
      _badges = AsyncData(list);
    } catch (e) {
      _badges = AsyncError(e.toString());
    }
    notifyListeners();
  }

  List<String> _proclaimedDeclarationIds = [];
  List<String> get proclaimedDeclarationIds => _proclaimedDeclarationIds;

  Future<void> loadProclaimedDeclarations() async {
    try {
      _proclaimedDeclarationIds = await _repository.getProclaimedDeclarations();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> completeDevotional(String devotionalId) async {
    try {
      final ok = await _repository.completeDevotional(devotionalId);
      if (ok) {
        await loadStreak();
        await loadBadges();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> proclaimDeclaration(String declarationId) async {
    try {
      final ok = await _repository.proclaimDeclaration(declarationId);
      if (ok) {
        if (!_proclaimedDeclarationIds.contains(declarationId)) {
          _proclaimedDeclarationIds.add(declarationId);
        }
        await loadStreak();
        await loadBadges();
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  String getMotivationalMessage(int days) {
    if (days == 0) return 'Start your streak today!';
    if (days == 1) return 'Day one! Keep going';
    if (days < 7) return '$days days in a row!';
    if (days < 30) return 'Incredible! $days days of consistency';
    if (days < 100) return 'You are unstoppable! $days days';
    return 'Legendary! $days days of faith';
  }
}
