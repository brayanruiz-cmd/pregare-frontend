import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/infrastructure/http/http_client.dart';
import '../../domain/models/auth_session.dart';
import '../../domain/models/user.dart';
import '../../domain/ports/auth_repository.dart';

class AuthApiAdapter implements AuthRepository {
  AuthApiAdapter({required this.httpClient});

  final PregareHttpClient httpClient;
  static const _tokenKey = 'pregare_auth_token';
  static const _refreshTokenKey = 'pregare_refresh_token';
  static const _userKey = 'pregare_auth_user';

  Future<void> _persistSession(AuthSession session) async {
    httpClient.updateToken(session.accessToken);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, session.accessToken);
      await prefs.setString(_refreshTokenKey, session.refreshToken);
      await prefs.setString(_userKey, jsonEncode(session.user.toJson()));
    } catch (_) {}
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    String? gender,
    List<String>? selectedTopics,
    String? notificationTime,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
    };
    if (gender != null) payload['gender'] = gender;
    if (selectedTopics != null) payload['selectedTopics'] = selectedTopics;
    if (notificationTime != null) payload['notificationTime'] = notificationTime;

    final data = await httpClient.post(
      '/auth/register',
      data: payload,
      parser: (json) => json,
    );
    final session = AuthSession.fromJson(data);
    await _persistSession(session);
    return session;
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await httpClient.post(
      '/auth/login',
      data: {'email': email, 'password': password},
      parser: (json) => json,
    );
    final session = AuthSession.fromJson(data);
    await _persistSession(session);
    return session;
  }

  @override
  Future<AuthSession> googleAuth({required String idToken}) async {
    final data = await httpClient.post(
      '/auth/google',
      data: {'idToken': idToken},
      parser: (json) => json,
    );
    final session = AuthSession.fromJson(data);
    await _persistSession(session);
    return session;
  }

  @override
  Future<AuthSession> refreshToken({required String refreshToken}) async {
    final data = await httpClient.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      parser: (json) => json,
    );
    final session = AuthSession.fromJson(data);
    await _persistSession(session);
    return session;
  }

  @override
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      await httpClient.post(
        '/auth/logout',
        data: {'refreshToken': refreshToken ?? ''},
      );
    } catch (_) {
      // Ignore network/server errors so local session is always cleanly cleared
    } finally {
      httpClient.updateToken(null);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
        await prefs.remove(_refreshTokenKey);
        await prefs.remove(_userKey);
      } catch (_) {}
    }
  }

  @override
  Future<void> updateGender({required String gender}) async {
    await httpClient.put('/auth/gender', data: {'gender': gender});
  }

  @override
  Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null && token.isNotEmpty) {
        httpClient.updateToken(token);
      }
      return token;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthSession?> getStoredSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final refreshToken = prefs.getString(_refreshTokenKey);
      final userRaw = prefs.getString(_userKey);

      if (token != null && token.isNotEmpty && refreshToken != null && userRaw != null) {
        final userJson = jsonDecode(userRaw) as Map<String, dynamic>;
        final user = User.fromJson(userJson);
        final session = AuthSession(
          user: user,
          accessToken: token,
          refreshToken: refreshToken,
        );
        httpClient.updateToken(token);
        return session;
      } else {
        httpClient.updateToken(null);
        return null;
      }
    } catch (_) {
      httpClient.updateToken(null);
      return null;
    }
  }
}

