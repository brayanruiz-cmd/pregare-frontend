import 'package:flutter/material.dart';
import '../../../../core/state/async_state.dart';
import '../../domain/models/devotional.dart';
import '../../domain/ports/devotionals_repository.dart';

class DevotionalsProvider extends ChangeNotifier {
  DevotionalsProvider({required DevotionalsRepository repository})
      // ignore: prefer_initializing_formals
      : _repository = repository;

  final DevotionalsRepository _repository;

  AsyncState<List<Devotional>> _devotionals = const AsyncInitial();
  AsyncState<List<Devotional>> get devotionals => _devotionals;

  int? _expandedId;
  int? get expandedId => _expandedId;

  List<Devotional> get currentDevotionals {
    if (_devotionals is AsyncData) {
      return (_devotionals as AsyncData).data;
    }
    return [];
  }

  Future<void> loadDevotionals() async {
    _devotionals = const AsyncLoading();
    notifyListeners();

    try {
      final result = await _repository.getAll();
      _devotionals = AsyncData(result);
      if (result.isNotEmpty) {
        _expandedId = result.first.id;
      }
    } catch (e) {
      _devotionals = AsyncError(e.toString());
    }
    notifyListeners();
  }

  void markAsCompleted(String devotionalIdOrDay) {
    if (_devotionals is! AsyncData) return;
    final list = (_devotionals as AsyncData<List<Devotional>>).data;
    final updated = list.map((d) {
      if (d.uuid == devotionalIdOrDay ||
          d.id.toString() == devotionalIdOrDay ||
          d.day.toString() == devotionalIdOrDay) {
        return d.copyWith(isCompleted: true);
      }
      return d;
    }).toList();
    _devotionals = AsyncData(updated);
    notifyListeners();
  }

  bool isCompleted(Devotional d) {
    if (d.isCompleted) return true;
    if (_devotionals is AsyncData) {
      final list = (_devotionals as AsyncData<List<Devotional>>).data;
      for (final item in list) {
        if ((item.day == d.day || (d.uuid != null && item.uuid == d.uuid)) && item.isCompleted) {
          return true;
        }
      }
    }
    return false;
  }

  void toggleAccordion(int id) {
    if (_expandedId == id) {
      _expandedId = null;
    } else {
      _expandedId = id;
    }
    notifyListeners();
  }
}
