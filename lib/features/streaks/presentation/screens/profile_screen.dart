import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/organisms/main_shell.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../../../../core/ui/molecules/auth_prompt_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../domain/models/streak_activity.dart';
import '../../domain/models/user_badge_model.dart';
import '../providers/streaks_provider.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../topics/presentation/providers/topics_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pantalla 23 — Profile / You
// Fondo: INK · Con nav flotante
// ─────────────────────────────────────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final onboarding = context.watch<OnboardingProvider>();
    final streaks = context.watch<StreaksProvider>();
    final streak = streaks.currentStreak;

    final rawName =
        auth.currentSession?.user.name ?? onboarding.getDisplayName();
    final name =
        (rawName != null && rawName.isNotEmpty) ? rawName : 'Invitado';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    final isAuthenticated = auth.isAuthenticated;

    return PScreen(
      background: const PScreenBackground.ink(),
      hasNav: true,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      floatingWidget: PBottomNav(
        currentIndex: 4,
        onTap: (i) => MainShell.setTab(context, i),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 16),

          // ── Avatar + nombre ────────────────────────────────────────────
          GestureDetector(
            onTap: isAuthenticated ? null : () => AuthPromptSheet.show(context),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: PColors.glassFill,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: PType.greeting.copyWith(
                        fontSize: 22,
                        color: PColors.bone,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: PType.display.copyWith(fontSize: 22)),
                    const SizedBox(height: 3),
                    Text(
                      isAuthenticated
                          ? (auth.currentSession?.user.email ?? 'With PREGARE')
                          : 'Guest mode · Tap to create account',
                      style: PType.meta.copyWith(
                        color: isAuthenticated ? PColors.stone : PColors.clay,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Tarjeta de stats conectada a StreaksProvider ──────────────
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GrowthScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: PColors.glassFill,
                borderRadius: BorderRadius.circular(PRadius.panel),
                border: Border.all(color: PColors.hairline, width: 1.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatColumn(
                    number: '${streak?.currentStreak ?? 0}',
                    label: 'Day streak',
                  ),
                  Container(width: 1, height: 28, color: PColors.hairline),
                  _StatColumn(
                    number: '${streak?.longestStreak ?? 0}',
                    label: 'Best',
                  ),
                  Container(width: 1, height: 28, color: PColors.hairline),
                  _StatColumn(
                    number: '${streak?.totalDaysActive ?? 0}',
                    label: 'Total days',
                  ),
                ],
              ),
            ),
          ),
          // ── ADMIN STUDIO HERO CARD (ONLY FOR ADMIN USERS) ────────────
          if (auth.currentSession?.user.isAdmin == true) ...[
            const _AdminStudioHeroCard(),
            const SizedBox(height: 36),
          ],

          // ── Sección SAVED (conteos reales de la base de datos) ─────────
          const PEyebrow('Saved'),
          const SizedBox(height: 4),
          PListRow(
            title: 'Saved declarations',
            trailing: Text(
              '${streak?.savedDeclarationsCount ?? 0}',
              style: PType.meta.copyWith(color: PColors.bone55),
            ),
          ),
          PListRow(
            title: 'Highlights',
            trailing: Text(
              '${streak?.highlightsCount ?? 0}',
              style: PType.meta.copyWith(color: PColors.bone55),
            ),
          ),
          PListRow(
            title: 'Completed devotionals',
            trailing: Text(
              '${streak?.completedDevotionalsCount ?? 0}',
              style: PType.meta.copyWith(color: PColors.bone55),
            ),
          ),
          const SizedBox(height: 36),

          // ── Badges & Achievements ─────────────────────────────────────
          const PEyebrow('Achievements'),
          const SizedBox(height: 14),
          _BadgesSection(),
          const SizedBox(height: 36),

          // ── Sección SETTINGS ───────────────────────────────────────────
          const PEyebrow('Settings'),

          const SizedBox(height: 4),
          PListRow(
            title: 'Preferences',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PreferencesScreen()),
              );
            },
          ),
          PListRow(
            title: 'Notifications',
            meta: onboarding.reminderTime,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PreferencesScreen()),
              );
            },
          ),
          if (isAuthenticated)
            PListRow(
              title: 'Log out',
              meta: auth.currentSession?.user.email ?? '',
              trailing: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEF4444),
                size: 18,
              ),
              onTap: () => _confirmLogout(context),
            )
          else
            PListRow(
              title: 'Sign in / Create account',
              meta: 'Sync your data and streak',
              trailing: const Icon(
                Icons.arrow_forward_rounded,
                color: PColors.clay,
                size: 18,
              ),
              onTap: () => AuthPromptSheet.show(context),
            ),
          const SizedBox(height: PSpace.navClearance),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: PColors.inkDeep,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PRadius.panel),
          side: const BorderSide(color: PColors.hairline),
        ),
        title: Text(
          'Log out',
          style: PType.rowTitle.copyWith(fontSize: 18, color: PColors.bone),
        ),
        content: Text(
          'Are you sure you want to log out of PREGARE?',
          style: PType.body.copyWith(color: PColors.bone70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(
              'Cancel',
              style: PType.uiStrong.copyWith(color: PColors.bone62),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              'Log out',
              style: PType.uiStrong.copyWith(color: const Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        context.read<HomeProvider>().loadHomeData();
        context.read<TopicsProvider>().loadTopics();
        context.read<StreaksProvider>().loadStreak();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: PColors.ink,
          ),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Admin Studio Hero Card — Visible ONLY for users with 'admin' role
// ─────────────────────────────────────────────────────────────────────────────
class _AdminStudioHeroCard extends StatelessWidget {
  const _AdminStudioHeroCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PRadius.card),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF281E15), // Warm bronze / amber
              Color(0xFF151311), // Deep obsidian
            ],
          ),
          border: Border.all(
            color: const Color(0x66C8A97E), // Warm metallic gold/clay border
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x388A6A4E),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Ambient glow in corner
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x14C8A97E),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header badge + active status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x33C8A97E),
                          borderRadius: BorderRadius.circular(PRadius.chip),
                          border: Border.all(
                            color: const Color(0x66C8A97E),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Color(0xFFE8C89A),
                              size: 12,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'ADMIN ACCESS',
                              style: PType.eyebrow.copyWith(
                                color: const Color(0xFFE8C89A),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Active',
                        style: PType.meta.copyWith(
                          color: PColors.bone55,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title + Arrow CTA
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Studio',
                              style: PType.display.copyWith(
                                fontSize: 24,
                                color: PColors.bone,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Manage YouTube topics, devotionals & app content in real-time.',
                              style: PType.meta.copyWith(
                                color: PColors.bone70,
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0x33C8A97E),
                          border: Border.all(
                            color: const Color(0x80C8A97E),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFFE8C89A),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.number, required this.label});
  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(number, style: PType.display.copyWith(fontSize: 26, height: 1.0)),
        const SizedBox(height: 4),
        Text(label, style: PType.meta.copyWith(fontSize: 12, color: PColors.bone55)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pantalla 24 — Preferences
// ─────────────────────────────────────────────────────────────────────────────
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  double _textSize = 0.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingProvider>();
    final notifProvider = context.watch<NotificationsProvider>();
    final notifPrefs = notifProvider.currentPreferences;

    final genderLabel = onboarding.gender == 'hombres' ? 'Men' : 'Women';
    final topics = onboarding.selectedTopics.isNotEmpty
        ? onboarding.selectedTopics
        : ['Faith', 'Strength', 'Peace'];

    return PScreen(
      background: const PScreenBackground.ink(),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      header: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: PColors.bone,
                size: 28,
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Preferences',
                  style: TextStyle(
                    color: PColors.bone,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Hanken Grotesk',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Declarations ───────────────────────────────────────────────
          const PEyebrow('Declarations'),
          const SizedBox(height: 4),
          PListRow(
            title: 'Written for',
            meta: genderLabel,
            onTap: () {
              final newGender =
                  onboarding.gender == 'mujeres' ? 'hombres' : 'mujeres';
              onboarding.setGender(newGender);
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Topics', style: PType.rowTitle),
              Text(
                '${topics.length} selected',
                style: PType.uiStrong.copyWith(color: PColors.bone70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topics.map((t) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: PColors.glassFill,
                  borderRadius: BorderRadius.circular(PRadius.chip),
                  border: Border.all(color: PColors.hairline),
                ),
                child: Text(t, style: PType.meta.copyWith(color: PColors.bone)),
              );
            }).toList(),
          ),
          const SizedBox(height: 36),

          // ── Reading ────────────────────────────────────────────────────
          const PEyebrow('Reading'),
          const SizedBox(height: 4),
          PListRow(title: 'Bible translation', meta: 'NIV'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Text size', style: PType.rowTitle),
              Text(
                _textSize < 0.33
                    ? 'Small'
                    : _textSize < 0.66
                        ? 'Medium'
                        : 'Large',
                style: PType.meta,
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              thumbColor: PColors.bone,
              activeTrackColor: PColors.bone70,
              inactiveTrackColor: PColors.bone45,
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: _textSize,
              onChanged: (val) => setState(() => _textSize = val),
            ),
          ),
          const SizedBox(height: 36),

          // ── Daily Reminder ─────────────────────────────────────────────
          const PEyebrow('Daily Reminder'),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(vertical: PSpace.rowPaddingY),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: PColors.hairline, width: 1.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Morning notification', style: PType.rowTitle),
                Switch(
                  value: notifPrefs?.declarations ?? true,
                  onChanged: (val) {
                    notifProvider.updatePreference(declarations: val);
                  },
                  activeThumbColor: PColors.bone,
                  activeTrackColor: PColors.bone50,
                  inactiveThumbColor: PColors.bone45,
                  inactiveTrackColor: PColors.glassFill,
                ),
              ],
            ),
          ),
          PListRow(
            title: 'Time',
            meta: notifPrefs?.reminderTime ?? onboarding.reminderTime,
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: PSpace.rowPaddingY),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: PColors.hairline, width: 1.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Streak reminder', style: PType.rowTitle),
                Switch(
                  value: notifPrefs?.streakReminder ?? true,
                  onChanged: (val) {
                    notifProvider.updatePreference(streakReminder: val);
                  },
                  activeThumbColor: PColors.bone,
                  activeTrackColor: PColors.bone50,
                  inactiveThumbColor: PColors.bone45,
                  inactiveTrackColor: PColors.glassFill,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pantalla 25 — Growth
// Fondo: FOTO photo-milestone · Sin nav
// ─────────────────────────────────────────────────────────────────────────────
class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StreaksProvider>().loadMonthActivity();
    });
  }

  static String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return (month >= 1 && month <= 12) ? months[month - 1] : 'Month';
  }

  @override
  Widget build(BuildContext context) {
    final streaks = context.watch<StreaksProvider>();
    final streak = streaks.currentStreak;
    final activity = streaks.currentMonthActivity;

    final currentStreak = streak?.currentStreak ?? 0;
    final longestStreak = streak?.longestStreak ?? 0;
    final totalDays = streak?.totalDaysActive ?? 0;
    final declSpoken = streak?.declarationsSpoken ?? 0;
    final chaptersRead = streak?.chaptersRead ?? 0;

    final now = DateTime.now();
    final monthName = activity != null && activity.monthName.isNotEmpty
        ? activity.monthName
        : _getMonthName(now.month);
    final totalDaysInMonth =
        activity?.totalDaysInMonth ?? DateTime(now.year, now.month + 1, 0).day;
    final activeDaysCount = activity?.activeDaysCount ?? (currentStreak > 0 ? 1 : 0);

    return PScreen(
      background: const PScreenBackground.photo(
        'assets/photo-milestone.jpg',
        scrim: PScrims.home,
      ),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 12),

          // ── Cabecera ──────────────────────────────────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: PColors.bone,
                  size: 28,
                ),
              ),
              const Spacer(),
              Text('Your growth', style: PType.uiStrong),
              const Spacer(),
              const SizedBox(width: 28),
            ],
          ),
          const SizedBox(height: 36),

          // ── Eyebrow ───────────────────────────────────────────────────
          const PEyebrow('You are building something'),
          const SizedBox(height: 12),

          // ── Número grande real ─────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$currentStreak',
                style: PType.display.copyWith(fontSize: 64, height: 1.0),
              ),
              const SizedBox(width: 14),
              Text(
                currentStreak == 1 ? 'day active' : 'days in a row',
                style: PType.body.copyWith(
                  color: PColors.bone70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Copy editorial con números reales ─────────────────────────
          Text(
            'Best stretch $longestStreak days · $totalDays days total. Miss a day and none of this resets.',
            style: PType.body,
          ),
          const SizedBox(height: 32),

          // ── Calendario mensual real desde la base de datos ────────────
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: PColors.glassFill,
              borderRadius: BorderRadius.circular(PRadius.panel),
              border: Border.all(color: PColors.glassStroke, width: 1.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PEyebrow(monthName),
                    Text(
                      '$activeDaysCount of $totalDaysInMonth days',
                      style: PType.meta,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _MonthDotGrid(activity: activity),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // ── Métricas inferiores reales ────────────────────────────────
          PListRow(
            title: 'Declarations spoken',
            meta: '',
            showChevron: false,
            trailing: Text(
              '$declSpoken',
              style: PType.display.copyWith(fontSize: 22, color: PColors.bone70),
            ),
          ),
          PListRow(
            title: 'Chapters read',
            meta: '',
            showChevron: false,
            trailing: Text(
              '$chaptersRead',
              style: PType.display.copyWith(fontSize: 22, color: PColors.bone70),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _MonthDotGrid extends StatelessWidget {
  const _MonthDotGrid({required this.activity});
  final MonthActivity? activity;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totalDays =
        activity?.totalDaysInMonth ?? DateTime(now.year, now.month + 1, 0).day;
    final activeDates = activity?.activeDates ?? [];
    final todayDay = now.day;
    final currentYearMonth =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final numRows = (totalDays / 7).ceil();

    return Column(
      children: List.generate(numRows, (row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (col) {
              final dayNumber = row * 7 + col + 1;
              if (dayNumber > totalDays) {
                return const SizedBox(width: 22, height: 22);
              }

              final dateString =
                  '$currentYearMonth-${dayNumber.toString().padLeft(2, '0')}';
              final isToday = dayNumber == todayDay;
              final isActive = activeDates.contains(dateString);

              if (isToday) {
                return Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? PColors.bone : Colors.transparent,
                    border: Border.all(color: PColors.bone, width: 1.5),
                  ),
                );
              }

              return Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? PColors.bone70 : PColors.glassFill,
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badges & Achievements Section
// Horizontal scroll of badge cards — data from StreaksProvider (backend)
// ─────────────────────────────────────────────────────────────────────────────
class _BadgesSection extends StatelessWidget {
  const _BadgesSection();

  @override
  Widget build(BuildContext context) {
    final streaks = context.watch<StreaksProvider>();
    final badges = streaks.currentBadges;

    if (badges.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: PColors.glassFill,
          borderRadius: BorderRadius.circular(PRadius.tile),
        ),
        child: const Center(
          child: PEyebrow('Completing devotionals unlocks badges'),
        ),
      );
    }

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: badges.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _BadgeCard(badge: badges[i]),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});
  final UserBadgeModel badge;

  @override
  Widget build(BuildContext context) {
    final isUnlocked = badge.isUnlocked;
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? const Color(0xFF1A2A1A)    // dark green tint for unlocked
            : PColors.glassFill,
        borderRadius: BorderRadius.circular(PRadius.tile),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFF2D6A4F).withValues(alpha: 0.6)
              : PColors.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon row ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                badge.icon,
                style: TextStyle(
                  fontSize: 22,
                  color: isUnlocked ? null : const Color.fromRGBO(255, 255, 255, 0.3),
                ),
              ),
              if (isUnlocked)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF52B788),
                  size: 14,
                )
              else
                const Icon(
                  Icons.lock_outline_rounded,
                  color: PColors.bone45,
                  size: 14,
                ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Title ─────────────────────────────────────────
          Expanded(
            child: Text(
              badge.title,
              style: PType.meta.copyWith(
                color: isUnlocked ? PColors.bone : PColors.bone45,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),

          // ── Progress bar ──────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: badge.progress,
              backgroundColor: PColors.bone50,
              valueColor: AlwaysStoppedAnimation<Color>(
                isUnlocked
                    ? const Color(0xFF52B788)
                    : const Color(0xFFD4A853),
              ),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}
