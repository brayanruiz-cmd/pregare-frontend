import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/molecules/auth_prompt_sheet.dart';
import '../../../../core/ui/organisms/main_shell.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../streaks/presentation/providers/streaks_provider.dart';
import '../../domain/models/declaration.dart';
import '../../domain/models/topic_labels.dart';
import '../providers/declaration_provider.dart';

// ─── Flow 04 States (Screens 14, 15/16, 18) ──────────────────────────────────
enum _DeclarationFlowState {
  intro, // Screen 14: Daily introduction
  flip, // Screen 15 & 16: Declaration card with 3D Flip
  completed, // Screen 18: Completed 4/4
}

// ─── Local item model for UI & Sharing ───────────────────────────────────────
class DeclarationItem {
  final String scriptureText;
  final String scriptureRef;
  final String declarationText;
  final String topic;
  final int dayNumber;
  final String gender;
  final int stepIndex; // 0..3

  const DeclarationItem({
    required this.scriptureText,
    required this.scriptureRef,
    required this.declarationText,
    required this.topic,
    required this.dayNumber,
    required this.gender,
    this.stepIndex = 0,
  });
}

// ─── Main Declarations Screen ────────────────────────────────────────────────
class DeclarationsScreen extends StatefulWidget {
  const DeclarationsScreen({super.key});

  @override
  State<DeclarationsScreen> createState() => _DeclarationsScreenState();
}

class _DeclarationsScreenState extends State<DeclarationsScreen> {
  _DeclarationFlowState _flowState = _DeclarationFlowState.intro;
  int _cardIndex = 0;

  // Track proclaimed status per gender so switching genders preserves both!
  final Set<String> _proclaimedGenders = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final provider = context.read<DeclarationProvider>();
      final streaks = context.read<StreaksProvider>();

      streaks.loadProclaimedDeclarations();

      String targetGender = provider.selectedGender;
      final userGender = auth.currentSession?.user.gender;
      if (userGender != null && userGender.isNotEmpty) {
        if (userGender.toLowerCase().startsWith('h') ||
            userGender.toLowerCase().contains('men') ||
            userGender.toLowerCase() == 'male') {
          targetGender = 'hombres';
        } else {
          targetGender = 'mujeres';
        }
      }

      provider.loadTodayDeclaration(gender: targetGender);
      provider.loadDeclarations();

