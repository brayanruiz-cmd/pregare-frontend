import 'package:flutter/material.dart';
import '../../../../core/state/async_state.dart';
import '../../domain/models/declaration.dart';
import '../../domain/ports/declarations_repository.dart';
import '../../application/usecases/get_daily_declarations_use_case.dart';
import '../../application/usecases/get_today_declaration_use_case.dart';

class DeclarationProvider extends ChangeNotifier {
  DeclarationProvider({required DeclarationsRepository repository})
      : _getDaily = GetDailyDeclarationsUseCase(repository: repository),
        _getToday = GetTodayDeclarationUseCase(repository: repository);

  final GetDailyDeclarationsUseCase _getDaily;
  final GetTodayDeclarationUseCase _getToday;

  // ── 365 Daily Declaration State ──────────────────────────────────────────
  AsyncState<Declaration> _todayState = const AsyncInitial();
  AsyncState<Declaration> get todayState => _todayState;

  final Map<String, Declaration> _cachedTodayByGender = {};
  Declaration? _todayDeclaration;
  Declaration? get todayDeclaration => _todayDeclaration;

  bool _isRevealed = false;
  bool get isRevealed => _isRevealed;

  void setRevealed(bool val) {
    _isRevealed = val;
    notifyListeners();
  }

  // ── Legacy / Multi-item declarations state ────────────────────────────────
  List<Declaration> _allDeclarations = [];

  AsyncState<List<Declaration>> _declarations = const AsyncInitial();
  AsyncState<List<Declaration>> get declarations => _declarations;

  String _selectedGender = 'mujeres'; // 'mujeres' or 'hombres'
  String get selectedGender => _selectedGender;

  final List<String> _selectedTopics = [];
  List<String> get selectedTopics => _selectedTopics;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

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

  // ── Today's Single Declaration Loader ─────────────────────────────────────
  Future<void> loadTodayDeclaration({String? gender, bool forceReload = false}) async {
    if (gender != null) {
      final g = gender.toLowerCase().trim();
      _selectedGender = (g.startsWith('h') || g.contains('men') || g == 'male')
          ? 'hombres'
          : 'mujeres';
    }

    if (!forceReload && _cachedTodayByGender.containsKey(_selectedGender)) {
      _todayDeclaration = _cachedTodayByGender[_selectedGender];
      _todayState = AsyncData(_todayDeclaration!);
      notifyListeners();
      return;
    }

    _todayState = const AsyncLoading();
    notifyListeners();

    try {
      final item = await _getToday.execute(gender: _selectedGender);
      _cachedTodayByGender[_selectedGender] = item;
      _todayDeclaration = item;
      _todayState = AsyncData(item);

      // Pre-fetch opposite gender in background so both cards are immediately ready
      final otherGender = _selectedGender == 'mujeres' ? 'hombres' : 'mujeres';
      if (!_cachedTodayByGender.containsKey(otherGender)) {
        _getToday.execute(gender: otherGender).then((otherItem) {
          _cachedTodayByGender[otherGender] = otherItem;
        }).catchError((_) {});
      }
    } catch (e) {
      _todayState = AsyncError(e.toString());
    }
    notifyListeners();
  }

  Declaration? declarationForGender(String gender) {
    final norm = (gender.toLowerCase().startsWith('h') ||
            gender.toLowerCase().contains('men') ||
            gender.toLowerCase() == 'male')
        ? 'hombres'
        : 'mujeres';
    return _cachedTodayByGender[norm];
  }

  // ── Filtering & Legacy loaders ───────────────────────────────────────────
  void _applyFilters() {
    var filtered = _allDeclarations;

    if (_selectedGender != 'all') {
      final backendGender = (_selectedGender == 'hombre' || _selectedGender == 'hombres')
          ? 'hombres'
          : 'mujeres';
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

  Future<void> loadDeclarations() async {
    _declarations = const AsyncLoading();
    notifyListeners();

    // Also load today's single declaration
    loadTodayDeclaration(gender: _selectedGender, forceReload: true);

    try {
      final result = await _getDaily.execute();
      _allDeclarations = result;
      _applyFilters();
    } catch (e) {
      _declarations = AsyncError(e.toString());
      notifyListeners();
    }
  }

  void setGender(String gender) {
    final normalized = (gender.toLowerCase().startsWith('h') ||
            gender.toLowerCase().contains('men') ||
            gender.toLowerCase() == 'male')
        ? 'hombres'
        : 'mujeres';

    if (_selectedGender == normalized && _todayDeclaration != null) return;

    _selectedGender = normalized;
    loadTodayDeclaration(gender: normalized, forceReload: false);

    if (_allDeclarations.isNotEmpty) {
      _applyFilters();
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
