import 'package:flutter_test/flutter_test.dart';
import 'package:pregare_app/features/auth/domain/models/auth_session.dart';
import 'package:pregare_app/features/auth/domain/models/user.dart';

void main() {
  group('AuthSession', () {
    test('parses from JSON with camelCase keys', () {
      final json = {
        'user': {'id': '1', 'name': 'Test', 'email': 'test@test.com'},
        'accessToken': 'token-123',
        'refreshToken': 'refresh-456',
      };

      final session = AuthSession.fromJson(json);

      expect(session.user.id, '1');
      expect(session.user.name, 'Test');
      expect(session.accessToken, 'token-123');
      expect(session.refreshToken, 'refresh-456');
    });

    test('parses from JSON with snake_case keys', () {
      final json = {
        'user': {'id': '1', 'name': 'Test', 'email': 'test@test.com'},
        'access_token': 'token-123',
        'refresh_token': 'refresh-456',
      };

      final session = AuthSession.fromJson(json);

      expect(session.accessToken, 'token-123');
      expect(session.refreshToken, 'refresh-456');
    });
  });

  group('User', () {
    test('parses from JSON with all fields', () {
      final json = {
        'id': '1',
        'name': 'Test',
        'email': 'test@test.com',
        'gender': 'mujeres',
        'provider': 'google',
      };

      final user = User.fromJson(json);

      expect(user.id, '1');
      expect(user.gender, 'mujeres');
      expect(user.provider, 'google');
    });

    test('defaults provider to email', () {
      final json = {
        'id': '1',
        'name': 'Test',
        'email': 'test@test.com',
      };

      final user = User.fromJson(json);

      expect(user.provider, 'email');
    });
  });
}
