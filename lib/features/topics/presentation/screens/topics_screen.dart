import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/molecules/auth_prompt_sheet.dart';
import '../../../../core/ui/organisms/main_shell.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bible/presentation/screens/bible_screen.dart';
import '../../../devotionals/presentation/providers/devotionals_provider.dart';
import '../../../devotionals/domain/models/devotional.dart';
import '../../../home/domain/models/daily_verse.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../streaks/presentation/providers/streaks_provider.dart';
import '../../domain/models/topic.dart';
import '../providers/topics_provider.dart';
import 'topic_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Explore screen — Topics + Devotionals tabs
// Background: INK · With floating nav
// All data loaded from the backend API via providers.
// ─────────────────────────────────────────────────────────────────────────────
class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  int _activeTab = 0; // 0 = Topics, 1 = Devotionals

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TopicsProvider>().loadTopics();
      context.read<DevotionalsProvider>().loadDevotionals();
    });
  }

  void _openTopicDetail(Topic topic) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: topic)),
    );
  }

  void _openDevotionalDetail(Devotional devotional) {
    final devProvider = context.read<DevotionalsProvider>();
    final homeState = context.read<HomeProvider>().state;
    final todayDayNumber = homeState is AsyncData && (homeState as AsyncData).data is HomeData
        ? ((homeState as AsyncData).data as HomeData).dailyVerse.devotionalDay
        : 1;

    final isToday = devotional.day == todayDayNumber || (todayDayNumber == null && devotional.day == 1);
    final isCompleted = devProvider.isCompleted(devotional);

    // Block locked devotionals from opening
    if (!isToday && !isCompleted) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Day ${devotional.day} is locked. Complete today\'s devotional to progress.',
            style: PType.body.copyWith(color: PColors.bone, fontSize: 13),
          ),
          backgroundColor: PColors.ink,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _DevotionalDetailScreen(devotional: devotional)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PScreen(
      background: const PScreenBackground.ink(),
      hasNav: true,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      floatingWidget: PBottomNav(
        currentIndex: 3,
        onTap: (i) => MainShell.setTab(context, i),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Explore', style: PType.display),
          const SizedBox(height: 20),
          _ExploreTabRow(
            activeIndex: _activeTab,
            onTap: (i) => setState(() => _activeTab = i),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: IndexedStack(
              index: _activeTab,
              children: [
                _TopicsContent(onTopicTap: _openTopicDetail),
                _DevotionalsContent(onDevotionalTap: _openDevotionalDetail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Explore tab row ──────────────────────────────────────────────────────────
class _ExploreTabRow extends StatelessWidget {
  const _ExploreTabRow({required this.activeIndex, required this.onTap});
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final labels = ['Topics', 'Devotionals'];
    return Row(
      children: labels.asMap().entries.map((e) {
        final isActive = e.key == activeIndex;
        return Padding(
          padding: EdgeInsets.only(right: e.key < labels.length - 1 ? 24 : 0),
          child: PInteractive(
            onTap: () => onTap(e.key),
            pressedScale: 0.98,
            builder: (context, isHovered, isPressed) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.value,
                    style: PType.uiStrong.copyWith(
                      color: isActive
                          ? PColors.bone
                          : (isHovered ? PColors.bone85 : PColors.bone45),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    height: 1.5,
                    width: isActive ? 42 : 0,
                    color: isActive ? PColors.bone : Colors.transparent,
                  ),
                ],
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Topics tab — loaded from TopicsProvider
// ─────────────────────────────────────────────────────────────────────────────
class _TopicsContent extends StatelessWidget {
  const _TopicsContent({required this.onTopicTap});
  final void Function(Topic) onTopicTap;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TopicsProvider>();
    final topics = provider.currentTopics;

    if (provider.topics is AsyncLoading) {
      return const Center(child: CircularProgressIndicator(color: PColors.bone));
    }
    if (provider.topics is AsyncError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PEyebrow('Could not load topics'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => provider.loadTopics(),
              child: Text('Retry', style: PType.uiStrong),
            ),
          ],
        ),
      );
    }
    if (topics.isEmpty) {
      return const Center(child: PEyebrow('No topics available'));
    }

    final featured = topics.first;

    return RefreshIndicator(
      onRefresh: () => context.read<TopicsProvider>().loadTopics(),
      color: PColors.bone,
      backgroundColor: PColors.ink,
      child: ListView(
        padding: const EdgeInsets.only(bottom: PSpace.navClearance),
        children: [
          // ── Featured topic card ───────────────────────────────────────────
          PInteractive(
            onTap: () => onTopicTap(featured),
            pressedScale: 0.99,
            builder: (context, isHovered, isPressed) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(PRadius.tile),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/photo-topics.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: PColors.inkDeep),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(gradient: PScrims.home),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      top: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const PEyebrow('This week'),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(featured.title,
                                  style: PType.display.copyWith(fontSize: 28)),
                              const SizedBox(height: 6),
                              Text(
                                featured.description.length > 80
                                    ? '${featured.description.substring(0, 80).trim()}…'
                                    : featured.description,
                                style: PType.body.copyWith(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          // ── Numbered topic list ───────────────────────────────────────────
          ...topics.asMap().entries.map((e) {
            final idx = (e.key + 1).toString().padLeft(2, '0');
            return _topicRow(idx, e.value);
          }),
        ],
      ),
    );
  }

  Widget _topicRow(String number, Topic topic) {
    return PListRow(
      title: topic.title,
      meta: topic.tag,
      prefix: Text(number, style: PType.meta.copyWith(color: PColors.bone45)),
      trailing: Text(
        topic.tag,
        style: PType.meta.copyWith(color: PColors.bone55),
      ),
      showChevron: false,
      onTap: () => onTopicTap(topic),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Devotionals tab — loaded from DevotionalsProvider
// Virtualized with SliverList for 0ms instantaneous tab switching
// ─────────────────────────────────────────────────────────────────────────────
class _DevotionalsContent extends StatelessWidget {
  const _DevotionalsContent({required this.onDevotionalTap});
  final void Function(Devotional) onDevotionalTap;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DevotionalsProvider>();
    final devotionals = provider.currentDevotionals;
    final homeState = context.watch<HomeProvider>().state;
    final todayDayNumber = homeState is AsyncData
        ? (homeState as AsyncData<dynamic>).data is HomeData
            ? ((homeState as AsyncData<dynamic>).data as HomeData)
                .dailyVerse
                .devotionalDay
            : null
        : null;

    if (provider.devotionals is AsyncLoading) {
      return const Center(child: CircularProgressIndicator(color: PColors.bone));
    }
    if (provider.devotionals is AsyncError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PEyebrow('Could not load devotionals'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => provider.loadDevotionals(),
              child: Text('Retry', style: PType.uiStrong),
            ),
          ],
        ),
      );
    }
    if (devotionals.isEmpty) {
      return const Center(child: PEyebrow('No devotionals available'));
    }

    final today = todayDayNumber != null
        ? devotionals.firstWhere(
            (d) => d.day == todayDayNumber,
            orElse: () => devotionals.first,
          )
        : devotionals.first;

    final others = devotionals.where((d) => d.day != today.day).toList();
    final completedOthers = others.where((d) => provider.isCompleted(d)).toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    final lockedOthers = others.where((d) => !provider.isCompleted(d)).toList()
      ..sort((a, b) => a.day.compareTo(b.day));

    return RefreshIndicator(
      onRefresh: () => context.read<DevotionalsProvider>().loadDevotionals(),
      color: PColors.bone,
      backgroundColor: PColors.ink,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Today's devotional card ─────────────────────────────────
                PInteractive(
                  onTap: () => onDevotionalTap(today),
                  pressedScale: 0.99,
                  builder: (context, isHovered, isPressed) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(PRadius.tile),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: Image.asset(
                              'assets/photo-devotionals.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: PColors.inkDeep),
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(gradient: PScrims.home),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 20,
                            top: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const PEyebrow("Today's devotional"),
                                    if (provider.isCompleted(today))
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2D6A4F),
                                          borderRadius: BorderRadius.circular(PRadius.pill),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.check_rounded, color: PColors.bone, size: 12),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Completed',
                                              style: PType.meta.copyWith(
                                                color: PColors.bone,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      today.title,
                                      style: PType.display.copyWith(fontSize: 24),
                                    ),
                                    const SizedBox(height: 6),
                                    Text('Day ${today.day}', style: PType.meta),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // ── Completed devotionals header (shown first) ───────────────
                if (completedOthers.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  PEyebrow('Completed (${completedOthers.length})'),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),

          // ── Completed devotionals list (viewable & re-readable) ───────────
          if (completedOthers.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final d = completedOthers[index];
                  return PListRow(
                    title: d.title,
                    meta: 'Day ${d.day} • Completed',
                    showChevron: false,
                    isDimmed: false,
                    onTap: () => onDevotionalTap(d),
                    prefix: Text(
                      d.day.toString().padLeft(2, '0'),
                      style: PType.meta.copyWith(
                        color: const Color(0xFF2D6A4F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF2D6A4F),
                      size: 18,
                    ),
                  );
                },
                childCount: completedOthers.length,
              ),
            ),

          // ── Locked days header ───────────────────────────────────────────
          if (lockedOthers.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 28, bottom: 4),
                child: PEyebrow('Upcoming days (${lockedOthers.length})'),
              ),
            ),

          // ── Locked days list (padlock icon, tap blocked) ──────────────────
          if (lockedOthers.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final d = lockedOthers[index];
                  return PListRow(
                    title: d.title,
                    meta: 'Day ${d.day} • Locked',
                    showChevron: false,
                    isDimmed: true,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Day ${d.day} is locked. Complete today\'s devotional to unlock.',
                            style: PType.body.copyWith(color: PColors.bone, fontSize: 13),
                          ),
                          backgroundColor: PColors.ink,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    prefix: Text(
                      d.day.toString().padLeft(2, '0'),
                      style: PType.meta.copyWith(
                        color: PColors.bone45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.lock_rounded,
                      color: PColors.bone45,
                      size: 16,
                    ),
                  );
                },
                childCount: lockedOthers.length,
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: PSpace.navClearance),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Devotional detail screen (public) — stateful for completion + badge toasts
// Also used from home_screen when tapping Today's Scripture.
// ─────────────────────────────────────────────────────────────────────────────
/// Public alias used by home_screen.dart
typedef TodayDevotionalDetailScreen = _DevotionalDetailScreen;

class _DevotionalDetailScreen extends StatefulWidget {
  const _DevotionalDetailScreen({required this.devotional});
  final Devotional devotional;

  @override
  State<_DevotionalDetailScreen> createState() => _DevotionalDetailScreenState();
}

class _DevotionalDetailScreenState extends State<_DevotionalDetailScreen> {
  bool _completing = false;
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _completed = widget.devotional.isCompleted;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_completed && mounted) {
        final devProvider = context.read<DevotionalsProvider>();
        if (devProvider.isCompleted(widget.devotional)) {
          setState(() => _completed = true);
        }
      }
    });
  }

  /// Parse a verse reference like "Proverbs 27:17" or "(Proverbs 27:17)" into (bookId, bookName, chapter)
  (String, String, int) _parseRef(String ref) {
    if (ref.trim().isEmpty) return ('genesis', 'Genesis', 1);

    var clean = ref.split('·').first.trim();
    // If text contains a parenthetical reference e.g. "(Proverbs 27:17)", extract it
    final parenMatch = RegExp(r'\(([^)]+)\)').firstMatch(clean);
    if (parenMatch != null) {
      clean = parenMatch.group(1)!.trim();
    }

    final lastColon = clean.lastIndexOf(':');
    String bookAndChap;
    if (lastColon != -1) {
      bookAndChap = clean.substring(0, lastColon).trim();
    } else {
      bookAndChap = clean;
    }

    final parts = bookAndChap.split(' ');
    int chapter = 1;
    String bookName = bookAndChap;
    if (parts.length >= 2) {
      final maybeCh = int.tryParse(parts.last);
      if (maybeCh != null) {
        chapter = maybeCh;
        bookName = parts.sublist(0, parts.length - 1).join(' ');
      }
    } else if (parts.length == 1) {
      bookName = parts.first;
    }

    var bookId = bookName.toLowerCase().replaceAll(' ', '').replaceAll('-', '');
    if (bookId == 'psalm') {
      bookId = 'psalms';
    }

    return (bookId, bookName, chapter);
  }

  Future<void> _handleComplete() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      AuthPromptSheet.show(
        context,
        isLoginOnly: false,
        onSuccess: () => _completeOnBackend(),
      );
      return;
    }
    await _completeOnBackend();
  }

  Future<void> _completeOnBackend() async {
    setState(() => _completing = true);
    try {
      final devId = widget.devotional.uuid ?? widget.devotional.day.toString();
      final streaks = context.read<StreaksProvider>();
      final devProvider = context.read<DevotionalsProvider>();

      final newBadges = await streaks.completeDevotional(devId);
      devProvider.markAsCompleted(devId);
      devProvider.markAsCompleted(widget.devotional.day.toString());
      if (widget.devotional.uuid != null) {
        devProvider.markAsCompleted(widget.devotional.uuid!);
      }

      if (!mounted) return;
      setState(() {
        _completing = false;
        _completed = true;
      });
      if (newBadges && streaks.currentBadges.isNotEmpty) {
        final unlocked = streaks.currentBadges.where((b) => b.isUnlocked).toList();
        if (unlocked.isNotEmpty) {
          final badge = unlocked.last;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1A1A1A),
              duration: const Duration(seconds: 3),
              content: Row(
                children: [
                  Text(badge.icon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Badge unlocked!',
                            style: PType.meta.copyWith(
                                color: const Color(0xFFD4A853), fontSize: 11)),
                        Text(badge.title,
                            style: PType.uiStrong
                                .copyWith(color: PColors.bone, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _completing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save progress. Please try again.'),
          backgroundColor: Color(0xFF1A1A1A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.devotional;
    final verseRef = d.effectiveVerseReference.isNotEmpty
        ? d.effectiveVerseReference
        : d.verse;
    final (bookId, bookName, chapter) = _parseRef(verseRef);

    return PScreen(
      background: const PScreenBackground.bone(),
      hasNav: false,
      safeAreaBottom: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutterLight),
      header: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.chevron_left_rounded, color: PColors.ink, size: 28),
          ),
          const Spacer(),
          const Icon(Icons.ios_share_rounded, color: PColors.ink40, size: 20),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 8),
          PEyebrow('Day ${d.day} · Devotional', color: PColors.stone),
          const SizedBox(height: 12),
          Text(
            d.title,
            style: PType.display.copyWith(color: PColors.ink, fontSize: 30, height: 1.15),
          ),
          const SizedBox(height: 28),

          // ── Scripture ─ tappable → opens Bible at this reference ───────
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BibleReaderScreen(
                  bookId: bookId,
                  bookName: bookName,
                  initialChapter: chapter,
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12, right: 12),
              decoration: BoxDecoration(
                color: PColors.ink.withValues(alpha: 0.03),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: const Border(left: BorderSide(color: PColors.ink, width: 2.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.cleanVerseText,
                    style: PType.scripture.copyWith(
                        color: PColors.ink, fontSize: 17, height: 1.45),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.menu_book_rounded,
                          size: 13, color: Color(0xFFB58D3D)),
                      const SizedBox(width: 6),
                      if (d.effectiveVerseReference.isNotEmpty) ...[
                        Text(
                          d.effectiveVerseReference,
                          style: PType.uiStrong.copyWith(
                              color: PColors.ink, fontSize: 12),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '·',
                          style: PType.meta.copyWith(color: PColors.stone, fontSize: 12),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        'Read in Bible ↗',
                        style: PType.meta.copyWith(
                            color: const Color(0xFFB58D3D), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ── Reflection ────────────────────────────────────────────────
          PEyebrow('Reflection', color: PColors.stone),
          const SizedBox(height: 10),
          Text(
            d.text,
            style: PType.body.copyWith(color: PColors.ink, height: 1.65),
          ),
          const SizedBox(height: 28),

          // ── Prayer ─────────────────────────────────────────────────
          PEyebrow('Prayer', color: PColors.stone),
          const SizedBox(height: 10),
          Text(
            d.prayer,
            style: PType.body.copyWith(
              color: PColors.ink,
              fontStyle: FontStyle.italic,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 40),

          // ── CTA ───────────────────────────────────────────────────
          GestureDetector(
            onTap: (_completing || _completed) ? null : _handleComplete,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _completed ? const Color(0xFF2D6A4F) : PColors.ink,
                borderRadius: BorderRadius.circular(PRadius.pill),
              ),
              child: _completing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: PColors.bone,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_completed) ...[
                          const Icon(Icons.check_circle_outline_rounded,
                              color: PColors.bone, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _completed
                              ? 'Devotional completed!'
                              : 'Complete devotional',
                          style: PType.uiStrong
                              .copyWith(color: PColors.bone, fontSize: 14),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
