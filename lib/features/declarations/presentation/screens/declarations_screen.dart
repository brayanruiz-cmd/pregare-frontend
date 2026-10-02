import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/organisms/main_shell.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../../domain/models/topic_labels.dart';
import '../providers/declaration_provider.dart';
import 'declarations_web_layout.dart';

// ─── Local item model ─────────────────────────────────────────────────────────
class DeclarationItem {
  final String scriptureText;
  final String scriptureRef;
  final String declarationText;
  final String topic;

  const DeclarationItem({
    required this.scriptureText,
    required this.scriptureRef,
    required this.declarationText,
    required this.topic,
  });
}

// No hardcoded sample data — all declarations come from the backend.

// ─── Main Declarations Screen ────────────────────────────────────────────────
class DeclarationsScreen extends StatefulWidget {
  const DeclarationsScreen({super.key});

  @override
  State<DeclarationsScreen> createState() => _DeclarationsScreenState();
}

class _DeclarationsScreenState extends State<DeclarationsScreen> {
  bool _hasBegun = false;
  bool _isComplete = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DeclarationProvider>();
      if (provider.declarations is AsyncInitial) {
        provider.loadDeclarations();
      }
    });
  }

  List<DeclarationItem> _getItems(DeclarationProvider provider) {
    return provider.currentDeclarations.map((d) {
      final topicKey = d.topics.isNotEmpty ? d.topics.first : '';
      final topicName = topicLabels[topicKey] ?? (topicKey.isNotEmpty ? topicKey : '');
      return DeclarationItem(
        scriptureText: d.verse,
        scriptureRef: d.reference,
        declarationText: d.text,
        topic: topicName,
      );
    }).toList();
  }

  void _nextDeclaration(int total) {
    if (_currentIndex < total - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      setState(() => _isComplete = true);
    }
  }

  void _restart() {
    setState(() {
      _hasBegun = false;
      _isComplete = false;
      _currentIndex = 0;
    });
  }

  void _exitToHome() {
    _restart();
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

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isDesktop(context)) {
      return const DeclarationsWebLayout();
    }

    final provider = context.watch<DeclarationProvider>();
    final items = _getItems(provider);
    final safeIndex = _currentIndex.clamp(0, items.length - 1);

    if (!_hasBegun) {
      return _IntroView(
        onBegin: () => setState(() => _hasBegun = true),
        onClose: _exitToHome,
      );
    }
    if (_isComplete) {
      return _CompletedView(
        onShareTap: () => _openShareModal(items.last),
        onRestart: _restart,
        onClose: _exitToHome,
      );
    }
    return _CardExperienceView(
      key: ValueKey(safeIndex),
      item: items[safeIndex],
      currentIndex: safeIndex,
      total: items.length,
      onNext: () => _nextDeclaration(items.length),
      onClose: _exitToHome,
      onShare: () => _openShareModal(items[safeIndex]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 14 — Daily introduction (Background: photo-dawn · Close button to exit)
// ─────────────────────────────────────────────────────────────────────────────
class _IntroView extends StatelessWidget {
  const _IntroView({required this.onBegin, required this.onClose});
  final VoidCallback onBegin;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    final days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    final dateLabel = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}'.toUpperCase();

    return PScreen(
      background: const PScreenBackground.photo('assets/photo-dawn.jpg', scrim: PScrims.home),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // ── Top Bar: Close button (✕) + Centered Date ──────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: PColors.glassFill,
                    shape: BoxShape.circle,
                    border: Border.all(color: PColors.hairline),
                  ),
                  child: const Icon(Icons.close_rounded, color: PColors.bone, size: 20),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    dateLabel,
                    style: PType.eyebrow,
                  ),
                ),
              ),
              const SizedBox(width: 36), // Visual balance
            ],
          ),

          const Spacer(),

          // ── App Logo Mark (Brand Logo) ───────────────────────────────────
          const Center(
            child: PBrandLogo(
              height: 56,
              isLight: true,
            ),
          ),
          const SizedBox(height: 28),

          // ── Serif Heading ──────────────────────────────────────────────────
          Text(
            'Today I declare',
            style: PType.display,
          ),
          const SizedBox(height: 16),
          Text(
            'Four declarations, drawn from Scripture and written for you. Take them slowly.',
            style: PType.body,
          ),

          const Spacer(),

          // ── Progress indicator (4 empty segments) ──────────────────────────
          _ProgressBar(currentIndex: -1, total: 4),
          const SizedBox(height: 32),

          // ── Begin Button ───────────────────────────────────────────────────
          _PrimaryButton(label: 'Begin', onTap: onBegin),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screens 15 + 16 — Declaration flip card
// ─────────────────────────────────────────────────────────────────────────────
class _CardExperienceView extends StatelessWidget {
  const _CardExperienceView({
    super.key,
    required this.item,
    required this.currentIndex,
    required this.total,
    required this.onNext,
    required this.onClose,
    required this.onShare,
  });

  final DeclarationItem item;
  final int currentIndex;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final isLast = currentIndex == total - 1;

