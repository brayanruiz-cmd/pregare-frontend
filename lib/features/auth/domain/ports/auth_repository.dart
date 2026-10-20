import '../models/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    String? gender,
    List<String>? selectedTopics,
    String? notificationTime,
  });

  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession> googleAuth({required String idToken});

  Future<AuthSession> refreshToken({required String refreshToken});

  Future<void> logout();

  Future<void> updateGender({required String gender});

  Future<String?> getStoredToken();
  Future<AuthSession?> getStoredSession();
}
