import '../models/notification_preferences.dart';

abstract class NotificationsRepository {
  Future<NotificationPreferences> getPreferences();
  Future<NotificationPreferences> updatePreferences(NotificationPreferences prefs);
}
