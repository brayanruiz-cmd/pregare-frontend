import '../../../../core/infrastructure/http/http_client.dart';

/// Thin wrapper over `GET/PATCH /users/me/preferences`.
/// Returns the raw JSON map so callers can pluck only what they need.
class UserPreferencesApiAdapter {
  UserPreferencesApiAdapter({required PregareHttpClient httpClient})
      : _http = httpClient;

  final PregareHttpClient _http;

  Future<Map<String, dynamic>> getPreferences() async {
    final data = await _http.get<Map<String, dynamic>>(
      '/users/me/preferences',
      parser: (json) => Map<String, dynamic>.from(json as Map),
    );
    return data;
  }

  Future<void> patchPreferences(Map<String, dynamic> update) async {
    await _http.patch('/users/me/preferences', data: update);
  }
}
