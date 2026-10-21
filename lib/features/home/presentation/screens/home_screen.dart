import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/organisms/main_shell.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../streaks/presentation/providers/streaks_provider.dart';
import '../../../notifications/presentation/screens/notification_settings_screen.dart';
import '../../../topics/presentation/providers/topics_provider.dart';
import '../../../topics/presentation/screens/topic_detail_screen.dart';
import '../../../topics/presentation/screens/topics_screen.dart';
import '../../../devotionals/presentation/providers/devotionals_provider.dart';
import '../../../bible/presentation/screens/bible_screen.dart';
import '../../../bible/presentation/widgets/share_verse_sheet.dart';
import '../../domain/models/daily_verse.dart';
import '../providers/home_provider.dart';
import '../../../declarations/presentation/providers/declaration_provider.dart';

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
      context.read<DeclarationProvider>().loadTodayDeclaration();
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
        PLink(
          text: 'Try again',
          textStyle: PType.uiStrong.copyWith(color: PColors.bone70),
          trailingIcon: Icons.refresh_rounded,
          iconSize: 13,
          onTap: () => home.loadHomeData(),
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
        PInteractive(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NotificationSettingsScreen(),
            ),
          ),
          tooltip: 'Notificaciones',
          builder: (context, isHovered, isPressed) => AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHovered ? PColors.glassFill : Colors.transparent,
              border: Border.all(
                color: isHovered ? PColors.hairline : Colors.transparent,
              ),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: isHovered ? PColors.bone : PColors.bone85,
              size: 20,
            ),
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
    final streaks = context.watch<StreaksProvider>();
    final name = auth.isAuthenticated ? auth.currentSession?.user.name : null;

    final hour = DateTime.now().hour;
    final String greetingPrefix;
    if (hour >= 5 && hour < 12) {
      greetingPrefix = 'Good morning';
    } else if (hour >= 12 && hour < 19) {
      greetingPrefix = 'Good afternoon';
    } else {
      greetingPrefix = 'Good evening';
    }

    final greetingText = name != null && name.isNotEmpty
        ? '$greetingPrefix,\n$name.'
        : '$greetingPrefix.';

    final streak = streaks.streakCount;
    final eveningSub = streak > 0
        ? 'Today is complete. $streak ${streak == 1 ? "day" : "days"} now.'
        : 'Today is complete.';

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
            eveningSub,
            style: PType.body.copyWith(color: PColors.bone70),
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

  /// Parse a reference like "Proverbs 11:25", "Psalm 139:13-14", or "1 Corinthians 13:4-8"
  /// into (bookId, bookName, chapter, verseNumber) for navigating BibleReaderScreen.
  (String bookId, String bookName, int chapter, int? verse) _parseVerseRef(
    String ref, {
    String? fallbackBookId,
    String? fallbackBookName,
    int? fallbackChapter,
    int? fallbackVerse,
  }) {
    if (fallbackBookId != null && fallbackChapter != null) {
      return (
        fallbackBookId,
        fallbackBookName ?? fallbackBookId,
        fallbackChapter,
        fallbackVerse,
      );
    }

    final clean = ref.split('·').first.trim();
    final lastColon = clean.lastIndexOf(':');
    if (lastColon == -1) {
      final bId = clean.toLowerCase().replaceAll(' ', '').replaceAll('-', '');
      return (bId == 'psalm' ? 'psalms' : bId, clean, 1, null);
    }

    final bookAndChapter = clean.substring(0, lastColon).trim();
    final afterColon = clean.substring(lastColon + 1).trim();
    final versePart = afterColon.split('-').first.split(',').first.trim();
    final parsedVerse = int.tryParse(versePart);

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
    return (bookId, bookName, chapter, parsedVerse);
  }

  @override
  Widget build(BuildContext context) {
    final daily = homeData?.dailyVerse;
    final verseText = daily?.text ?? '';
    final rawRef = daily?.reference ?? '';
    final (bookId, bookName, chapter, verseNumber) = _parseVerseRef(
      rawRef,
      fallbackBookId: daily?.bookId,
      fallbackBookName: daily?.bookName,
      fallbackChapter: daily?.chapter,
      fallbackVerse: daily?.verseNumber,
    );
    final devotionalDay = daily?.devotionalDay;
    final devotionalTitle = daily?.devotionalTitle;
    const versionLabel = 'KJV';
    final displayRef = rawRef.isNotEmpty ? '$rawRef · $versionLabel' : '';

    /// Opens today's devotional. Loads from DevotionalsProvider by day number.
    Future<void> openTodaysDevotional() async {
      final devProvider = context.read<DevotionalsProvider>();
      if (devProvider.currentDevotionals.isEmpty) {
        await devProvider.loadDevotionals();
      }
      if (!context.mounted) return;
      final list = devProvider.currentDevotionals;
      final todayDev = list.firstWhere(
        (d) => d.day == devotionalDay,
        orElse: () => list.isNotEmpty ? list.first : throw Exception('empty'),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TodayDevotionalDetailScreen(devotional: todayDev)),
      );
    }

    void openBibleReader() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BibleReaderScreen(
            bookId: bookId,
            bookName: bookName,
            initialChapter: chapter,
            initialVerse: verseNumber,
            targetVersion: 'KJV',
            devotionalTitle: devotionalTitle,
            devotionalDay: devotionalDay,
            isFromDevotional: true,
          ),
        ),
      );
    }

    void openEveningPsalm() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const BibleReaderScreen(
            bookId: 'psalms',
            bookName: 'Psalms',
            initialChapter: 4,
            targetVersion: 'KJV',
          ),
        ),
      );
    }

    final streaks = context.watch<StreaksProvider>();
    final declProvider = context.watch<DeclarationProvider>();
    final todayDecl = declProvider.todayDeclaration;
    final isDeclarationsComplete = (todayDecl != null &&
        (streaks.proclaimedDeclarationIds.contains(todayDecl.id.toString()) ||
            (todayDecl.dayNumber != null &&
                (streaks.proclaimedDeclarationIds.contains(
                        '${todayDecl.gender}_${todayDecl.dayNumber}') ||
                    streaks.proclaimedDeclarationIds.contains(
                        '${todayDecl.gender}_day_${todayDecl.dayNumber}')))));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── TODAY'S TOPICS ── PRIMARY VISUAL (the differentiator) ─────
        const PEyebrow("Today's Topic"),
        const SizedBox(height: 14),
        _TopicsHeroCard(),
        const SizedBox(height: 32),

        // ── TODAY'S SCRIPTURE ── ILLUMINATED LUXURY EDITORIAL CARD ─────
        if (verseText.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1B1915),
              borderRadius: BorderRadius.circular(PRadius.panel),
              border: Border.all(color: const Color(0x40C5A059), width: 1.2),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF28231C),
                  Color(0xFF171512),
                  Color(0xFF12110F),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: const Color(0xFFC5A059).withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Top-right subtle sacred glow aura
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFC5A059).withValues(alpha: 0.16),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Card Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Eyebrow badge + KJV Pill + Share action
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: const Color(0x28C5A059),
                              borderRadius: BorderRadius.circular(PRadius.pill),
                              border: Border.all(color: const Color(0x55C5A059)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 11,
                                  color: Color(0xFFE5C583),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "TODAY'S SCRIPTURE",
                                  style: GoogleFonts.hankenGrotesk(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.4,
                                    color: const Color(0xFFE5C583),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0x1FFFFFFF),
                              borderRadius: BorderRadius.circular(PRadius.pill),
                              border: Border.all(color: const Color(0x33FFFFFF)),
                            ),
                            child: Text(
                              'KJV',
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: PColors.bone,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                ShareVerseSheet.show(
                                  context,
                                  bookName: bookName,
                                  chapter: chapter,
                                  verseNumber: verseNumber ?? 1,
                                  verseText: verseText,
                                  version: 'KJV',
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0x14FFFFFF),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0x24FFFFFF)),
                                ),
                                child: const Icon(
                                  Icons.share_rounded,
                                  size: 14,
                                  color: PColors.bone70,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Verse Text with sacred Newsreader serif styling
                      PInteractive(
                        onTap: devotionalDay != null ? openTodaysDevotional : openBibleReader,
                        tooltip: devotionalDay != null ? "Leer devocional de hoy" : "Leer en la Biblia",
                        pressedScale: 0.99,
                        pressedOpacity: 0.90,
                        builder: (context, isHovered, isPressed) => AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 140),
                          style: GoogleFonts.newsreader(
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.italic,
                            height: 1.42,
                            color: isHovered ? Colors.white : PColors.bone,
                          ),
                          child: Text('“$verseText”'),
                        ),
                      ),

                      // Devotional Context Chip (shows that this verse is part of today's devotional)
                      if (devotionalDay != null) ...[
                        const SizedBox(height: 14),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: openTodaysDevotional,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0x1CC5A059),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0x38C5A059)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.bookmark_rounded,
                                    size: 13,
                                    color: Color(0xFFE2C285),
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      devotionalTitle != null && devotionalTitle.isNotEmpty
                                          ? 'Versículo del devocional: $devotionalTitle'
                                          : 'Versículo conectado con el devocional de hoy',
                                      style: GoogleFonts.hankenGrotesk(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFE2C285),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 14,
                                    color: Color(0xFFE2C285),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Hairline separator
                      Container(
                        height: 1,
                        color: const Color(0x24FFFFFF),
                        margin: const EdgeInsets.symmetric(vertical: 14),
                      ),

                      // Footer Actions: Bible reader reference button & Devotional link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (displayRef.isNotEmpty)
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: openBibleReader,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0x26C5A059),
                                    borderRadius: BorderRadius.circular(PRadius.chip),
                                    border: Border.all(color: const Color(0x55C5A059)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.menu_book_rounded,
                                        size: 13,
                                        color: Color(0xFFE5C583),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        displayRef,
                                        style: GoogleFonts.hankenGrotesk(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: PColors.bone,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Icon(
                                        Icons.arrow_outward_rounded,
                                        size: 11,
                                        color: Color(0xFFE5C583),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (devotionalDay != null)
                            PLink(
                              text: "Today's Devotional",
                              textStyle: PType.meta.copyWith(
                                color: const Color(0xFFE5C583),
                                fontWeight: FontWeight.w600,
                              ),
                              trailingIcon: Icons.arrow_forward_rounded,
                              iconSize: 11,
                              onTap: openTodaysDevotional,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: PColors.glassFill,
              borderRadius: BorderRadius.circular(PRadius.panel),
            ),
          ),
        const SizedBox(height: 32),

        // ── FAITH DECLARATIONS HERO BONE CARD (Flow 02 Spec) ───────────
        PBoneCard(
          onTap: () => MainShell.setTab(context, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FAITH DECLARATIONS',
                    style: PType.eyebrow
                        .copyWith(color: PColors.clay, fontSize: 10),
                  ),
                  Text(
                    isDeclarationsComplete ? '04 / 04' : '00 / 04',
                    style: PType.counter,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                isDeclarationsComplete
                    ? (todayDecl.text.isNotEmpty
                        ? '“${todayDecl.text}”'
                        : 'Today’s four declarations spoken.')
                    : 'Four declarations,\nprepared for you',
                style: PType.cardTitle.copyWith(
                  fontSize: 22,
                  height: 1.25,
                  color: PColors.ink,
                ),
                maxLines: isDeclarationsComplete ? 3 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isDeclarationsComplete
                        ? 'Read them again'
                        : 'Take four quiet minutes',
                    style: PType.meta
                        .copyWith(color: PColors.ink40, fontSize: 12),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: PColors.ink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: PColors.bone,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // ── Action rows ───────────────────────────────────────────────
        PListRow(
          title: "Today's Devotional",
          meta: devotionalTitle != null && devotionalTitle.isNotEmpty
              ? '$devotionalTitle · 2 min'
              : 'Daily reflection and prayer',
          onTap: openTodaysDevotional,
        ),
        PListRow(
          title: isEvening ? 'Evening Psalm' : 'Continue reading',
          meta: isEvening ? 'Psalm 4 · 1 min' : 'Open Bible library',
          showTopBorder: false,
          onTap: isEvening
              ? openEveningPsalm
              : () => MainShell.setTab(context, 1),
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
      return PInteractive(
        onTap: () => MainShell.setTab(context, 3),
        hoverScale: 1.01,
        pressedScale: 0.985,
        tooltip: 'Explorar series de YouTube',
        builder: (context, isHovered, isPressed) => Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            color: isHovered ? PColors.glassFill.withValues(alpha: 0.20) : PColors.glassFill,
            borderRadius: BorderRadius.circular(PRadius.card),
            border: Border.all(
              color: isHovered ? PColors.bone50 : PColors.glassStroke,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.ondemand_video_outlined,
                color: isHovered ? PColors.bone : PColors.bone45,
                size: 36,
              ),
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

    return PInteractive(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: topic)),
      ),
      hoverScale: 1.01,
      pressedScale: 0.985,
      tooltip: 'Ver video: ${topic.title}',
      builder: (context, isHovered, isPressed) => ClipRRect(
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
                      PColors.ink.withValues(alpha: isHovered ? 0.12 : 0.20),
                      PColors.ink.withValues(alpha: isHovered ? 0.72 : 0.80),
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isHovered ? PColors.bone : PColors.ink.withValues(alpha: 0.75),
                  border: Border.all(color: PColors.bone, width: 1.2),
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: isHovered ? PColors.ink : PColors.bone,
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

