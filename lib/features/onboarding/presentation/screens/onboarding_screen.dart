import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/molecules/auth_prompt_sheet.dart';
import '../../../../core/ui/organisms/main_shell.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../../../topics/presentation/providers/topics_provider.dart';
import '../providers/onboarding_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Flujo 01 — Onboarding (7 pantallas, sin nav)
//
// 01 Splash: FOTO photo-dusk-water | Wordmark 236px + tagline
// 02 Welcome: FOTO photo-welcome | "Begin the day..." + Start + Log in
// 03 Name: INK | "What's your name?" + hint + Next
// 04 Content preference: INK | For women / For men con ✓ + Next
// 05 Topics: INK | 12 chips + contador + Next
// 06 Reminder: INK | Morning/Afternoon/Evening + selector horario (6:15 AM)
// 07 Ready: FOTO photo-milestone | Resumen + Enter PREGARE
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final provider = context.read<OnboardingProvider>();
    _nameController.text = provider.name;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    HapticFeedback.lightImpact();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextPage() {
    if (_currentPage < 6) {
      _goToPage(_currentPage + 1);
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  Future<void> _finishOnboarding() async {
    HapticFeedback.mediumImpact();
    final provider = context.read<OnboardingProvider>();
    await provider.completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  void _openLogin() {
    AuthPromptSheet.show(context, isLoginOnly: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColors.inkDeep,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          _buildStep01Splash(),
          _buildStep02Welcome(),
          _buildStep03Name(),
          _buildStep04ContentPreference(),
          _buildStep05Topics(),
          _buildStep06Reminder(),
          _buildStep07Ready(),
        ],
      ),
    );
  }

  // ── Top Bar for questionnaire steps (Steps 2 to 5) ─────────────────────────
  Widget _buildTopNavBar({required int stepIndex, VoidCallback? onSkip}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PInteractive(
            onTap: _previousPage,
            tooltip: 'Back',
            builder: (context, isHovered, isPressed) => Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isHovered ? PColors.glassFill : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                size: 26,
                color: PColors.bone,
              ),
            ),
          ),
          // 4 Progress dashes for the 4 questionnaire steps
          Row(
            children: List.generate(4, (index) {
              final isActive = index <= stepIndex;
              return Container(
                width: 28,
                height: 2.5,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: isActive ? PColors.bone : PColors.bone.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          PInteractive(
            onTap: onSkip ?? _nextPage,
            tooltip: 'Skip',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                'Skip',
                style: PType.uiStrong.copyWith(
                  color: PColors.bone50,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Screen 01 — Splash
  // Fondo: FOTO photo-dusk-water + scrim
  // Wordmark PNG a 236px + tagline
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep01Splash() {
    return PScreen(
      background: const PScreenBackground.photo(
        'assets/photo-dusk-water.jpg',
        scrim: PScrims.home,
      ),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      body: GestureDetector(
        onTap: _nextPage,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            const Spacer(flex: 3),
            Center(
              child: Image.asset(
                'assets/wordmark-pregare.png',
                width: 236,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Text(
                  'PREGARE',
                  style: PType.wordmark.copyWith(fontSize: 32, letterSpacing: 4.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'A daily space for Scripture, declaration\nand reflection',
              textAlign: TextAlign.center,
              style: PType.body.copyWith(
                color: PColors.bone70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const Spacer(flex: 3),
            PInteractive(
              onTap: _nextPage,
              child: Text(
                'Tap anywhere to begin',
                style: PType.meta.copyWith(
                  color: PColors.bone50,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Screen 02 — Welcome
  // Fondo: FOTO photo-welcome + scrim
  // "Welcome" / "Begin the day with something steady." / Start + Log in
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep02Welcome() {
    return PScreen(
      background: const PScreenBackground.photo(
        'assets/photo-welcome.jpg',
        scrim: PScrims.home,
      ),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          const PEyebrow('WELCOME'),
          const SizedBox(height: 14),
          Text(
            'Begin the day with\nsomething steady.',
            style: PType.display.copyWith(
              fontSize: 34,
              color: PColors.bone,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Four faith declarations, a two-minute devotional, and the Bible — all in one quiet place.',
            style: PType.body.copyWith(
              color: PColors.bone70,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const Spacer(flex: 3),
          _PrimaryPillButton(
            label: 'Start',
            onTap: _nextPage,
          ),
          const SizedBox(height: 16),
          Center(
            child: PInteractive(
              onTap: _openLogin,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Log in',
                  style: PType.uiStrong.copyWith(
                    color: PColors.bone70,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Screen 03 — Name
  // Fondo: INK plana
  // ‹ + Skip · "What's your name?" · input · hint · Next
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep03Name() {
    final provider = context.watch<OnboardingProvider>();

    return PScreen(
      background: const PScreenBackground.ink(),
      hasNav: false,
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          _buildTopNavBar(stepIndex: 0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  Text(
                    "What's your name?",
                    style: PType.display.copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your declarations are spoken to you by name.',
                    style: PType.body.copyWith(
                      color: PColors.bone70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    decoration: BoxDecoration(
                      color: PColors.glassFill,
                      borderRadius: BorderRadius.circular(PRadius.chip),
                      border: Border.all(color: PColors.glassStroke),
                    ),
                    child: TextField(
                      controller: _nameController,
                      onChanged: (val) => provider.setName(val),
                      style: PType.cardTitle.copyWith(
                        fontSize: 20,
                        color: PColors.bone,
                      ),
                      cursorColor: PColors.bone,
                      decoration: InputDecoration(
                        hintText: 'Your name',
                        hintStyle: PType.cardTitle.copyWith(
                          fontSize: 20,
                          color: PColors.bone45,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _PrimaryPillButton(
                    label: 'Next',
                    onTap: () {
                      provider.setName(_nameController.text);
                      _nextPage();
                    },
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'You can change this later in your profile.',
                      style: PType.meta.copyWith(color: PColors.bone50),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Screen 04 — Content Preference (Gender)
  // Fondo: INK plana
  // "Who are your declarations written for?" · For women / For men + Next
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep04ContentPreference() {
    final provider = context.watch<OnboardingProvider>();

    return PScreen(
      background: const PScreenBackground.ink(),
      hasNav: false,
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          _buildTopNavBar(stepIndex: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  Text(
                    'Who are your\ndeclarations written\nfor?',
                    style: PType.display.copyWith(fontSize: 30, height: 1.15),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This shapes the voice and wording only.',
                    style: PType.body.copyWith(
                      color: PColors.bone70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _buildGenderOptionCard(
                    title: 'For women',
                    subtitle: 'Written in her voice',
                    isSelected: provider.gender == 'mujeres',
                    onTap: () => provider.setGender('mujeres'),
                  ),
                  const SizedBox(height: 16),
                  _buildGenderOptionCard(
                    title: 'For men',
                    subtitle: 'Written in his voice',
                    isSelected: provider.gender == 'hombres',
                    onTap: () => provider.setGender('hombres'),
                  ),
                  const Spacer(),
                  _PrimaryPillButton(
                    label: 'Next',
                    onTap: _nextPage,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOptionCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return PInteractive(
      onTap: onTap,
      pressedScale: 0.985,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? PColors.glassFill.withValues(alpha: 0.25) : PColors.glassFill,
          borderRadius: BorderRadius.circular(PRadius.tile),
          border: Border.all(
            color: isSelected ? PColors.bone : PColors.glassStroke,
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PType.uiStrong.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: PColors.bone,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: PType.meta.copyWith(color: PColors.bone50),
                ),
              ],
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? PColors.bone : Colors.transparent,
                border: Border.all(
                  color: isSelected ? PColors.bone : PColors.bone50,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: PColors.ink, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Screen 05 — Topics
  // Fondo: INK plana
  // "What would you like to strengthen?" · 12 chips · contador · Next
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep05Topics() {
    final provider = context.watch<OnboardingProvider>();
    final topicsProvider = context.watch<TopicsProvider>();

    if (provider.focusAreas.isEmpty && !provider.isLoadingFocusAreas) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.loadFocusAreas();
      });
    }

    final allTopics = provider.focusAreas.isNotEmpty
        ? provider.focusAreas.map((f) => f.name).toList()
        : topicsProvider.currentTopics.map((t) => t.title).toList();

    return PScreen(
      background: const PScreenBackground.ink(),
      hasNav: false,
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          _buildTopNavBar(stepIndex: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'What would you like\nto strengthen?',
                    style: PType.display.copyWith(fontSize: 30, height: 1.15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pick three or more areas to personalize your daily declarations.',
                    style: PType.body.copyWith(
                      color: PColors.bone70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: allTopics.map((topic) {
                      final isSelected = provider.isTopicSelected(topic);
                      return PInteractive(
                        onTap: () => provider.toggleTopic(topic),
                        pressedScale: 0.96,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? PColors.bone : PColors.glassFill,
                            borderRadius: BorderRadius.circular(PRadius.chip),
                            border: Border.all(
                              color: isSelected ? PColors.bone : PColors.glassStroke,
                            ),
                          ),
                          child: Text(
                            topic,
                            style: PType.uiStrong.copyWith(
                              color: isSelected ? PColors.ink : PColors.bone,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    '${provider.selectedTopics.length} selected',
                    style: PType.counter.copyWith(color: PColors.bone62),
                  ),
                  const SizedBox(height: 16),
                  _PrimaryPillButton(
                    label: 'Next',
                    onTap: _nextPage,
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Screen 06 — Reminder
  // Fondo: INK plana
  // Segmented Morning/Afternoon/Evening · selector horario (6:15 AM) · Next
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep06Reminder() {
    final provider = context.watch<OnboardingProvider>();

    final Map<String, List<String>> periodTimes = {
      'Morning': [
        '5:00 AM', '5:30 AM', '6:00 AM', '6:15 AM', '6:30 AM', '6:45 AM',
        '7:00 AM', '7:30 AM', '8:00 AM', '8:30 AM', '9:00 AM', '9:30 AM',
        '10:00 AM', '10:30 AM', '11:00 AM',
      ],
      'Afternoon': [
        '12:00 PM', '12:30 PM', '1:00 PM', '1:30 PM', '2:00 PM', '2:30 PM',
        '3:00 PM', '3:30 PM', '4:00 PM', '4:30 PM', '5:00 PM', '5:30 PM',
      ],
      'Evening': [
        '6:00 PM', '6:30 PM', '7:00 PM', '7:30 PM', '8:00 PM', '8:30 PM',
        '9:00 PM', '9:30 PM', '10:00 PM', '10:30 PM', '11:00 PM',
      ],
    };

    final currentPeriod = provider.reminderPeriod;
    final availableTimes = List<String>.from(periodTimes[currentPeriod] ?? periodTimes['Morning']!);
    if (!availableTimes.contains(provider.reminderTime)) {
      availableTimes.insert(0, provider.reminderTime);
    }

    return PScreen(
      background: const PScreenBackground.ink(),
      hasNav: false,
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          _buildTopNavBar(stepIndex: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'When should we reach\nyou?',
                    style: PType.display.copyWith(fontSize: 30, height: 1.15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'One notification a day. Nothing else.',
                    style: PType.body.copyWith(
                      color: PColors.bone70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Segmented Morning / Afternoon / Evening
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: PColors.glassFill,
                      borderRadius: BorderRadius.circular(PRadius.chip),
                      border: Border.all(color: PColors.hairline),
                    ),
                    child: Row(
                      children: ['Morning', 'Afternoon', 'Evening'].map((period) {
                        final isSelected = provider.reminderPeriod == period;
                        return Expanded(
                          child: PInteractive(
                            onTap: () {
                              provider.setReminderPeriod(period);
                              final defaultForPeriod = periodTimes[period]!.first;
                              provider.setReminderTime(defaultForPeriod);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? PColors.bone : Colors.transparent,
                                borderRadius: BorderRadius.circular(PRadius.chip - 2),
                              ),
                              child: Center(
                                child: Text(
                                  period,
                                  style: PType.uiStrong.copyWith(
                                    fontSize: 12.5,
                                    color: isSelected ? PColors.ink : PColors.bone62,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Hours Selector Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: PColors.glassFill,
                      borderRadius: BorderRadius.circular(PRadius.tile),
                      border: Border.all(color: PColors.hairline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$currentPeriod hours',
                              style: PType.meta.copyWith(color: PColors.bone62),
                            ),
                            const Spacer(),
                            Text(
                              provider.reminderTime,
                              style: PType.uiStrong.copyWith(
                                fontSize: 15,
                                color: const Color(0xFFD4AF37),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          children: availableTimes.map((t) {
                            final isSelected = provider.reminderTime == t;
                            return PInteractive(
                              onTap: () => provider.setReminderTime(t),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? PColors.bone : PColors.glassFill,
                                  borderRadius: BorderRadius.circular(PRadius.chip),
                                  border: Border.all(
                                    color: isSelected ? PColors.bone : PColors.glassStroke,
                                  ),
                                ),
                                child: Text(
                                  t,
                                  style: PType.uiStrong.copyWith(
                                    fontSize: 12.5,
                                    color: isSelected ? PColors.ink : PColors.bone,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pick Custom Time button
                  PInteractive(
                    onTap: () => _pickCustomTime(context, provider),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: PColors.glassFill,
                        borderRadius: BorderRadius.circular(PRadius.tile),
                        border: Border.all(color: PColors.hairline),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time_rounded, color: Color(0xFFD4AF37), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Pick any specific time (${provider.reminderTime})',
                            style: PType.uiStrong.copyWith(
                              color: PColors.bone,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  _PrimaryPillButton(
                    label: 'Next',
                    onTap: _nextPage,
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCustomTime(BuildContext context, OnboardingProvider provider) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 6, minute: 15),
      builder: (ctx, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: PColors.bone,
              onPrimary: PColors.ink,
              surface: PColors.ink,
              onSurface: PColors.bone,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      final formatted = '$hour:$minute $period';

      provider.setReminderTime(formatted);
      if (picked.hour < 12) {
        provider.setReminderPeriod('Morning');
      } else if (picked.hour < 18) {
        provider.setReminderPeriod('Afternoon');
      } else {
        provider.setReminderPeriod('Evening');
      }
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Screen 07 — Ready
  // Fondo: FOTO photo-milestone + scrim
  // "Ready" · "Sarah, your first four declarations are waiting." · Enter PREGARE
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep07Ready() {
    final provider = context.watch<OnboardingProvider>();
    final displayName = provider.getDisplayName() ?? 'Friend';
    final topicsSummary = provider.selectedTopics.take(3).join(', ');

    return PScreen(
      background: const PScreenBackground.photo(
        'assets/photo-milestone.jpg',
        scrim: PScrims.home,
      ),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 3),
          const PEyebrow('READY'),
          const SizedBox(height: 14),
          Text(
            '$displayName, your first\nfour declarations\nare waiting.',
            style: PType.display.copyWith(
              fontSize: 32,
              color: PColors.bone,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$topicsSummary — every morning at ${provider.reminderTime}.',
            style: PType.body.copyWith(
              color: PColors.bone70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const Spacer(flex: 3),
          _PrimaryPillButton(
            label: 'Enter PREGARE',
            onTap: _finishOnboarding,
          ),
          const SizedBox(height: 16),
          Center(
            child: PInteractive(
              onTap: () {
                AuthPromptSheet.show(
                  context,
                  onSuccess: _finishOnboarding,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Create account to back up',
                  style: PType.uiStrong.copyWith(
                    color: PColors.bone70,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Pill Button for Onboarding (Height 52, Pill shape, PColors.bone)
// ─────────────────────────────────────────────────────────────────────────────
class _PrimaryPillButton extends StatelessWidget {
  const _PrimaryPillButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PInteractive(
      onTap: onTap,
      pressedScale: 0.985,
      hoverScale: 1.01,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: PColors.bone,
          borderRadius: BorderRadius.circular(PRadius.pill),
        ),
        child: Text(
          label,
          style: PType.uiStrong.copyWith(
            color: PColors.ink,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
