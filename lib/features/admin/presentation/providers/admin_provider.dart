import 'package:flutter/material.dart';
import '../../../../core/state/async_state.dart';
import '../../../topics/domain/models/topic.dart';
import '../../../devotionals/domain/models/devotional.dart';
import '../../../onboarding/domain/models/focus_area.dart';
import '../../domain/ports/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider({required AdminRepository repository})
      // ignore: prefer_initializing_formals
      : _repository = repository;

  final AdminRepository _repository;

  AsyncState<Map<String, dynamic>> _stats = const AsyncInitial();
  AsyncState<Map<String, dynamic>> get stats => _stats;

  AsyncState<List<Topic>> _topics = const AsyncInitial();
  AsyncState<List<Topic>> get topics => _topics;

  AsyncState<List<Devotional>> _devotionals = const AsyncInitial();
  AsyncState<List<Devotional>> get devotionals => _devotionals;

  AsyncState<List<FocusArea>> _focusAreas = const AsyncInitial();
  AsyncState<List<FocusArea>> get focusAreas => _focusAreas;

  List<Topic> get currentTopics {
    if (_topics is AsyncData<List<Topic>>) {
      return (_topics as AsyncData<List<Topic>>).data;
    }
    return [];
  }

  List<Devotional> get currentDevotionals {
    if (_devotionals is AsyncData<List<Devotional>>) {
      return (_devotionals as AsyncData<List<Devotional>>).data;
    }
    return [];
  }

  List<FocusArea> get currentFocusAreas {
    if (_focusAreas is AsyncData<List<FocusArea>>) {
      return (_focusAreas as AsyncData<List<FocusArea>>).data;
    }
    return [];
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadStats(),
      loadTopics(),
      loadDevotionals(),
      loadFocusAreas(),
    ]);
  }

  Future<void> loadStats() async {
    _stats = const AsyncLoading();
    notifyListeners();
    try {
      final res = await _repository.getStats();
      _stats = AsyncData(res);
    } catch (e) {
      _stats = AsyncError(e.toString());
    }
    notifyListeners();
  }

  Future<void> loadTopics() async {
    _topics = const AsyncLoading();
    notifyListeners();
    try {
      final res = await _repository.getTopics();
      _topics = AsyncData(res);
    } catch (e) {
      _topics = AsyncError(e.toString());
    }
    notifyListeners();
  }

  Future<bool> saveTopic({
    String? id,
    required String tag,
    required String title,
    String? subtitle,
    required String description,
    String? scriptureQuote,
    String? scriptureReference,
    String? youtubeUrl,
    int? videoDurationMinutes,
    List<String>? supportTips,
  }) async {
    try {
      final data = {
        'tag': tag,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'scriptureQuote': scriptureQuote,
        'scriptureReference': scriptureReference,
        'youtubeUrl': youtubeUrl,
        'videoDurationMinutes': videoDurationMinutes ?? 8,
        'supportTips': supportTips ?? [],
      };

      if (id != null && id.isNotEmpty) {
        await _repository.updateTopic(id, data);
      } else {
        await _repository.createTopic(data);
      }

      await loadTopics();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTopic(String id) async {
    try {
      await _repository.deleteTopic(id);
      await loadTopics();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadDevotionals() async {
    _devotionals = const AsyncLoading();
    notifyListeners();
    try {
      final res = await _repository.getDevotionals();
      _devotionals = AsyncData(res);
    } catch (e) {
      _devotionals = AsyncError(e.toString());
    }
    notifyListeners();
  }

  Future<bool> saveDevotional({
    String? id,
    required int dayNumber,
    required String title,
    required String verseText,
    String? verseReference,
    required String reflectionText,
    required String prayerText,
    int? durationMinutes,
  }) async {
    try {
      final data = {
        'dayNumber': dayNumber,
        'title': title,
        'verseText': verseText,
        'verseReference': verseReference ?? '',
        'reflectionText': reflectionText,
        'prayerText': prayerText,
        'durationMinutes': durationMinutes ?? 2,
      };

      if (id != null && id.isNotEmpty) {
        await _repository.updateDevotional(id, data);
      } else {
        await _repository.createDevotional(data);
      }

      await loadDevotionals();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteDevotional(String id) async {
    try {
      await _repository.deleteDevotional(id);
      await loadDevotionals();
      return true;
    } catch (_) {
      return false;
    }
  }

  // --- FOCUS AREAS / STRENGTHS ---
  Future<void> loadFocusAreas() async {
    _focusAreas = const AsyncLoading();
    notifyListeners();
    try {
      final res = await _repository.getFocusAreas();
      _focusAreas = AsyncData(res);
    } catch (e) {
      _focusAreas = AsyncError(e.toString());
    }
    notifyListeners();
  }

  Future<bool> saveFocusArea({
    int? id,
    required String name,
    String? description,
    int? order,
    bool? isActive,
  }) async {
    try {
      final data = {
        'name': name.trim(),
        'description': description?.trim(),
        'order': order ?? 0,
        'isActive': isActive ?? true,
      };

      if (id != null && id > 0) {
        await _repository.updateFocusArea(id, data);
      } else {
        await _repository.createFocusArea(data);
      }

      await loadFocusAreas();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteFocusArea(int id) async {
    try {
      await _repository.deleteFocusArea(id);
      await loadFocusAreas();
      return true;
    } catch (_) {
      return false;
    }
  }
}
