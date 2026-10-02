import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/gender_selection_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/topics/presentation/screens/topic_detail_screen.dart';
import '../../features/topics/domain/models/topic.dart';
import '../../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../../features/streaks/presentation/screens/streaks_screen.dart';

class AppRouter {
  static const String initialRoute = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String genderSelection = '/gender-selection';
  static const String home = '/home';
  static const String bible = '/bible';
  static const String declarations = '/declarations';
  static const String devotionals = '/devotionals';
  static const String topics = '/topics';
  static const String topicDetail = '/topic-detail';
  static const String notificationSettings = '/notification-settings';
  static const String streaks = '/streaks';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildRoute(const LoginScreen(), settings);
      case register:
        return _buildRoute(const RegisterScreen(), settings);
      case genderSelection:
        return _buildRoute(const GenderSelectionScreen(), settings);
      case topicDetail:
        final topic = settings.arguments as Topic;
        return _buildRoute(TopicDetailScreen(topic: topic), settings);
      case notificationSettings:
        return _buildRoute(const NotificationSettingsScreen(), settings);
      case streaks:
        return _buildRoute(const StreaksScreen(), settings);
      default:
        return _buildRoute(const HomeScreen(), settings);
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
    );
  }
}
