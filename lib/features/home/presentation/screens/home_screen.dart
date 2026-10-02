import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/organisms/main_shell.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../streaks/presentation/providers/streaks_provider.dart';
import '../../../notifications/presentation/screens/notification_settings_screen.dart';
import '../../../topics/presentation/providers/topics_provider.dart';
import '../../../topics/presentation/screens/topic_detail_screen.dart';
import '../../../topics/presentation/screens/topics_screen.dart';
import '../../../devotionals/presentation/providers/devotionals_provider.dart';
import '../../../bible/presentation/screens/bible_screen.dart';
import '../../domain/models/daily_verse.dart';
import '../providers/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadHomeData();
      context.read<TopicsProvider>().loadTopics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final hour = DateTime.now().hour;
    final isEvening = hour >= 19 || hour < 5;

    // Dynamic background photo based on time of day
    final photo = isEvening ? 'assets/photo-dusk-water.jpg' : 'assets/photo-dawn.jpg';

    return PScreen(
      background: PScreenBackground.photo(photo, scrim: PScrims.home),
      hasNav: true,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      floatingWidget: PBottomNav(
        currentIndex: 0,
        onTap: (i) => MainShell.setTab(context, i),
      ),
      body: RefreshIndicator(
        onRefresh: () => home.loadHomeData(),
        color: PColors.bone,
        backgroundColor: PColors.ink,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 16),

            // ── Header: wordmark · streak · bell ──────────────────────────
            _TopBar(isEvening: isEvening),
            const SizedBox(height: 28),

            // ── Serif greeting ─────────────────────────────────────────────
            _Greeting(isEvening: isEvening),
            const SizedBox(height: 36),

            // ── Dynamic content from API ───────────────────────────────────
            if (home.state is AsyncLoading)
              _buildSkeleton()
            else if (home.state is AsyncError)
              _buildError(home)
            else if (home.state is AsyncData<HomeData>)
              _MainSections(
                isEvening: isEvening,
                homeData: (home.state as AsyncData<HomeData>).data,
              )
            else
              _MainSections(isEvening: isEvening, homeData: null),

            const SizedBox(height: PSpace.navClearance),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: PColors.glassFill,
        borderRadius: BorderRadius.circular(PRadius.card),
      ),
    );
  }

  Widget _buildError(HomeProvider home) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PEyebrow('Could not load daily updates'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => home.loadHomeData(),
          child: Text(
            'Try again',
            style: PType.uiStrong.copyWith(color: PColors.bone70),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header: PREGARE · Streak Pill · Bell
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.isEvening});
  final bool isEvening;

  @override
  Widget build(BuildContext context) {
    final streakCount = context.watch<StreaksProvider>().streakCount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand logo
        const PBrandLogo(
          isLight: true,
          height: 28,
        ),

        const Spacer(),

        // Streak pill connected to real StreaksProvider
        PStreakPill(
          streak: streakCount,
          onTap: () => MainShell.setTab(context, 4),
        ),
        const SizedBox(width: 14),

        // Notifications
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NotificationSettingsScreen(),
            ),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: PColors.bone,
            size: 22,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dynamic serif greeting
// ─────────────────────────────────────────────────────────────────────────────
class _Greeting extends StatelessWidget {
  const _Greeting({required this.isEvening});
  final bool isEvening;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final onboarding = context.watch<OnboardingProvider>();
    final name = auth.currentSession?.user.name ?? onboarding.getDisplayName();

