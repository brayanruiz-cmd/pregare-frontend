import 'package:flutter/material.dart';
import '../../../../core/state/async_state.dart';
import '../../domain/models/declaration.dart';
import '../../domain/ports/declarations_repository.dart';
import '../../application/usecases/get_daily_declarations_use_case.dart';

class DeclarationProvider extends ChangeNotifier {
  DeclarationProvider({required DeclarationsRepository repository})
      : _getDaily = GetDailyDeclarationsUseCase(repository: repository);

  final GetDailyDeclarationsUseCase _getDaily;

  AsyncState<List<Declaration>> _declarations = const AsyncInitial();
  AsyncState<List<Declaration>> get declarations => _declarations;

  String _selectedGender = 'all';
  String get selectedGender => _selectedGender;

  List<String> _selectedTopics = [];
  List<String> get selectedTopics => _selectedTopics;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  List<Declaration> get currentDeclarations {
    if (_declarations is AsyncData) {
      return (_declarations as AsyncData).data;
    }
    return [];
  }

  Declaration? get currentDeclaration {
    final decls = currentDeclarations;
    if (decls.isEmpty || _currentIndex >= decls.length) return null;
    return decls[_currentIndex];
  }

  Future<void> loadDeclarations() async {
    _declarations = const AsyncLoading();
    notifyListeners();

    try {
      final gender = _selectedGender == 'all' ? null : _selectedGender;
      final topics = _selectedTopics.isEmpty ? null : _selectedTopics;
      final result = await _getDaily.execute(gender: gender, topics: topics);
      _declarations = AsyncData(result);
      _currentIndex = 0;
    } catch (e) {
      _declarations = AsyncError(e.toString());
    }
    notifyListeners();
  }

  void setGender(String gender) {
    _selectedGender = gender;
    loadDeclarations();
  }

  void toggleTopic(String topic) {
    if (_selectedTopics.contains(topic)) {
      _selectedTopics.remove(topic);
    } else {
      _selectedTopics.add(topic);
    }
    loadDeclarations();
  }

  void nextDeclaration() {
    final decls = currentDeclarations;
    if (_currentIndex < decls.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousDeclaration() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void goToDeclaration(int index) {
    final decls = currentDeclarations;
    if (index >= 0 && index < decls.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void shuffle() {
    loadDeclarations();
  }
}
