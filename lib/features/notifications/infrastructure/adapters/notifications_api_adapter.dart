import '../../../../core/infrastructure/http/http_client.dart';
import '../../domain/models/notification_preferences.dart';
import '../../domain/ports/notifications_repository.dart';

class NotificationsApiAdapter implements NotificationsRepository {
  NotificationsApiAdapter({required this.httpClient});

  final PregareHttpClient httpClient;

  @override
  Future<NotificationPreferences> getPreferences() async {
    final data = await httpClient.get('/notifications/preferences', parser: (json) => json);
    return NotificationPreferences.fromJson(data);
  }

  @override
  Future<NotificationPreferences> updatePreferences(NotificationPreferences prefs) async {
    final data = await httpClient.put('/notifications/preferences', data: prefs.toJson());
    return NotificationPreferences.fromJson(data);
  }
}
