import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui/molecules/auth_prompt_sheet.dart';
import '../../../../core/ui/organisms/main_shell.dart';
import '../../../topics/presentation/providers/topics_provider.dart';
import '../providers/onboarding_provider.dart';

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
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
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
      backgroundColor: AppColors.background,
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

  // ── Step Navigation Bar (Top Bar for steps 2 to 5) ────────────────────────
  Widget _buildTopNavBar({required int stepIndex, VoidCallback? onSkip}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 28, color: AppColors.textPrimary),
            onPressed: _previousPage,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          // Progress Dashes (4 dashes for the 4 questionnaire steps: Name, Gender, Topics, Reminder)
          Row(
            children: List.generate(4, (index) {
              final isActive = index <= stepIndex;
              return Container(
                width: 32,
                height: 2.5,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.boneCard : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          GestureDetector(
            onTap: onSkip ?? _nextPage,
            child: Text(
              'Skip',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 01: Splash Screen ────────────────────────────────────────────────
  Widget _buildStep01Splash() {
    return GestureDetector(
      onTap: _nextPage,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Twilight lake sunrise background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D1B2A),
                    Color(0xFF1B2A38),
                    Color(0xFF2C3E50),
                    Color(0xFF8B5A2B),
                    Color(0xFFE5A855),
                    Color(0xFF0F141C),
                  ],
                  stops: [0.0, 0.45, 0.65, 0.78, 0.88, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  // Abstract PREGARE double arch symbol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(36, 26),
                        painter: _PregareSymbolPainter(),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'PREGARE',
                        style: AppTypography.eyebrow.copyWith(
                          fontSize: 22,
                          letterSpacing: 4.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'A daily space for Scripture, declaration\nand reflection',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(flex: 3),
                  Text(
                    'Tap anywhere to begin',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
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

  // ── Step 02: Welcome Screen ───────────────────────────────────────────────
  Widget _buildStep02Welcome() {
    return Stack(
      children: [
        // Mountain peak atmosphere gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF162024),
                  Color(0xFF233036),
                  Color(0xFF4A4E46),
                  Color(0xFF8A6C4A),
                  Color(0xFF121214),
                ],
                stops: [0.0, 0.35, 0.6, 0.8, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                Text(
                  'WELCOME',
                  style: AppTypography.eyebrow.copyWith(
                    color: Colors.white70,
                    letterSpacing: 2.5,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Begin the day with\nsomething steady.',
                  style: AppTypography.displaySerifLarge.copyWith(
                    fontSize: 34,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Four faith declarations, a two-minute devotional, and the Bible — all in one quiet place.',
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const Spacer(flex: 3),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.boneCard,
                    foregroundColor: AppColors.boneInk,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  ),
                  child: Text(
                    'Start',
                    style: AppTypography.button.copyWith(color: AppColors.boneInk, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _openLogin,
                    child: Text(
                      'Log in',
                      style: AppTypography.button.copyWith(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 03: Name Screen ──────────────────────────────────────────────────
  Widget _buildStep03Name() {
    final provider = context.watch<OnboardingProvider>();

    return SafeArea(
      child: Column(
        children: [
          _buildTopNavBar(stepIndex: 0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "What's your name?",
                    style: AppTypography.displaySerifLarge.copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your declarations are spoken to you by name.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: TextField(
                      controller: _nameController,
                      onChanged: (val) => provider.setName(val),
                      style: AppTypography.headingSerif.copyWith(
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                      cursorColor: AppColors.accent,
                      decoration: InputDecoration(
                        hintText: 'Your name',
                        hintStyle: AppTypography.headingSerif.copyWith(
                          fontSize: 20,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      provider.setName(_nameController.text);
                      _nextPage();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.boneCard,
                      foregroundColor: AppColors.boneInk,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                    ),
                    child: Text(
                      'Next',
                      style: AppTypography.button.copyWith(color: AppColors.boneInk, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'You can change this later in your profile.',
                      style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 04: Content Preference (Gender) ──────────────────────────────────
  Widget _buildStep04ContentPreference() {
    final provider = context.watch<OnboardingProvider>();

    return SafeArea(
      child: Column(
        children: [
          _buildTopNavBar(stepIndex: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Who are your\ndeclarations written\nfor?',
                    style: AppTypography.displaySerifLarge.copyWith(fontSize: 30, height: 1.15),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This shapes the voice and wording only.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.boneCard,
                      foregroundColor: AppColors.boneInk,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                    ),
                    child: Text(
                      'Next',
                      style: AppTypography.button.copyWith(color: AppColors.boneInk, fontSize: 15),
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

  Widget _buildGenderOptionCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.boneCard : AppColors.surfaceBorder,
            width: isSelected ? 1.2 : 0.8,
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
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.boneCard : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.boneCard : AppColors.textTertiary,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: AppColors.boneInk, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 05: Topics Selection ─────────────────────────────────────────────
  Widget _buildStep05Topics() {
    final provider = context.watch<OnboardingProvider>();
    final topicsProvider = context.watch<TopicsProvider>();

    // Load focus areas from DB if not loaded yet
    if (provider.focusAreas.isEmpty && !provider.isLoadingFocusAreas) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.loadFocusAreas();
      });
    }

    // Strengths loaded dynamically 100% from database
    final allTopics = provider.focusAreas.isNotEmpty
        ? provider.focusAreas.map((f) => f.name).toList()
        : topicsProvider.currentTopics.map((t) => t.title).toList();

    return SafeArea(
      child: Column(
        children: [
          _buildTopNavBar(stepIndex: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'What would you like\nto strengthen?',
                    style: AppTypography.displaySerifLarge.copyWith(fontSize: 30, height: 1.15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pick three or more areas to personalize your daily declarations.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: allTopics.map((topic) {
                      final isSelected = provider.isTopicSelected(topic);
                      return GestureDetector(
                        onTap: () => provider.toggleTopic(topic),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.boneCard : AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected ? AppColors.boneCard : AppColors.surfaceBorder,
                            ),
                          ),
                          child: Text(
                            topic,
                            style: AppTypography.bodySmall.copyWith(
                              color: isSelected ? AppColors.boneInk : AppColors.textPrimary,
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
                    style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.boneCard,
                      foregroundColor: AppColors.boneInk,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                    ),
                    child: Text(
                      'Next',
                      style: AppTypography.button.copyWith(color: AppColors.boneInk, fontSize: 15),
                    ),
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

  // ── Step 06: Reminder Screen ──────────────────────────────────────────────
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

    return SafeArea(
      child: Column(
        children: [
          _buildTopNavBar(stepIndex: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'When should we reach\nyou?',
                    style: AppTypography.displaySerifLarge.copyWith(fontSize: 30, height: 1.15),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'One notification a day. Morning, afternoon or night.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Period Pills: Morning / Afternoon / Evening
                  Row(
                    children: ['Morning', 'Afternoon', 'Evening'].map((period) {
                      final isSelected = provider.reminderPeriod == period;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            provider.setReminderPeriod(period);
                            final defaultForPeriod = periodTimes[period]!.first;
                            provider.setReminderTime(defaultForPeriod);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.surfaceElevated : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.surfaceBorder : Colors.transparent,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                period,
                                style: AppTypography.caption.copyWith(
                                  color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Hours Wrap Selector Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$currentPeriod hours',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              provider.reminderTime,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFC8A97E),
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
                            return GestureDetector(
                              onTap: () => provider.setReminderTime(t),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.boneCard : AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected ? AppColors.boneCard : AppColors.surfaceBorder,
                                  ),
                                ),
                                child: Text(
                                  t,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                    color: isSelected ? AppColors.boneInk : AppColors.textPrimary,
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
                  GestureDetector(
                    onTap: () => _pickCustomTime(context, provider),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time_rounded, color: Color(0xFFC8A97E), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Pick any specific time (${provider.reminderTime})',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.boneCard,
                      foregroundColor: AppColors.boneInk,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                    ),
                    child: Text(
                      'Next',
                      style: AppTypography.button.copyWith(color: AppColors.boneInk, fontSize: 15),
                    ),
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
      initialTime: const TimeOfDay(hour: 7, minute: 0),
      builder: (ctx, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFC8A97E),
              onPrimary: Color(0xFF141310),
              surface: Color(0xFF1E1C1A),
              onSurface: Color(0xFFF4F2EC),
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

  // ── Step 07: Ready Screen ─────────────────────────────────────────────────
  Widget _buildStep07Ready() {
    final provider = context.watch<OnboardingProvider>();
    final displayName = provider.getDisplayName() ?? 'Friend';
    final topicsSummary = provider.selectedTopics.take(3).join(', ');

    return Stack(
      children: [
        // Twilight lake sunrise background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF141920),
                  Color(0xFF26333D),
                  Color(0xFF6B482E),
                  Color(0xFFC68B45),
                  Color(0xFF16151A),
                ],
                stops: [0.0, 0.4, 0.65, 0.82, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 3),
                Text(
                  'READY',
                  style: AppTypography.eyebrow.copyWith(
                    color: Colors.white70,
                    letterSpacing: 2.5,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '$displayName, your first\nfour declarations\nare waiting.',
                  style: AppTypography.displaySerifLarge.copyWith(
                    fontSize: 32,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$topicsSummary — every morning at ${provider.reminderTime}.',
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const Spacer(flex: 3),
                ElevatedButton(
                  onPressed: _finishOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16151A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                  ),
                  child: Text(
                    'Enter PREGARE',
                    style: AppTypography.button.copyWith(color: Colors.white, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      AuthPromptSheet.show(
                        context,
                        onSuccess: _finishOnboarding,
                      );
                    },
                    child: Text(
                      'Create account to back up',
                      style: AppTypography.button.copyWith(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for PREGARE flowing arch symbol
class _PregareSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.boneCard
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(4, size.height - 4);
    path.cubicTo(
      size.width * 0.25, 4,
      size.width * 0.35, 4,
      size.width * 0.5, size.height - 8,
    );
    path.cubicTo(
      size.width * 0.65, 4,
      size.width * 0.75, 4,
      size.width - 4, size.height - 4,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
