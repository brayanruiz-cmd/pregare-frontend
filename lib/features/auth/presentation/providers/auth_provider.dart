import 'package:flutter/material.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/infrastructure/errors/app_exception.dart';
import '../../domain/models/auth_session.dart';
import '../../domain/ports/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository repository}) : _repository = repository {
    restoreSession();
  }

  final AuthRepository _repository;

  AsyncState<AuthSession> _session = const AsyncInitial();
  AsyncState<AuthSession> get session => _session;

  bool get isAuthenticated => _session is AsyncData;
  AuthSession? get currentSession =>
      _session is AsyncData ? (_session as AsyncData<AuthSession>).data : null;

  String? _error;
  String? get error => _error;

  Future<void> restoreSession() async {
    try {
      final session = await _repository.getStoredSession();
      if (session != null) {
        _session = AsyncData(session);
        notifyListeners();
      } else {
        _session = const AsyncInitial();
        notifyListeners();
      }
    } catch (_) {
      _session = const AsyncInitial();
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _session = const AsyncLoading();
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.login(email: email, password: password);
      _session = AsyncData(result);
    } on AppException catch (e) {
      _session = AsyncError(e);
      _error = e.message;
    } catch (e) {
      _session = AsyncError(e);
      _error = 'Error inesperado. Intenta de nuevo.';
    }
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? gender,
    List<String>? selectedTopics,
    String? notificationTime,
  }) async {
    _session = const AsyncLoading();
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.register(
        name: name,
        email: email,
        password: password,
        gender: gender,
        selectedTopics: selectedTopics,
        notificationTime: notificationTime,
      );
      _session = AsyncData(result);
    } on AppException catch (e) {
      _session = AsyncError(e);
      _error = e.message;
    } catch (e) {
      _session = AsyncError(e);
      _error = 'Error inesperado. Intenta de nuevo.';
    }
    notifyListeners();
  }

  Future<void> googleAuth({required String idToken}) async {
    _session = const AsyncLoading();
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.googleAuth(idToken: idToken);
      _session = AsyncData(result);
    } on AppException catch (e) {
      _session = AsyncError(e);
      _error = e.message;
    } catch (e) {
      _session = AsyncError(e);
      _error = 'Error con Google. Intenta de nuevo.';
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.logout();
    _session = const AsyncInitial();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
