import 'package:flutter/material.dart';
import '../../../../core/state/async_state.dart';
import '../../domain/models/daily_verse.dart';
import '../../domain/ports/home_repository.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({required HomeRepository repository})
      // ignore: prefer_initializing_formals
      : _repository = repository;

  final HomeRepository _repository;

  AsyncState<HomeData> _state = const AsyncInitial();
  AsyncState<HomeData> get state => _state;

  String? _error;
  String? get error => _error;

  Future<void> loadHomeData() async {
    _state = const AsyncLoading();
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getHomeData();
      _state = AsyncData(result);
    } catch (e) {
      _state = AsyncError(e);
      _error = 'Error loading data. Please try again.';
    }
    notifyListeners();
  }
}