    return PScreen(
      background: const PScreenBackground.photo('assets/photo-declarations.jpg', scrim: PScrims.hero),
      hasNav: false,
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          const SizedBox(height: 12),

          // ── Top bar: close · progress · counter ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: PColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: PColors.hairline),
                    ),
                    child: const Icon(Icons.close_rounded, color: PColors.bone, size: 20),
                  ),
                ),

                const Spacer(),

                _ProgressBar(currentIndex: currentIndex, total: total),

                const Spacer(),

                Text(
                  '0${currentIndex + 1} / 0$total',
                  style: PType.counter,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── 3D Hero Flip Card ──────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
              child: PFlipCard(
                scriptureText: item.scriptureText,
                scriptureRef: item.scriptureRef,
                declarationText: item.declarationText,
                topic: item.topic,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Bottom controls: share + next button ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
            child: Row(
              children: [
                _ShareIconButton(onTap: onShare),
                const SizedBox(width: 12),
                Expanded(
                  child: _PrimaryButton(
                    label: isLast ? 'Complete daily declarations' : 'Next declaration',
                    onTap: onNext,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 18 — Completed 4/4
// ─────────────────────────────────────────────────────────────────────────────
class _CompletedView extends StatelessWidget {
  const _CompletedView({
    required this.onShareTap,
    required this.onRestart,
    required this.onClose,
  });

  final VoidCallback onShareTap;
  final VoidCallback onRestart;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return PScreen(
      background: const PScreenBackground.photo('assets/photo-declarations.jpg', scrim: PScrims.home),
      hasNav: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // ── Top Bar: Close button (✕) ──────────────────────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: PColors.glassFill,
                    shape: BoxShape.circle,
                    border: Border.all(color: PColors.hairline),
                  ),
                  child: const Icon(Icons.close_rounded, color: PColors.bone, size: 20),
                ),
              ),
              const Spacer(),
              const PEyebrow('Today\'s declarations'),
              const Spacer(),
              const SizedBox(width: 36),
            ],
          ),

          const Spacer(),

          // ── App Logo Mark (Brand Logo) ───────────────────────────────────
          const Center(
            child: PBrandLogo(
              height: 50,
              isLight: true,
            ),
          ),
          const SizedBox(height: 24),

          // Heading
          Text(
            'You\'ve spoken today\'s four declarations.',
            style: PType.display,
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            'Four new ones arrive tomorrow morning. Nothing is lost if you miss a day.',
            style: PType.body,
          ),

          const Spacer(),

          // Primary CTA
          _PrimaryButton(label: 'Share today\'s declarations', onTap: onShareTap),
          const SizedBox(height: 14),

          // Secondary link
          Center(
            child: GestureDetector(
              onTap: onRestart,
              child: Text(
                'Read them again',
                style: PType.uiStrong.copyWith(color: PColors.bone70),
              ),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
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
            const SizedBox(height: 24),

            // Card preview
            _ShareCardPreview(
              item: widget.item,
              themeIndex: _selectedTheme,
            ),
            const SizedBox(height: 20),

            // Theme selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ThemeChip(label: 'Dusk', index: 0, selected: _selectedTheme, onTap: (i) => setState(() => _selectedTheme = i)),
                _ThemeChip(label: 'Ink', index: 1, selected: _selectedTheme, onTap: (i) => setState(() => _selectedTheme = i)),
                _ThemeChip(label: 'Bone', index: 2, selected: _selectedTheme, onTap: (i) => setState(() => _selectedTheme = i)),
                _ThemeChip(label: 'Story', index: 3, selected: _selectedTheme, onTap: (i) => setState(() => _selectedTheme = i)),
              ],
            ),
            const SizedBox(height: 24),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(icon: Icons.download_rounded, label: 'Save'),
                  _ActionButton(icon: Icons.ios_share_rounded, label: 'Share'),
                  _ActionButton(icon: Icons.copy_rounded, label: 'Copy'),
                  _ActionButton(icon: Icons.send_rounded, label: 'Send'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Main button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
              child: _PrimaryButton(
                label: 'Save to photos',
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
          Text(
            'TODAY I DECLARE',
            style: PType.eyebrow.copyWith(color: textSub, fontSize: 9),
          ),
          const Spacer(),
          Text(
            item.declarationText,
            style: PType.cardTitle.copyWith(
              color: textMain,
              fontSize: 18,
              height: 1.35,
            ),
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
                  color: PColors.clay,
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
    return GestureDetector(
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: PColors.glassFill,
          borderRadius: BorderRadius.circular(PRadius.tile),
          border: Border.all(color: PColors.glassStroke, width: 1.0),
        ),
        child: const Icon(Icons.ios_share_rounded, color: PColors.bone, size: 20),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.currentIndex, required this.total});
  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (index) {
        final isActive = index <= currentIndex;
        return Container(
          width: 28,
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          decoration: BoxDecoration(
            color: isActive ? PColors.bone : PColors.bone45,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 14),
        ),
      ),
    );
  }
}
