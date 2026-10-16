import 'dart:math' as math;
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

// ─── Local item model for UI & Sharing ───────────────────────────────────────
class DeclarationItem {
  final String scriptureText;
  final String scriptureRef;
  final String declarationText;
  final String topic;
  final int dayNumber;
  final String gender;

  const DeclarationItem({
    required this.scriptureText,
    required this.scriptureRef,
    required this.declarationText,
    required this.topic,
    required this.dayNumber,
    required this.gender,
  });
}

// ─── Main Declarations Screen ────────────────────────────────────────────────
class DeclarationsScreen extends StatefulWidget {
  const DeclarationsScreen({super.key});

  @override
  State<DeclarationsScreen> createState() => _DeclarationsScreenState();
}

class _DeclarationsScreenState extends State<DeclarationsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  // Track revealed and proclaimed status per gender so switching genders preserves both!
  final Set<String> _revealedGenders = {};
  final Set<String> _proclaimedGenders = {};

  @override
  void initState() {
    super.initState();

    // Pulse animation for the sacred seal before revelation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final provider = context.read<DeclarationProvider>();
      context.read<StreaksProvider>().loadProclaimedDeclarations();

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
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerReveal(String gender) {
    HapticFeedback.mediumImpact();
    setState(() {
      _revealedGenders.add(gender);
    });
  }

  void _resetReveal(String gender) {
    setState(() {
      _revealedGenders.remove(gender);
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
    });

    final streaks = context.read<StreaksProvider>();
    await streaks.proclaimDeclaration(declaration.id.toString());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Amen! You have proclaimed today\'s declaration.',
            style: PType.body.copyWith(color: PColors.bone, fontSize: 13),
          ),
          backgroundColor: PColors.ink,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  DeclarationItem _buildItem(Declaration d) {
    final topicKey = d.topics.isNotEmpty ? d.topics.first : '';
    final topicName = topicLabels[topicKey] ?? (topicKey.isNotEmpty ? topicKey : 'Faith');
    return DeclarationItem(
      scriptureText: d.verse,
      scriptureRef: d.reference,
      declarationText: d.text,
      topic: topicName,
      dayNumber: d.dayNumber ?? 1,
      gender: d.gender,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeclarationProvider>();
    final streaks = context.watch<StreaksProvider>();
    final currentGender = provider.selectedGender;
    final isRevealed = _revealedGenders.contains(currentGender);
    final declaration = provider.todayDeclaration;
    final isProclaimed = (declaration != null &&
            streaks.proclaimedDeclarationIds.contains(declaration.id.toString())) ||
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
        background: const PScreenBackground.photo('assets/photo-dawn.jpg', scrim: PScrims.home),
        hasNav: false,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PEyebrow('No declarations available'),
              const SizedBox(height: 16),
              _PrimaryButton(
                label: 'Retry',
                onTap: () => provider.loadTodayDeclaration(forceReload: true),
              ),
            ],
          ),
        ),
      );
    }

    if (declaration == null) {
      return const Scaffold(
        backgroundColor: PColors.inkDeep,
        body: Center(child: CircularProgressIndicator(color: PColors.bone)),
      );
    }

    final item = _buildItem(declaration);

    return PScreen(
      background: const PScreenBackground.photo('assets/photo-dawn.jpg', scrim: PScrims.home),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Top Bar: Close (✕) + Day indicator + Action icons ─────────
              Row(
                children: [
                  PInteractive(
                    onTap: _exitToHome,
                    tooltip: 'Back to home',
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
                      child: const Icon(Icons.close_rounded, color: PColors.bone, size: 20),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'DAY ${item.dayNumber} OF 365',
                            style: PType.eyebrow.copyWith(
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w600,
                              color: PColors.bone70,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'DAILY DECLARATION',
                            style: PType.meta.copyWith(
                              color: PColors.bone45,
                              fontSize: 9,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isRevealed)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PInteractive(
                          onTap: () => _copyToClipboard(item),
                          tooltip: 'Copy text',
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
                            child: const Icon(Icons.copy_rounded, color: PColors.bone, size: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        PInteractive(
                          onTap: () => _resetReveal(currentGender),
                          tooltip: 'Conceal declaration',
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
                            child: const Icon(Icons.refresh_rounded, color: PColors.bone, size: 18),
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox(width: 36),
                ],
              ),

              const SizedBox(height: 14),

              // ── Gender Toggle Pills (Women / Men) ─────────────────────────
              Center(
                child: _GenderSelector(
                  selectedGender: provider.selectedGender,
                  onChanged: (newGender) {
                    provider.setGender(newGender);
                  },
                ),
              ),

              const SizedBox(height: 10),

              // ── Main Card: Sealed or Revealed (PFlipCard with 3D Flip) ──
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 700),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeInBack,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        final rotate = Tween(begin: math.pi / 2, end: 0.0).animate(animation);
                        return AnimatedBuilder(
                          animation: rotate,
                          builder: (context, widget) {
                            final isUnder = (ValueKey(isRevealed) != child.key);
                            var value = isUnder ? math.min(rotate.value, math.pi / 2) : rotate.value;
                            return Transform(
                              transform: Matrix4.rotationY(value)..setEntry(3, 2, 0.0015),
                              alignment: Alignment.center,
                              child: widget,
                            );
                          },
                          child: child,
                        );
                      },
                      child: !isRevealed
                          ? _SealedCard(
                              key: ValueKey('sealed-$currentGender'),
                              pulseController: _pulseController,
                              onRevealTap: () => _triggerReveal(currentGender),
                            )
                          : Padding(
                              key: ValueKey('flip-${item.gender}-${item.dayNumber}'),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: PFlipCard(
                                scriptureText: item.scriptureText,
                                scriptureRef: item.scriptureRef,
                                declarationText: item.declarationText,
                                topic: item.topic,
                                scriptureEyebrow: 'SCRIPTURE',
                                declarationEyebrow: 'TODAY I DECLARE',
                                frontPrompt: 'Tap card to read the declaration',
                                backPrompt: 'Tap card to return to Scripture',
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Bottom Action Button ──────────────────────────────────────
              if (!isRevealed) ...[
                _PrimaryButton(
                  label: 'Reveal today\'s declaration ✨',
                  onTap: () => _triggerReveal(currentGender),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    '365 inspired declarations to walk in victory',
                    style: PType.meta.copyWith(color: PColors.bone45, fontSize: 11),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    _ShareIconButton(onTap: () => _openShareModal(item)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PrimaryButton(
                        label: isProclaimed ? 'Proclaimed today! ✓' : 'Proclaim in faith',
                        onTap: isProclaimed ? null : () => _handleProclaim(declaration, currentGender),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gender Selector (Women / Men)
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                size: 14,
                color: isSelected ? PColors.ink : PColors.bone62,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: PType.meta.copyWith(
                  color: isSelected ? PColors.ink : PColors.bone70,
                  fontSize: 12,
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
      padding: const EdgeInsets.all(4),
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
// Sealed Card (Before user requests the revelation)
// ─────────────────────────────────────────────────────────────────────────────
class _SealedCard extends StatelessWidget {
  const _SealedCard({
    super.key,
    required this.pulseController,
    required this.onRevealTap,
  });

  final AnimationController pulseController;
  final VoidCallback onRevealTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableH = constraints.maxHeight.isFinite ? constraints.maxHeight : 480.0;
        final cardH = math.max(260.0, availableH - 34.0);

        return PInteractive(
          onTap: onRevealTap,
          tooltip: 'Tap to reveal your declaration',
          pressedScale: 0.98,
          child: AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              final pulse = pulseController.value;
              final glowRadius = 16.0 + (pulse * 18.0);
              final glowAlpha = 0.12 + (pulse * 0.14);

              return Container(
                width: double.infinity,
                height: cardH,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: PColors.ink.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(PRadius.flip),
                  border: Border.all(
                    color: Color.lerp(PColors.glassStroke, const Color(0xFFD4AF37), pulse * 0.5)!,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: glowAlpha),
                      blurRadius: glowRadius,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    PBrandLogo(
                      height: 64,
                      width: 90,
                      isLight: true,
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'DAILY WORD',
                      style: PType.eyebrow.copyWith(
                        color: const Color(0xFFD4AF37),
                        letterSpacing: 2.2,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your daily declaration awaits',
                      textAlign: TextAlign.center,
                      style: PType.cardTitle.copyWith(
                        color: PColors.bone,
                        fontSize: 22,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'An anointed truth for today.\nTap here to unveil.',
                      textAlign: TextAlign.center,
                      style: PType.body.copyWith(
                        color: PColors.bone62,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: PColors.glassFill,
                        borderRadius: BorderRadius.circular(PRadius.chip),
                        border: Border.all(color: PColors.hairline),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app_rounded, color: PColors.bone70, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'TAP TO UNVEIL',
                            style: PType.meta.copyWith(color: PColors.bone85, fontSize: 10, letterSpacing: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 17 — Share modal
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
                    child: const Icon(Icons.close_rounded, color: PColors.bone62, size: 22),
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

            // Theme selector
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
                  label: 'Story',
                  index: 3,
                  selected: _selectedTheme,
                  onTap: (i) => setState(() => _selectedTheme = i),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Actions
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
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          backgroundColor: PColors.ink,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const _ActionButton(icon: Icons.copy_rounded, label: 'Copy'),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const _ActionButton(icon: Icons.ios_share_rounded, label: 'Share'),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const _ActionButton(icon: Icons.download_rounded, label: 'Save'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Main button
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
      width: 260,
      height: 300,
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
            style: PType.cardTitle.copyWith(
              color: textMain,
              fontSize: 16,
              height: 1.35,
            ),
            maxLines: 5,
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
                width: 8,
                height: 8,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 4),
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
        child: const Icon(Icons.ios_share_rounded, color: PColors.bone, size: 20),
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
          color: isEnabled ? PColors.bone : PColors.bone.withValues(alpha: 0.25),
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
