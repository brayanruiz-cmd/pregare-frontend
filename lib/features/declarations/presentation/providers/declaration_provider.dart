import 'package:flutter/material.dart';
import '../../../../core/state/async_state.dart';
import '../../domain/models/declaration.dart';
import '../../domain/ports/declarations_repository.dart';
import '../../application/usecases/get_daily_declarations_use_case.dart';

class DeclarationProvider extends ChangeNotifier {
  DeclarationProvider({required DeclarationsRepository repository})
      : _getDaily = GetDailyDeclarationsUseCase(repository: repository);

  final GetDailyDeclarationsUseCase _getDaily;

  // Master list — fetched once and kept in memory.
  // Filtering by gender is done locally without hitting the network.
  List<Declaration> _allDeclarations = [];

  AsyncState<List<Declaration>> _declarations = const AsyncInitial();
  AsyncState<List<Declaration>> get declarations => _declarations;

  String _selectedGender = 'all';
  String get selectedGender => _selectedGender;

  List<String> _selectedTopics = [];
  List<String> get selectedTopics => _selectedTopics;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  // ── Derived view ──────────────────────────────────────────────────────────

  List<Declaration> get currentDeclarations {
    if (_declarations is AsyncData) {
      return (_declarations as AsyncData<List<Declaration>>).data;
    }
    return [];
  }

  Declaration? get currentDeclaration {
    final decls = currentDeclarations;
    if (decls.isEmpty || _currentIndex >= decls.length) return null;
    return decls[_currentIndex];
  }

  // ── Filtering (local — no network call) ───────────────────────────────────

  void _applyFilters() {
    var filtered = _allDeclarations;

    if (_selectedGender != 'all') {
      // Backend stores 'hombres', 'mujeres', or 'todos'
      // Pills use 'hombre' / 'mujer' as keys — map to backend plural form
      final backendGender = _selectedGender == 'hombre' ? 'hombres' : 'mujeres';
      filtered = filtered.where((d) {
        final g = d.gender.toLowerCase().trim();
        return g.isEmpty || g == 'todos' || g == backendGender;
      }).toList();
    }

    if (_selectedTopics.isNotEmpty) {
      filtered = filtered.where((d) {
        return d.topics.any((t) => _selectedTopics.contains(t));
      }).toList();
    }

    _declarations = AsyncData(filtered);
    _currentIndex = 0;
    notifyListeners();
  }

  // ── Network load ──────────────────────────────────────────────────────────

  Future<void> loadDeclarations() async {
    _declarations = const AsyncLoading();
    notifyListeners();

    try {
      // Always fetch without filters so we have the full dataset locally
      final result = await _getDaily.execute();
      _allDeclarations = result;
      _applyFilters(); // Apply current filters on the fresh data
    } catch (e) {
      _declarations = AsyncError(e.toString());
      notifyListeners();
    }
  }

  // ── Filter setters (instant — no network) ────────────────────────────────

  /// Changes the gender filter and applies it instantly to cached data.
  void setGender(String gender) {
    if (_selectedGender == gender) return; // No-op if already selected
    _selectedGender = gender;
    if (_allDeclarations.isNotEmpty) {
      _applyFilters(); // Filter locally — no loading spinner
    } else {
      loadDeclarations(); // First load ever
    }
  }

  void toggleTopic(String topic) {
    if (_selectedTopics.contains(topic)) {
      _selectedTopics.remove(topic);
    } else {
      _selectedTopics.add(topic);
    }
    if (_allDeclarations.isNotEmpty) {
      _applyFilters();
    } else {
      loadDeclarations();
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

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