    final greetingText = name != null && name.isNotEmpty
        ? (isEvening ? 'Good evening,\n$name.' : 'Good morning,\n$name.')
        : (isEvening ? 'Good evening.' : 'Good morning.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greetingText,
          style: PType.greeting,
        ),
        if (isEvening) ...[
          const SizedBox(height: 10),
          Text(
            'Today is complete. Keep growing.',
            style: PType.body,
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main content sections
// ─────────────────────────────────────────────────────────────────────────────
class _MainSections extends StatelessWidget {
  const _MainSections({required this.isEvening, this.homeData});
  final bool isEvening;
  final HomeData? homeData;

  /// Parse a reference like "Deuteronomy 20:4" or "Psalm 139:13-14" into
  /// a (bookName, chapter) pair for navigating BibleReaderScreen.
  (String bookId, String bookName, int chapter) _parseVerseRef(String ref) {
    final clean = ref.split('·').first.trim();
    final lastColon = clean.lastIndexOf(':');
    if (lastColon == -1) return (clean.toLowerCase().replaceAll(' ', '-'), clean, 1);
    final bookAndChapter = clean.substring(0, lastColon).trim();
    final parts = bookAndChapter.split(' ');
    int chapter = 1;
    String bookName = bookAndChapter;
    if (parts.length >= 2) {
      final maybeCh = int.tryParse(parts.last);
      if (maybeCh != null) {
        chapter = maybeCh;
        bookName = parts.sublist(0, parts.length - 1).join(' ');
      }
    }
    var bookId = bookName.toLowerCase().replaceAll(' ', '').replaceAll('-', '');
    if (bookId == 'psalm') bookId = 'psalms';
    return (bookId, bookName, chapter);
  }

  @override
  Widget build(BuildContext context) {
    final verseText = homeData?.dailyVerse.text ?? '';
    final verseRef = homeData != null
        ? '${homeData!.dailyVerse.reference} · ${homeData!.dailyVerse.version}'
        : '';
    final rawRef = homeData?.dailyVerse.reference ?? '';
    final (bookId, bookName, chapter) = _parseVerseRef(rawRef);
    final devotionalDay = homeData?.dailyVerse.devotionalDay;

    /// Opens today's devotional. Loads from DevotionalsProvider by day number.
    Future<void> openTodaysDevotional() async {
      final devProvider = context.read<DevotionalsProvider>();
      // Ensure list is loaded
      if (devProvider.currentDevotionals.isEmpty) {
        await devProvider.loadDevotionals();
      }
      if (!context.mounted) return;
      final list = devProvider.currentDevotionals;
      // Find by day number, fallback to first
      final todayDev = list.firstWhere(
        (d) => d.day == devotionalDay,
        orElse: () => list.isNotEmpty ? list.first : throw Exception('empty'),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TodayDevotionalDetailScreen(devotional: todayDev)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── TODAY'S TOPICS ── PRIMARY VISUAL (the differentiator) ─────
        const PEyebrow("Today's Topic"),
        const SizedBox(height: 14),
        _TopicsHeroCard(),
        const SizedBox(height: 36),

        // ── TODAY'S SCRIPTURE ─────────────────────────────────────────
        const PEyebrow("Today's Scripture"),
        const SizedBox(height: 14),

        // ── Tappable verse → opens today's Devotional ─────────────────
        GestureDetector(
          onTap: (verseText.isNotEmpty && devotionalDay != null)
              ? () => openTodaysDevotional()
              : null,
          child: verseText.isNotEmpty
              ? Text('"$verseText"', style: PType.scripture)
              : Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: PColors.glassFill,
                    borderRadius: BorderRadius.circular(PRadius.chip),
                  ),
                ),
        ),
        const SizedBox(height: 10),

        // ── Bible reference (tappable → goes to Bible) ────────────────
        if (verseRef.isNotEmpty)
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
            child: Row(
              children: [
                Text(verseRef, style: PType.meta.copyWith(color: PColors.bone62)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_outward_rounded, size: 11, color: PColors.bone45),
              ],
            ),
          ),
        const SizedBox(height: 36),

        // ── Action rows ───────────────────────────────────────────────
        PListRow(
          title: 'Faith Declarations',
          meta: 'Speak over your day · 4 declarations',
          onTap: () => MainShell.setTab(context, 2),
        ),
        PListRow(
          title: 'Read the Bible',
          meta: 'Open Bible library',
          showTopBorder: false,
          onTap: () => MainShell.setTab(context, 1),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Topics Hero Card — PRIMARY visual on home screen.
// Shows the latest topic from DB with YouTube thumbnail if available,
// otherwise an elegant empty-state prompting the admin to add content.
// ─────────────────────────────────────────────────────────────────────────────
class _TopicsHeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topicsProvider = context.watch<TopicsProvider>();
    final topics = topicsProvider.currentTopics;

    // Empty state: no topics created yet
    if (topics.isEmpty) {
      return GestureDetector(
        onTap: () => MainShell.setTab(context, 3),
        child: Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            color: PColors.glassFill,
            borderRadius: BorderRadius.circular(PRadius.card),
            border: Border.all(color: PColors.glassStroke, width: 1.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.ondemand_video_outlined, color: PColors.bone45, size: 36),
              const SizedBox(height: 12),
              Text(
                'PREGARE · YouTube Series',
                style: PType.eyebrow.copyWith(color: PColors.clay),
              ),
              const SizedBox(height: 6),
              Text(
                'New topics coming soon.',
                style: PType.meta.copyWith(color: PColors.bone55),
              ),
            ],
          ),
        ),
      );
    }

    final topic = topics.first;
    final videoId = topic.youtubeVideoId ??
        (topic.youtubeUrl != null
            ? RegExp(r'(?:watch\?v=|youtu\.be\/|shorts\/)([^"&?\/\s]{11})')
                .firstMatch(topic.youtubeUrl!)?.group(1)
            : null);
    final thumbnailUrl =
        videoId != null ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg' : null;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: topic)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PRadius.card),
        child: Stack(
          children: [
            // ── Thumbnail or fallback ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 190,
              child: thumbnailUrl != null
                  ? Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, st) => Container(color: PColors.inkDeep),
                    )
                  : Container(color: PColors.inkDeep),
            ),

            // ── Gradient scrim ───────────────────────────────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      PColors.ink.withValues(alpha: 0.2),
                      PColors.ink.withValues(alpha: 0.80),
                    ],
                  ),
                ),
              ),
            ),

            // ── Channel badge (top-left) ─────────────────────────────────
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: PColors.ink.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(PRadius.chip),
                  border: Border.all(color: PColors.hairline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF0000),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'PREGARE · YouTube',
                      style: PType.meta.copyWith(
                        color: PColors.bone,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Duration badge (top-right) ───────────────────────────────
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PColors.ink.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(PRadius.chip),
                  border: Border.all(color: PColors.hairline),
                ),
                child: Text(
                  '${topic.videoDurationMinutes} min',
                  style: PType.meta.copyWith(color: PColors.bone, fontSize: 10),
                ),
              ),
            ),

            // ── Content (bottom) ─────────────────────────────────────────
            Positioned(
              left: 16,
              right: 56,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (topic.tag.isNotEmpty)
                    Text(
                      topic.tag.toUpperCase(),
                      style: PType.eyebrow.copyWith(color: PColors.clay, fontSize: 10),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    topic.title,
                    style: PType.uiStrong.copyWith(
                      color: PColors.bone,
                      fontSize: 15,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Play button (bottom-right) ───────────────────────────────
            Positioned(
              right: 14,
              bottom: 14,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PColors.ink.withValues(alpha: 0.75),
                  border: Border.all(color: PColors.bone, width: 1.2),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: PColors.bone,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
