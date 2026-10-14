import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/home/presentation/screens/home_screen.dart';
import '../../../features/home/presentation/providers/home_provider.dart';
import '../../../features/bible/presentation/screens/bible_screen.dart';
import '../../../features/bible/presentation/providers/bible_provider.dart';
import '../../../features/declarations/presentation/screens/declarations_screen.dart';
import '../../../features/declarations/presentation/providers/declaration_provider.dart';
import '../../../features/topics/presentation/screens/topics_screen.dart';
import '../../../features/topics/presentation/providers/topics_provider.dart';
import '../../../features/devotionals/presentation/providers/devotionals_provider.dart';
import '../../../features/streaks/presentation/screens/profile_screen.dart';
import '../../../features/streaks/presentation/providers/streaks_provider.dart';
import 'web_side_nav.dart';
import '../../theme/tokens.dart';
import '../../theme/app_breakpoints.dart';
import '../primitives/primitives.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static void setTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_MainShellState>()?.changeTab(index);
  }

  static void reloadAll(BuildContext context) {
    context.findAncestorStateOfType<_MainShellState>()?._reloadAllData();
  }

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  String? _lastSessionId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    final currentSessionId =
        auth.isAuthenticated ? auth.currentSession?.user.id : 'guest';
    if (_lastSessionId != null && _lastSessionId != currentSessionId) {
      _lastSessionId = currentSessionId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _reloadAllData();
        }
      });
    } else {
      _lastSessionId = currentSessionId;
    }
  }

  void changeTab(int index) {
    setState(() => _currentIndex = index);
    _refreshTab(index);
  }

  void _refreshTab(int index) {
    if (index == 0) {
      context.read<HomeProvider>().loadHomeData();
      context.read<TopicsProvider>().loadTopics();
    } else if (index == 1) {
      context.read<BibleProvider>().loadHighlights();
    } else if (index == 3) {
      context.read<TopicsProvider>().loadTopics();
      context.read<DevotionalsProvider>().loadDevotionals();
    } else if (index == 4) {
      context.read<StreaksProvider>().loadStreak();
    }
  }

  void _reloadAllData() {
    context.read<HomeProvider>().loadHomeData();
    context.read<StreaksProvider>().loadStreak();
    context.read<TopicsProvider>().loadTopics();
    context.read<DevotionalsProvider>().loadDevotionals();
    context.read<BibleProvider>().loadHighlights();
    context.read<DeclarationProvider>().loadDeclarations();
    setState(() {
      _currentIndex = 0;
    });
  }

  // Pantallas donde el nav flotante se muestra (Home, Bible library, Explore, You)
  // Declarations (2) maneja su propia navegación con botón de cierre ✕
  static const _showNavOnTabs = {0, 1, 3, 4};

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sessionKey = auth.isAuthenticated
        ? auth.currentSession?.user.id ?? 'user'
        : 'guest';

    final screens = [
      HomeScreen(key: ValueKey('home_$sessionKey')),
      BibleScreen(key: ValueKey('bible_$sessionKey')),
      DeclarationsScreen(key: ValueKey('decl_$sessionKey')),
      TopicsScreen(key: ValueKey('topics_$sessionKey')),
      ProfileScreen(key: ValueKey('profile_$sessionKey')),
    ];

    final isDesktop = AppBreakpoints.isDesktop(context);

    if (isDesktop) {
      return _WebShell(
        currentIndex: _currentIndex,
        screens: screens,
        onTap: changeTab,
      );
    }

    final showNav = _showNavOnTabs.contains(_currentIndex);

    return Scaffold(
      backgroundColor: PColors.ink,
      body: Stack(
        children: [
          // Pantallas en IndexedStack con llaves de sesión dinámicas
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),

          // Nav flotante — solo en las tabs que lo necesitan
          if (showNav)
            PBottomNav(
              currentIndex: _currentIndex,
              onTap: changeTab,
            ),
        ],
      ),
    );
  }
}

/// Web / Desktop Sidebar Shell
class _WebShell extends StatelessWidget {
  const _WebShell({
    required this.currentIndex,
    required this.screens,
    required this.onTap,
  });

  final int currentIndex;
  final List<Widget> screens;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColors.ink,
      body: Row(
        children: [
          WebSideNav(
            currentIndex: currentIndex,
            onTap: onTap,
          ),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
    );
  }
}
