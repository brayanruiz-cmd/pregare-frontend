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
  flip, // Screen 15: Declaration card with 3D Flip
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

  // Track proclaimed status per gender so switching genders preserves both!
  final Set<String> _proclaimedGenders = {};

  bool _isGenderProclaimed(String gender) {
    final normGender = (gender.toLowerCase().startsWith('h') ||
            gender.toLowerCase().contains('men'))
        ? 'hombres'
        : 'mujeres';

    if (_proclaimedGenders.contains(normGender)) return true;

    final streaks = context.read<StreaksProvider>();
    if (streaks.todayProclaimedGenders.contains(normGender)) return true;

    final provider = context.read<DeclarationProvider>();
    final decl = provider.declarationForGender(normGender) ??
        (provider.selectedGender == normGender ? provider.todayDeclaration : null);

    if (decl != null) {
      if (streaks.proclaimedDeclarationIds.contains(decl.id.toString())) {
        return true;
      }
      if (decl.dayNumber != null) {
        if (streaks.proclaimedDeclarationIds.contains('${decl.gender}_${decl.dayNumber}') ||
            streaks.proclaimedDeclarationIds.contains('${decl.gender}_day_${decl.dayNumber}')) {
          return true;
        }
      }
    }
    return false;
  }

  bool _hasAnyProclaimedToday() {
    return _isGenderProclaimed('mujeres') || _isGenderProclaimed('hombres');
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final provider = context.read<DeclarationProvider>();
      final streaks = context.read<StreaksProvider>();

      await streaks.loadProclaimedDeclarations();

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

      await provider.loadTodayDeclaration(gender: targetGender);

      // Si ya proclamó hoy (o cualquiera de los géneros), ir directo a las tarjetas sin intro
      _checkProclaimedStatus(targetGender);
    });
  }

  void _checkProclaimedStatus(String gender) {
    if (_hasAnyProclaimedToday() || _isGenderProclaimed(gender)) {
      if (_flowState == _DeclarationFlowState.intro) {
        setState(() {
          _flowState = _DeclarationFlowState.flip;
        });
      }
    }
  }

  void _onGenderChanged(String newGender) {
    final provider = context.read<DeclarationProvider>();
    provider.setGender(newGender);
    setState(() {
      // Al cambiar género, mantenerse en la vista de tarjetas
      _flowState = _DeclarationFlowState.flip;
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
    final normGender = (gender.toLowerCase().startsWith('h') ||
            gender.toLowerCase().contains('men'))
        ? 'hombres'
        : 'mujeres';

    setState(() {
      _proclaimedGenders.add(normGender);
      _flowState = _DeclarationFlowState.flip;
    });

    final streaks = context.read<StreaksProvider>();
    await streaks.proclaimDeclaration(declaration.id.toString(), gender: normGender);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Declaración proclamada en fe! Tu racha fue actualizada.',
            style: PType.body.copyWith(color: PColors.bone, fontSize: 13),
          ),
          backgroundColor: const Color(0xFF1E281E),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeclarationProvider>();
    final currentGender = provider.selectedGender;
    final primaryDeclaration = provider.todayDeclaration;

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

    // Declaración única del día para el género activo
    final activeDecl = primaryDeclaration;
    final activeItem = _buildItem(activeDecl, step: 0);
    final isProclaimed = _isGenderProclaimed(currentGender);

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
    required Declaration activeDecl,
    required DeclarationItem activeItem,
    required bool isProclaimed,
  }) {
    switch (flowState) {
      case _DeclarationFlowState.intro:
        return _buildScreen14Intro(
          currentGender: currentGender,
        );
      case _DeclarationFlowState.flip:
        return _buildScreen15Flip(
          currentGender: currentGender,
          activeDecl: activeDecl,
          activeItem: activeItem,
          isProclaimed: isProclaimed,
        );
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SCREEN 14 — Daily Introduction (photo-dawn)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildScreen14Intro({
    required String currentGender,
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
              isWomenProclaimed: _isGenderProclaimed('mujeres'),
              isMenProclaimed: _isGenderProclaimed('hombres'),
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

        // Subtitle
        Text(
          'Daily declaration drawn from Scripture and prepared for you. Speak it in faith.',
          style: PType.body.copyWith(
            color: PColors.bone70,
            fontSize: 16,
            height: 1.45,
          ),
        ),

        const SizedBox(height: 24),

        // Single declaration pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: PColors.glassFill,
            borderRadius: BorderRadius.circular(PRadius.pill),
            border: Border.all(color: PColors.hairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 12, color: Color(0xFFE5C583)),
              const SizedBox(width: 6),
              Text(
                'DAILY DECLARATION',
                style: PType.eyebrow.copyWith(
                  color: const Color(0xFFE5C583),
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),

        const Spacer(flex: 4),

        // Button ("Begin")
        _PrimaryButton(
          label: 'Begin',
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _flowState = _DeclarationFlowState.flip;
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
    required Declaration activeDecl,
    required DeclarationItem activeItem,
    required bool isProclaimed,
  }) {
    return Column(
      key: ValueKey('screen-15-flip-$currentGender-${activeDecl.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // Top Bar: Close (✕) + Center Title + Action icons (Copy, Share)
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
                      'TODAY I DECLARE',
                      style: PType.eyebrow.copyWith(
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w600,
                        color: PColors.bone70,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      activeItem.topic.toUpperCase(),
                      style: PType.meta.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFC5A059),
                        fontSize: 10,
                      ),
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

        // Gender Selector Toggle (WOMEN / MEN) — Permite alternar entre las dos tarjetas
        Center(
          child: _GenderSelector(
            selectedGender: currentGender,
            onChanged: _onGenderChanged,
            isWomenProclaimed: _isGenderProclaimed('mujeres'),
            isMenProclaimed: _isGenderProclaimed('hombres'),
          ),
        ),

        const SizedBox(height: 8),

        // Live 3D Flip Card — Si ya la proclamó hoy, initialFlipped: true para que no tenga que volver a revelarla
        Expanded(
          child: Center(
            child: PFlipCard(
              key: ValueKey(
                  'flip-${activeItem.gender}-${activeItem.dayNumber}-$isProclaimed'),
              scriptureText: activeItem.scriptureText,
              scriptureRef: activeItem.scriptureRef,
              declarationText: activeItem.declarationText,
              topic: activeItem.topic,
              scriptureEyebrow: 'SCRIPTURE',
              declarationEyebrow: 'TODAY I DECLARE',
              frontPrompt: 'Tap to read the declaration',
              backPrompt: 'Tap to return to Scripture',
              initialFlipped: isProclaimed,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Bottom Actions Row: Share icon + Ya la declaré / Ya la declaré ✓
        Row(
          children: [
            _ShareIconButton(onTap: () => _openShareModal(activeItem)),
            const SizedBox(width: 12),
            Expanded(
              child: _PrimaryButton(
                label: isProclaimed ? 'Ya la declaré ✓' : 'Ya la declaré',
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (isProclaimed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Esta declaración ya fue proclamada hoy en fe.',
                          style: PType.body.copyWith(color: PColors.bone, fontSize: 13),
                        ),
                        backgroundColor: PColors.ink,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
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
    this.isWomenProclaimed = false,
    this.isMenProclaimed = false,
  });

  final String selectedGender;
  final ValueChanged<String> onChanged;
  final bool isWomenProclaimed;
  final bool isMenProclaimed;

  @override
  Widget build(BuildContext context) {
    final isMen = selectedGender == 'hombres';

    Widget buildPill({
      required String label,
      required String value,
      required IconData icon,
      required bool isSelected,
      required bool isProclaimed,
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
              if (isProclaimed) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check_rounded,
                  size: 13,
                  color: isSelected ? const Color(0xFF1B5E20) : const Color(0xFF81C784),
                ),
              ],
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
            isProclaimed: isWomenProclaimed,
          ),
          const SizedBox(width: 4),
          buildPill(
            label: 'MEN',
            value: 'hombres',
            icon: Icons.male_rounded,
            isSelected: isMen,
            isProclaimed: isMenProclaimed,
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

