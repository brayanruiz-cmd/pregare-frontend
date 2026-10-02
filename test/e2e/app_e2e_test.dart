import 'package:flutter_test/flutter_test.dart';
import 'package:pregare_app/core/router/app_router.dart';

void main() {
  group('App Router Tests', () {
    test('Initial route is /home', () {
      expect(AppRouter.initialRoute, '/home');
    });

    test('All routes are defined', () {
      expect(AppRouter.login, '/login');
      expect(AppRouter.register, '/register');
      expect(AppRouter.genderSelection, '/gender-selection');
      expect(AppRouter.home, '/home');
      expect(AppRouter.bible, '/bible');
      expect(AppRouter.declarations, '/declarations');
      expect(AppRouter.devotionals, '/devotionals');
      expect(AppRouter.topics, '/topics');
      expect(AppRouter.topicDetail, '/topic-detail');
      expect(AppRouter.notificationSettings, '/notification-settings');
    });
  });
}