      // Check if already proclaimed today
      _checkProclaimedStatus(targetGender);
    });
  }

  void _checkProclaimedStatus(String gender) {
    final streaks = context.read<StreaksProvider>();
    final provider = context.read<DeclarationProvider>();
    final decl = provider.todayDeclaration;

    final isAlreadyProclaimed = (decl != null &&
            (streaks.proclaimedDeclarationIds.contains(decl.id.toString()) ||
                (decl.dayNumber != null &&
                    (streaks.proclaimedDeclarationIds
                            .contains('${decl.gender}_${decl.dayNumber}') ||
                        streaks.proclaimedDeclarationIds.contains(
                            '${decl.gender}_day_${decl.dayNumber}'))))) ||
        _proclaimedGenders.contains(gender);

    if (isAlreadyProclaimed && _flowState == _DeclarationFlowState.intro) {
      setState(() {
        _flowState = _DeclarationFlowState.completed;
      });
    }
  }

  void _onGenderChanged(String newGender) {
    final provider = context.read<DeclarationProvider>();
    provider.setGender(newGender);
    setState(() {
      _cardIndex = 0;
    });

    final streaks = context.read<StreaksProvider>();
    final decl = provider.todayDeclaration;
    final isAlreadyProclaimed = (decl != null &&
            (streaks.proclaimedDeclarationIds.contains(decl.id.toString()) ||
                (decl.dayNumber != null &&
                    (streaks.proclaimedDeclarationIds
                            .contains('${decl.gender}_${decl.dayNumber}') ||
                        streaks.proclaimedDeclarationIds.contains(
                            '${decl.gender}_day_${decl.dayNumber}'))))) ||
        _proclaimedGenders.contains(newGender);

    setState(() {
      _flowState = isAlreadyProclaimed
          ? _DeclarationFlowState.completed
          : _DeclarationFlowState.intro;
    });
  }

  void _exitToHome() {
    MainShell.setTab(context, 0);
  }

  void _openShareModal(DeclarationItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareModal(item: item),
    );
  }

  void _copyToClipboard(DeclarationItem item) {
    final text =
        '«${item.declarationText}»\n\n${item.scriptureRef}\n"${item.scriptureText}"\n\n— Via Pregare';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Declaration copied to clipboard',
          style: PType.body.copyWith(color: PColors.bone, fontSize: 13),
        ),
        backgroundColor: PColors.ink,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleProclaim(Declaration declaration, String gender) {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      AuthPromptSheet.show(
        context,
        isLoginOnly: false,
        onSuccess: () => _proclaimOnBackend(declaration, gender),
      );
      return;
    }
    _proclaimOnBackend(declaration, gender);
  }

  Future<void> _proclaimOnBackend(Declaration declaration, String gender) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _proclaimedGenders.add(gender);
      _flowState = _DeclarationFlowState.completed;
    });

    final streaks = context.read<StreaksProvider>();
    await streaks.proclaimDeclaration(declaration.id.toString());
  }

  DeclarationItem _buildItem(Declaration d, {int step = 0}) {
    final topicKey = d.topics.isNotEmpty ? d.topics.first : '';
    final topicName =
        topicLabels[topicKey] ?? (topicKey.isNotEmpty ? topicKey : 'Faith');
    return DeclarationItem(
      scriptureText: d.verse,
      scriptureRef: d.reference,
      declarationText: d.text,
      topic: topicName,
      dayNumber: d.dayNumber ?? 1,
      gender: d.gender,
      stepIndex: step,
    );
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, ${now.day} $month';
  }

  String _wordForIndex(int index) {
    switch (index) {
      case 0:
        return 'one';
      case 1:
        return 'two';
      case 2:
        return 'three';
      case 3:
        return 'four';
      default:
        return '${index + 1}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeclarationProvider>();
    final streaks = context.watch<StreaksProvider>();
    final currentGender = provider.selectedGender;
    final primaryDeclaration = provider.todayDeclaration;

    final isProclaimed = (primaryDeclaration != null &&
            (streaks.proclaimedDeclarationIds
                    .contains(primaryDeclaration.id.toString()) ||
                (primaryDeclaration.dayNumber != null &&
                    (streaks.proclaimedDeclarationIds.contains(
                            '${primaryDeclaration.gender}_${primaryDeclaration.dayNumber}') ||
                        streaks.proclaimedDeclarationIds.contains(
                            '${primaryDeclaration.gender}_day_${primaryDeclaration.dayNumber}'))))) ||
        _proclaimedGenders.contains(currentGender);

    final state = provider.todayState;

    if (state is AsyncLoading && provider.todayDeclaration == null) {
      return const Scaffold(
        backgroundColor: PColors.inkDeep,
        body: Center(
          child: CircularProgressIndicator(color: PColors.bone),
        ),
      );
    }

    if (state is AsyncError && provider.todayDeclaration == null) {
      return PScreen(
        background: const PScreenBackground.photo('assets/photo-dawn.jpg',
            scrim: PScrims.home),
        hasNav: false,
        padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  _HeaderIconButton(
                    icon: Icons.close_rounded,
                    onTap: _exitToHome,
                    tooltip: 'Back to home',
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PEyebrow('No declarations available'),
                      const SizedBox(height: 8),
                      Text(
                        'Could not connect to server',
                        style: PType.body.copyWith(
                            color: PColors.bone70, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      _PrimaryButton(
                        label: 'Retry',
                        onTap: () {
                          provider.loadTodayDeclaration(forceReload: true);
                          provider.loadDeclarations();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (primaryDeclaration == null) {
      return const Scaffold(
        backgroundColor: PColors.inkDeep,
        body: Center(child: CircularProgressIndicator(color: PColors.bone)),
      );
    }

    // Build the list of up to 4 declarations for today
    final List<Declaration> declarationsList =
        provider.currentDeclarations.isNotEmpty
            ? provider.currentDeclarations
            : [primaryDeclaration];

    final int totalDeclarations = declarationsList.length > 4 ? 4 : declarationsList.length;
    final int activeCardIndex =
        _cardIndex.clamp(0, totalDeclarations > 0 ? totalDeclarations - 1 : 0);
    final activeDecl = declarationsList[activeCardIndex];
    final activeItem = _buildItem(activeDecl, step: activeCardIndex);

    // Pick background photo based on screen state
    final bgPhoto = _flowState == _DeclarationFlowState.intro
        ? 'assets/photo-dawn.jpg'
        : 'assets/photo-declarations.jpg';

    return PScreen(
      background: PScreenBackground.photo(bgPhoto, scrim: PScrims.home),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: _buildFlowBody(
              flowState: _flowState,
              currentGender: currentGender,
              totalDeclarations: totalDeclarations,
              activeCardIndex: activeCardIndex,
              activeDecl: activeDecl,
              activeItem: activeItem,
              isProclaimed: isProclaimed,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlowBody({
    required _DeclarationFlowState flowState,
    required String currentGender,
    required int totalDeclarations,
    required int activeCardIndex,
    required Declaration activeDecl,
    required DeclarationItem activeItem,
    required bool isProclaimed,
  }) {
    switch (flowState) {
      case _DeclarationFlowState.intro:
        return _buildScreen14Intro(
          currentGender: currentGender,
          totalDeclarations: totalDeclarations,
        );
      case _DeclarationFlowState.flip:
        return _buildScreen15Flip(
          currentGender: currentGender,
          totalDeclarations: totalDeclarations,
          activeCardIndex: activeCardIndex,
          activeDecl: activeDecl,
          activeItem: activeItem,
          isProclaimed: isProclaimed,
        );
      case _DeclarationFlowState.completed:
        return _buildScreen18Completed(
          currentGender: currentGender,
          activeItem: activeItem,
        );
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SCREEN 14 — Daily Introduction (photo-dawn)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildScreen14Intro({
    required String currentGender,
    required int totalDeclarations,
  }) {
    return Column(
      key: const ValueKey('screen-14-intro'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // Top bar: Close (✕) + Gender selector
        Row(
          children: [
            _HeaderIconButton(
              icon: Icons.close_rounded,
              onTap: _exitToHome,
              tooltip: 'Back to home',
            ),
            const Spacer(),
            _GenderSelector(
              selectedGender: currentGender,
              onChanged: _onGenderChanged,
            ),
            const Spacer(),
            const SizedBox(width: 36),
          ],
        ),

        const Spacer(flex: 3),

        // Date headline ("Thursday, 28 August")
        Text(
          _formatCurrentDate(),
          style: PType.meta.copyWith(
            color: PColors.bone70,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 14),

        // Title ("Today I declare")
        Text(
          'Today I declare',
          style: PType.display.copyWith(
            color: PColors.bone,
            fontSize: 34,
            height: 1.15,
          ),
        ),

        const SizedBox(height: 14),

        // Subtitle ("Four declarations, drawn from Scripture and written for you. Take them slowly.")
        Text(
          'Four declarations, drawn from Scripture and written for you. Take them slowly.',
          style: PType.body.copyWith(
            color: PColors.bone70,
            fontSize: 16,
            height: 1.45,
          ),
        ),

        const SizedBox(height: 28),

        // 4 Progress dashes (inactive)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            return Container(
              width: 28,
              height: 2.5,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                color: PColors.bone.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),

        const Spacer(flex: 4),

        // Button ("Begin")
        _PrimaryButton(
          label: 'Begin',
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _flowState = _DeclarationFlowState.flip;
              _cardIndex = 0;
            });
          },
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SCREEN 15 & 16 — Declaration Flip Card (photo-declarations)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildScreen15Flip({
    required String currentGender,
    required int totalDeclarations,
    required int activeCardIndex,
    required Declaration activeDecl,
    required DeclarationItem activeItem,
    required bool isProclaimed,
  }) {
    final stepText =
        '${(activeCardIndex + 1).toString().padLeft(2, '0')} / ${totalDeclarations.toString().padLeft(2, '0')}';
    final isLastDeclaration = activeCardIndex >= totalDeclarations - 1;

    return Column(
      key: ValueKey('screen-15-flip-$activeCardIndex'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // Top Bar: Close (✕) + Step Counter with dashes + Action icons (Copy, Share)
        Row(
          children: [
            _HeaderIconButton(
              icon: Icons.close_rounded,
              onTap: _exitToHome,
              tooltip: 'Back to home',
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      stepText,
                      style: PType.eyebrow.copyWith(
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w600,
                        color: PColors.bone70,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(totalDeclarations, (idx) {
                        final isPassed = idx <= activeCardIndex;
                        return Container(
                          width: 18,
                          height: 2.0,
                          margin: const EdgeInsets.symmetric(horizontal: 2.0),
                          decoration: BoxDecoration(
                            color: isPassed
                                ? PColors.bone
                                : PColors.bone.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HeaderIconButton(
                  icon: Icons.copy_rounded,
                  onTap: () => _copyToClipboard(activeItem),
                  tooltip: 'Copy text',
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  icon: Icons.ios_share_rounded,
                  onTap: () => _openShareModal(activeItem),
                  tooltip: 'Share declaration',
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Gender Selector Toggle (WOMEN / MEN)
        Center(
          child: _GenderSelector(
            selectedGender: currentGender,
            onChanged: _onGenderChanged,
          ),
        ),

        const SizedBox(height: 8),

        // Live 3D Flip Card (PFlipCard with 950ms flip, no mirroring)
        Expanded(
          child: Center(
            child: PFlipCard(
              key: ValueKey(
                  'flip-${activeItem.gender}-$activeCardIndex-${activeItem.dayNumber}'),
              scriptureText: activeItem.scriptureText,
              scriptureRef: activeItem.scriptureRef,
              declarationText: activeItem.declarationText,
              topic:
                  '${activeItem.topic} · Declaration ${_wordForIndex(activeCardIndex)}',
              scriptureEyebrow: 'SCRIPTURE',
              declarationEyebrow: 'TODAY I DECLARE',
              frontPrompt: 'Tap to read the declaration',
              backPrompt: 'Tap to return to Scripture',
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Bottom Actions Row: Share icon + Next declaration / Proclaim in faith
        Row(
          children: [
            _ShareIconButton(onTap: () => _openShareModal(activeItem)),
            const SizedBox(width: 12),
            Expanded(
              child: _PrimaryButton(
                label: !isLastDeclaration
                    ? 'Next declaration'
                    : (isProclaimed
                        ? 'Today complete ✓'
                        : 'Proclaim in faith'),
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (!isLastDeclaration) {
                    setState(() {
                      _cardIndex = activeCardIndex + 1;
                    });
                  } else {
                    _handleProclaim(activeDecl, currentGender);
                  }
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SCREEN 18 — Completed 4/4 (photo-declarations)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildScreen18Completed({
    required String currentGender,
    required DeclarationItem activeItem,
  }) {
    return Column(
      key: const ValueKey('screen-18-completed'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // Top bar: Close (✕) + Gender selector
        Row(
          children: [
            _HeaderIconButton(
              icon: Icons.close_rounded,
              onTap: _exitToHome,
              tooltip: 'Back to home',
            ),
            const Spacer(),
            _GenderSelector(
              selectedGender: currentGender,
              onChanged: _onGenderChanged,
            ),
            const Spacer(),
            const SizedBox(width: 36),
          ],
        ),

        const Spacer(flex: 3),

        // 4 Completed progress dashes (all active)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            return Container(
              width: 32,
              height: 2.5,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                color: PColors.bone,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),

        const SizedBox(height: 24),

        // Pregare Mark / Brand Logo
        const PBrandLogo(
          isLight: true,
          height: 32,
        ),

        const SizedBox(height: 18),

        // Eyebrow
        const PEyebrow('DAY COMPLETE'),

        const SizedBox(height: 12),

        // Title ("You've spoken today's four declarations.")
        Text(
          'You\'ve spoken today\'s four declarations.',
          style: PType.display.copyWith(
            color: PColors.bone,
            fontSize: 28,
            height: 1.25,
          ),
        ),

        const SizedBox(height: 14),

        // Subtitle ("Four new ones arrive tomorrow morning. Nothing is lost if you miss a day.")
        Text(
          'Four new ones arrive tomorrow morning. Nothing is lost if you miss a day.',
          style: PType.body.copyWith(
            color: PColors.bone70,
            fontSize: 15,
            height: 1.45,
          ),
        ),

        const Spacer(flex: 4),

        // Primary action: Share today's declarations
        _PrimaryButton(
          label: 'Share today\'s declarations',
          onTap: () => _openShareModal(activeItem),
        ),

        const SizedBox(height: 12),

        // Secondary action: Read the devotional · 2 min
        _SecondaryOutlinedButton(
          label: 'Read the devotional · 2 min',
          onTap: () {
            MainShell.setTab(context, 0);
          },
        ),

        const SizedBox(height: 14),

        // Tertiary link: Review / Read them again
        Center(
          child: PInteractive(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _cardIndex = 0;
                _flowState = _DeclarationFlowState.flip;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(
                'Read them again',
                style: PType.meta.copyWith(
                  color: PColors.bone70,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                  decorationColor: PColors.bone50,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header Icon Button
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return PInteractive(
      onTap: onTap,
      tooltip: tooltip,
      builder: (context, isHovered, isPressed) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isHovered
              ? PColors.glassFill.withValues(alpha: 0.28)
              : PColors.glassFill,
          shape: BoxShape.circle,
          border: Border.all(
            color: isHovered ? PColors.bone50 : PColors.hairline,
          ),
        ),
        child: Icon(icon, color: PColors.bone, size: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gender Selector (WOMEN / MEN)
// ─────────────────────────────────────────────────────────────────────────────
class _GenderSelector extends StatelessWidget {
  const _GenderSelector({
    required this.selectedGender,
    required this.onChanged,
  });

  final String selectedGender;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isMen = selectedGender == 'hombres';

    Widget buildPill({
      required String label,
      required String value,
      required IconData icon,
      required bool isSelected,
    }) {
      return PInteractive(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? PColors.bone
                : PColors.glassFill.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(PRadius.chip),
            border: Border.all(
              color: isSelected ? PColors.bone : PColors.hairline,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? PColors.ink : PColors.bone62,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: PType.meta.copyWith(
                  color: isSelected ? PColors.ink : PColors.bone70,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: PColors.ink.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(PRadius.pill),
        border: Border.all(color: PColors.hairline.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildPill(
            label: 'WOMEN',
            value: 'mujeres',
            icon: Icons.female_rounded,
            isSelected: !isMen,
          ),
          const SizedBox(width: 4),
          buildPill(
            label: 'MEN',
            value: 'hombres',
            icon: Icons.male_rounded,
            isSelected: isMen,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN 17 — Share Modal
// ─────────────────────────────────────────────────────────────────────────────
class _ShareModal extends StatefulWidget {
  const _ShareModal({required this.item});
  final DeclarationItem item;

  @override
  State<_ShareModal> createState() => _ShareModalState();
}

class _ShareModalState extends State<_ShareModal> {
  int _selectedTheme = 0; // 0=Dusk, 1=Ink, 2=Bone, 3=Story 9:16

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      decoration: const BoxDecoration(
        color: PColors.ink,
        borderRadius: BorderRadius.vertical(top: Radius.circular(PRadius.flip)),
        border: Border(
          top: BorderSide(color: PColors.hairline, width: 1.0),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close_rounded,
                        color: PColors.bone62, size: 22),
                  ),
                  const Spacer(),
                  Text(
                    'Share declaration',
                    style: PType.uiStrong,
                  ),
                  const Spacer(),
                  const SizedBox(width: 22),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card preview
            _ShareCardPreview(
              item: widget.item,
              themeIndex: _selectedTheme,
            ),
            const SizedBox(height: 18),

            // Theme selector chips (Dusk / Ink / Bone / Story 9:16)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ThemeChip(
                  label: 'Dusk',
                  index: 0,
                  selected: _selectedTheme,
                  onTap: (i) => setState(() => _selectedTheme = i),
                ),
                _ThemeChip(
                  label: 'Ink',
                  index: 1,
                  selected: _selectedTheme,
                  onTap: (i) => setState(() => _selectedTheme = i),
                ),
                _ThemeChip(
                  label: 'Bone',
                  index: 2,
                  selected: _selectedTheme,
                  onTap: (i) => setState(() => _selectedTheme = i),
                ),
                _ThemeChip(
                  label: 'Story 9:16',
                  index: 3,
                  selected: _selectedTheme,
                  onTap: (i) => setState(() => _selectedTheme = i),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Actions (Copy / Share / Save)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      final text =
                          '«${widget.item.declarationText}»\n\n${widget.item.scriptureRef}\n"${widget.item.scriptureText}"\n\n— Via Pregare';
                      Clipboard.setData(ClipboardData(text: text));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Copied to clipboard',
                            style: PType.body
                                .copyWith(color: PColors.bone, fontSize: 13),
                          ),
                          backgroundColor: PColors.ink,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const _ActionButton(
                        icon: Icons.copy_rounded, label: 'Copy'),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const _ActionButton(
                        icon: Icons.ios_share_rounded, label: 'Share'),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const _ActionButton(
                        icon: Icons.download_rounded, label: 'Save'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
              child: _PrimaryButton(
                label: 'Close',
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareCardPreview extends StatelessWidget {
  const _ShareCardPreview({required this.item, required this.themeIndex});
  final DeclarationItem item;
  final int themeIndex;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Gradient? grad;
    final Color textMain;
    final Color textSub;
    final double cardWidth = themeIndex == 3 ? 210 : 260;
    final double cardHeight = themeIndex == 3 ? 350 : 300;

    switch (themeIndex) {
      case 1: // Ink
        bg = PColors.ink;
        grad = null;
        textMain = PColors.bone;
        textSub = PColors.bone55;
      case 2: // Bone
        bg = PColors.bone;
        grad = null;
        textMain = PColors.ink;
        textSub = PColors.ink40;
      default: // Dusk & Story
        bg = PColors.inkDeep;
        grad = PScrims.hero;
        textMain = PColors.bone;
        textSub = PColors.bone55;
    }

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: bg,
        gradient: grad,
        borderRadius: BorderRadius.circular(PRadius.panel),
        border: Border.all(color: PColors.hairline, width: 1.0),
        boxShadow: PShadows.flip,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'DAY ${item.dayNumber} • ${item.topic.toUpperCase()}',
                style: PType.eyebrow.copyWith(color: textSub, fontSize: 8),
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.declarationText,
            style: PType.scripture.copyWith(
              color: textMain,
              fontSize: 16,
              height: 1.35,
            ),
            maxLines: themeIndex == 3 ? 7 : 5,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text(
            item.scriptureRef,
            style: PType.meta.copyWith(color: textSub, fontSize: 11),
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFD4AF37),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'PREGARE',
                style: PType.eyebrow.copyWith(
                  color: textSub,
                  fontSize: 8,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final int index;
  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = selected == index;
    return PInteractive(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: isActive ? PColors.glassFill : Colors.transparent,
          borderRadius: BorderRadius.circular(PRadius.chip),
          border: Border.all(
            color: isActive ? PColors.glassStroke : PColors.hairline,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: PType.meta.copyWith(
            color: isActive ? PColors.bone : PColors.bone45,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: PColors.glassFill,
            borderRadius: BorderRadius.circular(PRadius.tile),
            border: Border.all(color: PColors.hairline, width: 1.0),
          ),
          child: Icon(icon, color: PColors.bone, size: 20),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: PType.navLabel.copyWith(color: PColors.bone55),
        ),
      ],
    );
  }
}

class _ShareIconButton extends StatelessWidget {
  const _ShareIconButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PInteractive(
      onTap: onTap,
      tooltip: 'Share declaration',
      pressedScale: 0.96,
      builder: (context, isHovered, isPressed) => AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isHovered
              ? PColors.glassFill.withValues(alpha: 0.28)
              : PColors.glassFill,
          borderRadius: BorderRadius.circular(PRadius.tile),
          border: Border.all(
            color: isHovered ? PColors.bone50 : PColors.glassStroke,
            width: 1.0,
          ),
        ),
        child:
            const Icon(Icons.ios_share_rounded, color: PColors.bone, size: 20),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return PInteractive(
      onTap: onTap,
      pressedScale: isEnabled ? 0.985 : 1.0,
      hoverScale: isEnabled ? 1.01 : 1.0,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              isEnabled ? PColors.bone : PColors.bone.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(PRadius.pill),
          border: isEnabled ? null : Border.all(color: PColors.hairline),
        ),
        child: Text(
          label,
          style: PType.uiStrong.copyWith(
            color: isEnabled ? PColors.ink : PColors.bone70,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _SecondaryOutlinedButton extends StatelessWidget {
  const _SecondaryOutlinedButton({required this.label, required this.onTap});
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
          color: PColors.glassFill,
          borderRadius: BorderRadius.circular(PRadius.pill),
          border: Border.all(color: PColors.hairline),
        ),
        child: Text(
          label,
          style: PType.uiStrong.copyWith(
            color: PColors.bone,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
