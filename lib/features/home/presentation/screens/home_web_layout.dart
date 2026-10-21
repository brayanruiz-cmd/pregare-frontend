import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/state/async_state.dart';
import '../../../../../core/theme/tokens.dart';
import '../../../../../core/ui/organisms/main_shell.dart';
import '../../../../../core/ui/primitives/primitives.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bible/presentation/screens/bible_screen.dart';
import '../../../bible/presentation/widgets/share_verse_sheet.dart';
import '../../../devotionals/presentation/providers/devotionals_provider.dart';
import '../../../topics/presentation/screens/topics_screen.dart';
import '../../../home/domain/models/daily_verse.dart';
import '../providers/home_provider.dart';

/// 2-Column Desktop/Web layout for Home adhering to PREGARE tokens.
class HomeWebLayout extends StatefulWidget {
  const HomeWebLayout({super.key});

  @override
  State<HomeWebLayout> createState() => _HomeWebLayoutState();
}

class _HomeWebLayoutState extends State<HomeWebLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final home = context.read<HomeProvider>();
      if (home.state is AsyncInitial) {
        home.loadHomeData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final hour = DateTime.now().hour;
    final isEvening = hour >= 19 || hour < 5;

    return Scaffold(
      backgroundColor: PColors.ink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isEvening, context),
              const SizedBox(height: 36),
              _buildBody(home, isEvening, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEvening, BuildContext context) {
    final auth = context.watch<AuthProvider>();
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greetingText,
              style: PType.greeting.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 6),
            Text(
              isEvening
                  ? 'Today is complete. Fifteen days now.'
                  : 'A daily space for Scripture, declaration and reflection',
              style: PType.body,
            ),
          ],
        ),
        const Spacer(),
        PStreakPill(streak: isEvening ? 15 : 14),
      ],
    );
  }

  Widget _buildBody(HomeProvider home, bool isEvening, BuildContext context) {
    if (home.state is AsyncLoading || home.state is AsyncInitial) {
      return const Padding(
        padding: EdgeInsets.only(top: 100),
        child: Center(child: CircularProgressIndicator(color: PColors.bone)),
      );
    }

    if (home.state is AsyncError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PEyebrow('Could not load daily updates'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => home.loadHomeData(),
            child: Text('Try again', style: PType.uiStrong),
          ),
        ],
      );
    }

    final homeData = home.state is AsyncData<HomeData>
        ? (home.state as AsyncData<HomeData>).data
        : null;
    final daily = homeData?.dailyVerse;
    final verseText = daily?.text ?? '';
    final rawRef = daily?.reference ?? '';
    final devotionalDay = daily?.devotionalDay;
    final devotionalTitle = daily?.devotionalTitle;
    const versionLabel = 'KJV';
    final displayRef = rawRef.isNotEmpty ? '$rawRef · $versionLabel' : '';

    (String, String, int, int?) parseRef(String ref) {
      if (daily?.bookId != null && daily?.chapter != null) {
        return (
          daily!.bookId!,
          daily.bookName ?? daily.bookId!,
          daily.chapter!,
          daily.verseNumber,
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

    final (bookId, bookName, chapter, verseNumber) = parseRef(rawRef);

    Future<void> openTodaysDevotional() async {
      if (devotionalDay == null) return;
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Left column (58%) ───
        Expanded(
          flex: 58,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's scripture card (Luxury Illuminated Obsidian/Gold)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1915),
                  borderRadius: BorderRadius.circular(PRadius.card),
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
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      const SizedBox(height: 18),
                      if (verseText.isNotEmpty)
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
                        )
                      else
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: PColors.glassFill,
                            borderRadius: BorderRadius.circular(PRadius.chip),
                          ),
                        ),
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
                      Container(
                        height: 1,
                        color: const Color(0x24FFFFFF),
                        margin: const EdgeInsets.symmetric(vertical: 14),
                      ),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
              ),
              const SizedBox(height: 24),

              // Faith declarations card
              if (!isEvening)
                PBoneCard(
                  onTap: () => MainShell.setTab(context, 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('FAITH DECLARATIONS', style: PType.eyebrow.copyWith(color: PColors.clay)),
                          Text('00 / 04', style: PType.counter),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text('Four declarations,\nprepared for you', style: PType.cardTitle),
                          ),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: PColors.ink,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward_rounded, color: PColors.bone, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: PColors.glassFill,
                    borderRadius: BorderRadius.circular(PRadius.card),
                    border: Border.all(color: PColors.glassStroke),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const PEyebrow('Faith Declarations'),
                          Text('04 / 04', style: PType.counter.copyWith(color: PColors.bone62)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '"I walk with strength and\nconfidence today."',
                        style: PType.scripture.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 12),
                      Text('Read them again', style: PType.uiStrong.copyWith(color: PColors.bone70)),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 36),

        // ─── Right column (42%) ───
        Expanded(
          flex: 42,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PEyebrow('More for you'),
              const SizedBox(height: 16),
              PListRow(
                title: isEvening ? 'Evening Psalm' : 'Finding Peace in Uncertainty',
                meta: isEvening ? 'Psalm 4 · 1 min' : "Today's devotional · 2 min",
                onTap: () => MainShell.setTab(context, 3),
              ),
              PListRow(
                title: 'Read the Bible',
                meta: 'Open Bible library',
                onTap: () => MainShell.setTab(context, 1),
              ),
              PListRow(
                title: 'All Topics',
                meta: 'Explore themes and practice',
                onTap: () => MainShell.setTab(context, 3),
              ),
              PListRow(
                title: 'Your Growth',
                meta: '15 day streak',
                onTap: () => MainShell.setTab(context, 4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
