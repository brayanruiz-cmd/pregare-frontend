import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/home/presentation/screens/home_screen.dart';
import '../../../features/home/presentation/providers/home_provider.dart';
import '../../../features/bible/presentation/screens/bible_screen.dart';
import '../../../features/declarations/presentation/screens/declarations_screen.dart';
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

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void changeTab(int index) {
    setState(() => _currentIndex = index);
    _refreshTab(index);
  }

  void _refreshTab(int index) {
    if (index == 0) {
      context.read<HomeProvider>().loadHomeData();
      context.read<TopicsProvider>().loadTopics();
    } else if (index == 3) {
      context.read<TopicsProvider>().loadTopics();
      context.read<DevotionalsProvider>().loadDevotionals();
    } else if (index == 4) {
      context.read<StreaksProvider>().loadStreak();
    }
  }

  final _screens = const [
    HomeScreen(),
    BibleScreen(),
    DeclarationsScreen(),
    TopicsScreen(),
    ProfileScreen(),
  ];

  // Pantallas donde el nav flotante se muestra (Home, Bible library, Explore, You)
  // Declarations (2) maneja su propia navegación con botón de cierre ✕
  static const _showNavOnTabs = {0, 1, 3, 4};

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);

    if (isDesktop) {
      return _WebShell(
        currentIndex: _currentIndex,
        screens: _screens,
        onTap: changeTab,
      );
    }

    final showNav = _showNavOnTabs.contains(_currentIndex);

    return Scaffold(
      backgroundColor: PColors.ink,
      body: Stack(
        children: [
          // Pantallas en IndexedStack para preservar estado
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Nav flotante — solo en las tabs que lo necesitan
          // Las pantallas de Declarations y sub-flujos de Bible lo ocultan
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
