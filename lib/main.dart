import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/tokens.dart';
import 'core/infrastructure/http/http_client.dart';
import 'core/ui/organisms/main_shell.dart';
import 'features/auth/infrastructure/adapters/auth_api_adapter.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/home/infrastructure/adapters/home_api_adapter.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'features/bible/infrastructure/adapters/bible_api_adapter.dart';
import 'features/bible/presentation/providers/bible_provider.dart';
import 'features/declarations/infrastructure/adapters/declarations_api_adapter.dart';
import 'features/declarations/presentation/providers/declaration_provider.dart';
import 'features/devotionals/infrastructure/adapters/devotionals_api_adapter.dart';
import 'features/devotionals/presentation/providers/devotionals_provider.dart';
import 'features/topics/infrastructure/adapters/topics_api_adapter.dart';
import 'features/topics/presentation/providers/topics_provider.dart';
import 'features/streaks/infrastructure/adapters/streaks_api_adapter.dart';
import 'features/streaks/presentation/providers/streaks_provider.dart';
import 'features/notifications/infrastructure/adapters/notifications_api_adapter.dart';
import 'features/notifications/presentation/providers/notifications_provider.dart';
import 'features/admin/infrastructure/adapters/admin_api_adapter.dart';
import 'features/admin/presentation/providers/admin_provider.dart';
import 'features/auth/infrastructure/adapters/user_preferences_api_adapter.dart';
import 'core/infrastructure/offline/offline_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OfflineManager.instance.init();
  runApp(const PregareApp());
}

class PregareApp extends StatelessWidget {
  const PregareApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BASE_URL_OVERRIDE is passed via --dart-define=BASE_URL_OVERRIDE=http://...
    // Falls back to 127.0.0.1 (not localhost) for Chrome compatibility.
    const baseUrl = String.fromEnvironment(
      'BASE_URL_OVERRIDE',
      defaultValue: 'http://127.0.0.1:3000',
    );
    final httpClient = PregareHttpClient(baseUrl: baseUrl);
    final authRepository = AuthApiAdapter(httpClient: httpClient);
    final homeRepository = HomeApiAdapter(httpClient: httpClient);
    final bibleRepository = BibleApiAdapter(httpClient: httpClient);
    final declarationsRepository = DeclarationsApiAdapter(httpClient: httpClient);
    final devotionalsRepository = DevotionalsApiAdapter(httpClient: httpClient);
    final topicsRepository = TopicsApiAdapter(httpClient: httpClient);
    final streaksRepository = StreaksApiAdapter(httpClient: httpClient);
    final notificationsRepository = NotificationsApiAdapter(httpClient: httpClient);
    final adminRepository = AdminApiAdapter(httpClient: httpClient);
    final userPrefsAdapter = UserPreferencesApiAdapter(httpClient: httpClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider(httpClient: httpClient),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(repository: homeRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => BibleProvider(repository: bibleRepository)..loadHighlights(),
        ),
        ChangeNotifierProvider(
          create: (_) => DeclarationProvider(repository: declarationsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => DevotionalsProvider(repository: devotionalsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TopicsProvider(repository: topicsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => StreaksProvider(repository: streaksRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationsProvider(repository: notificationsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider(repository: adminRepository),
        ),
        Provider<UserPreferencesApiAdapter>.value(value: userPrefsAdapter),
      ],
      child: MaterialApp(
        title: 'Pregare',
        debugShowCheckedModeBanner: false,
        theme: PTheme.dark,
        home: Consumer<OnboardingProvider>(
          builder: (context, onboarding, _) {
            return onboarding.isCompleted
                ? const MainShell()
                : const OnboardingScreen();
          },
        ),
      ),
    );
  }
}
