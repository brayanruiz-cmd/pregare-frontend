import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/ui/organisms/main_shell.dart';
import '../../../../core/ui/primitives/primitives.dart';
import '../../domain/models/bible_version.dart';
import '../../domain/models/book.dart';
import '../../domain/models/chapter.dart';
import '../providers/bible_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen 10 — Bible library (Background: INK · With floating nav)
// ─────────────────────────────────────────────────────────────────────────────
class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  int _currentTab = 0; // 0 = Old Testament, 1 = New Testament
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BibleProvider>();
      provider.loadVersions();
      provider.loadBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openChapterSelection(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BibleChapterSelectionScreen(book: book),
      ),
    );
  }


  void _showVersionPicker(BibleProvider provider) {
    final versionsState = provider.versions;
    if (versionsState is! AsyncData<List<BibleVersion>>) return;
    final versions = versionsState.data;

    showModalBottomSheet(
      context: context,
      backgroundColor: PColors.ink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(PRadius.flip)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PEyebrow('Bible Version'),
                const SizedBox(height: 12),
                ...versions.map((v) {
                  final isSelected = v.id == provider.selectedVersion;
                  return PListRow(
                    title: v.name,
                    meta: v.abbreviation,
                    showChevron: false,
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: PColors.bone, size: 18)
                        : null,
                    onTap: () {
                      provider.setVersion(v.id);
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BibleProvider>();

    return PScreen(
      background: const PScreenBackground.ink(),
      hasNav: true,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutter),
      floatingWidget: PBottomNav(
        currentIndex: 1,
        onTap: (i) => MainShell.setTab(context, i),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 16),

              // ── Header: Title "Bible" + Translation selector (NIV ⌄) ───────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Bible', style: PType.display),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _showVersionPicker(provider),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: PColors.glassFill,
                          borderRadius: BorderRadius.circular(PRadius.chip),
                          border: Border.all(color: PColors.hairline, width: 1.0),
                        ),
                        child: Row(
                          children: [
                            Text(
                              provider.selectedVersion,
                              style: PType.meta.copyWith(color: PColors.bone, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: PColors.bone62, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Search bar in library ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: PColors.glassFill,
                  borderRadius: BorderRadius.circular(PRadius.chip),
                  border: Border.all(color: PColors.hairline),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => provider.filterBooks(val),
                  style: PType.body.copyWith(color: PColors.bone),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search_rounded, color: PColors.bone45, size: 18),
                    hintText: 'Search books...',
                    hintStyle: PType.meta.copyWith(color: PColors.bone45),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Tabs: Old Testament | New Testament ────────────────────────────
              _TabRow(
                labels: const ['Old Testament', 'New Testament'],
                activeIndex: _currentTab,
                onTap: (i) => setState(() => _currentTab = i),
              ),
              const SizedBox(height: 20),

              // ── Responsive books grid ──────────────────────────────────────────
              _BooksContent(
                provider: provider,
                currentTab: _currentTab,
                onBookTap: _openChapterSelection,
              ),

              const SizedBox(height: PSpace.navClearance),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 11 — Choose a book (Background: BONE · No nav)
// ─────────────────────────────────────────────────────────────────────────────
class BibleBookSelectionScreen extends StatefulWidget {
  const BibleBookSelectionScreen({super.key});

  @override
  State<BibleBookSelectionScreen> createState() => _BibleBookSelectionScreenState();
}

class _BibleBookSelectionScreenState extends State<BibleBookSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onBookSelected(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BibleChapterSelectionScreen(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BibleProvider>();
    final books = provider.filteredBooks;

    return PScreen(
      background: const PScreenBackground.bone(),
      hasNav: false,
      safeAreaBottom: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutterLight),
      header: _BoneHeader(
        title: 'Choose a book',
        action: const SizedBox(width: 36),
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Search input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: PColors.ink06,
                  borderRadius: BorderRadius.circular(PRadius.chip),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => provider.filterBooks(val),
                  style: PType.body.copyWith(color: PColors.ink),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search_rounded, color: PColors.ink40, size: 18),
                    hintText: 'Search books...',
                    hintStyle: PType.meta.copyWith(color: PColors.stone),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Pentateuch / Old Testament
              PEyebrow('Pentateuch', color: PColors.stone),
              const SizedBox(height: 4),
              ...books.where((b) => b.testament == 'OT').take(5).map((b) => _buildBookRow(b)),

              const SizedBox(height: 28),

              // Historical
              PEyebrow('Historical', color: PColors.stone),
              const SizedBox(height: 4),
              ...books.where((b) => b.testament == 'OT').skip(5).map((b) => _buildBookRow(b)),

              if (books.any((b) => b.testament == 'NT')) ...[
                const SizedBox(height: 28),
                PEyebrow('New Testament', color: PColors.stone),
                const SizedBox(height: 4),
                ...books.where((b) => b.testament == 'NT').map((b) => _buildBookRow(b)),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookRow(Book book) {
    return PListRow(
      title: book.name,
      meta: '${book.chapters} ch.',
      isLight: true,
      showChevron: false,
      onTap: () => _onBookSelected(book),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 12 — Chapter selection (Background: BONE · No nav)
// ─────────────────────────────────────────────────────────────────────────────
class BibleChapterSelectionScreen extends StatelessWidget {
  const BibleChapterSelectionScreen({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BibleProvider>();
    final isDesktop = AppBreakpoints.isDesktop(context);
    final isTablet = AppBreakpoints.isTablet(context);

    return PScreen(
      background: const PScreenBackground.bone(),
      hasNav: false,
      safeAreaBottom: false,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 36 : PSpace.gutterLight,
      ),
      header: _BoneHeader(
        title: book.name,
        action: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: PColors.ink06,
            borderRadius: BorderRadius.circular(PRadius.chip),
            border: Border.all(color: PColors.ink14.withOpacity(0.18)),
          ),
          child: Text(
            provider.selectedVersion,
            style: PType.meta.copyWith(
              color: PColors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 48),
            children: [
              const SizedBox(height: 12),

              // Title and Meta
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.name,
                          style: PType.display.copyWith(
                            color: PColors.ink,
                            fontSize: isDesktop ? 38 : 30,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _MetaBadge(
                              text: '${book.chapters} chapters',
                              icon: Icons.format_list_numbered_rounded,
                            ),
                            _MetaBadge(
                              text: book.isOldTestament
                                  ? 'Old Testament'
                                  : 'New Testament',
                              icon: Icons.menu_book_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Quick start button
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BibleReaderScreen(
                              bookId: book.id,
                              bookName: book.name,
                              initialChapter: 1,
                              totalChapters: book.chapters,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: PColors.ink,
                          borderRadius: BorderRadius.circular(PRadius.pill),
                          boxShadow: [
                            BoxShadow(
                              color: PColors.ink.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              color: PColors.bone,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Read Ch. 1',
                              style: PType.uiStrong.copyWith(
                                color: PColors.bone,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Divider(color: PColors.ink10, height: 1),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select a chapter',
                    style: PType.uiStrong.copyWith(
                      color: PColors.ink.withValues(alpha: 0.75),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '1 – ${book.chapters}',
                    style: PType.meta.copyWith(
                      color: PColors.stone,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Responsive Chapter Grid (Compact, elegant tiles instead of massive squares)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isDesktop ? 60 : (isTablet ? 64 : 68),
                  mainAxisExtent: isDesktop ? 54 : (isTablet ? 58 : 60),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: book.chapters,
                itemBuilder: (context, index) {
                  final chapterNum = index + 1;
                  final isActive = false; // No longer hardcoded active chapter

                  return _ChapterTile(
                    chapterNum: chapterNum,
                    isActive: isActive,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BibleReaderScreen(
                            bookId: book.id,
                            bookName: book.name,
                            initialChapter: chapterNum,
                            totalChapters: book.chapters,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: PColors.ink06,
        borderRadius: BorderRadius.circular(PRadius.chip),
        border: Border.all(color: PColors.ink14.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: PColors.stone),
          const SizedBox(width: 5),
          Text(
            text,
            style: PType.meta.copyWith(
              color: PColors.ink.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterTile extends StatefulWidget {
  const _ChapterTile({
    required this.chapterNum,
    required this.isActive,
    required this.onTap,
  });

  final int chapterNum;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_ChapterTile> createState() => _ChapterTileState();
}

class _ChapterTileState extends State<_ChapterTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isActive
        ? PColors.ink
        : (_isHovered ? PColors.ink10 : PColors.ink06);
    final fg = widget.isActive
        ? PColors.bone
        : (_isHovered ? PColors.ink : PColors.ink.withOpacity(0.85));
    final border = widget.isActive
        ? Border.all(color: PColors.ink, width: 1.5)
        : Border.all(
            color: _isHovered ? PColors.ink40 : PColors.ink14.withOpacity(0.18),
            width: 1.0,
          );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          transform: _isHovered
              ? Matrix4.diagonal3Values(1.05, 1.05, 1.0)
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: border,
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: PColors.ink.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '${widget.chapterNum}',
              style: PType.rowTitle.copyWith(
                color: fg,
                fontSize: 15,
                fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 13 — Reader with Tap-to-Highlight / Bookmark (Background: BONE · No nav)
// ─────────────────────────────────────────────────────────────────────────────
class BibleReaderScreen extends StatefulWidget {
  final String bookId;
  final String bookName;
  final int initialChapter;
  final int totalChapters;

  const BibleReaderScreen({
    super.key,
    required this.bookId,
    required this.bookName,
    required this.initialChapter,
    this.totalChapters = 24,
  });

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  late int _currentChapter;
  double _fontSizeDelta = 0;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.initialChapter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BibleProvider>().loadChapter(widget.bookId, _currentChapter);
    });
  }

  void _goToChapter(int chapter) {
    if (chapter < 1 || chapter > widget.totalChapters) return;
    setState(() => _currentChapter = chapter);
    context.read<BibleProvider>().loadChapter(widget.bookId, chapter);
  }

  void _toggleFontSize() {
    setState(() {
      _fontSizeDelta = _fontSizeDelta == 0 ? 3.0 : (_fontSizeDelta == 3.0 ? -2.0 : 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BibleProvider>();

    return PScreen(
      background: const PScreenBackground.bone(),
      hasNav: false,
      safeAreaBottom: false,
      padding: const EdgeInsets.symmetric(horizontal: PSpace.gutterLight),
      header: _BoneHeader(
        title: '${widget.bookName} $_currentChapter',
        titleSuffix: const Icon(Icons.keyboard_arrow_down_rounded, color: PColors.ink40, size: 18),
        onBack: () => Navigator.of(context).pop(),
        action: Row(
          children: [
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tap any verse to highlight or bookmark it.'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Icon(Icons.notes_rounded, color: PColors.ink40, size: 18),
            ),
            const SizedBox(width: 14),
            GestureDetector(
              onTap: _toggleFontSize,
              child: const Icon(Icons.format_size_rounded, color: PColors.ink40, size: 18),
            ),
          ],
        ),
      ),
      floatingWidget: Positioned(
        bottom: 24,
        left: PSpace.gutterLight,
        right: PSpace.gutterLight,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: _ChapterPager(
              currentChapter: _currentChapter,
              totalChapters: widget.totalChapters,
              bookName: widget.bookName,
              onPrev: _currentChapter > 1 ? () => _goToChapter(_currentChapter - 1) : null,
              onNext: _currentChapter < widget.totalChapters ? () => _goToChapter(_currentChapter + 1) : null,
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: _buildVersesContent(provider),
        ),
      ),
    );
  }

  Widget _buildVersesContent(BibleProvider provider) {
    if (provider.chapter is AsyncLoading) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text('Loading chapter...', style: TextStyle(color: PColors.stone)),
        ),
      );
    }

    if (provider.chapter is AsyncError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PEyebrow('Could not load chapter', color: PColors.stone),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => provider.loadChapter(widget.bookId, _currentChapter),
            child: Text('Try again', style: PType.uiStrong.copyWith(color: PColors.ink)),
          ),
        ],
      );
    }

    if (provider.chapter is AsyncData<Chapter>) {
      final chapterData = (provider.chapter as AsyncData<Chapter>).data;
      final verses = chapterData.verses;

      return ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 8),
          PEyebrow('Chapter ${_numberToWords(_currentChapter)}', color: PColors.stone),
          const SizedBox(height: 8),
          Text(
            '${widget.bookName}\nChapter $_currentChapter',
            style: PType.display.copyWith(color: PColors.ink, fontSize: 32, height: 1.15),
          ),
          const SizedBox(height: 32),

          ...verses.map((v) => _buildVerse(provider, v)),

          const SizedBox(height: 120),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildVerse(BibleProvider provider, Verse v) {
    final isHighlighted = provider.isVerseHighlighted(widget.bookId, _currentChapter, v.number);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          provider.toggleVerseHighlight(widget.bookId, _currentChapter, v.number);
          final newState = !isHighlighted;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newState
                    ? '${widget.bookName} $_currentChapter:${v.number} highlighted and saved'
                    : '${widget.bookName} $_currentChapter:${v.number} highlight removed',
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          padding: isHighlighted
              ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
              : const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isHighlighted ? PColors.ink06 : Colors.transparent,
            borderRadius: BorderRadius.circular(PRadius.tile),
            border: isHighlighted
                ? const Border(left: BorderSide(color: PColors.clay, width: 3.0))
                : null,
          ),
          child: _buildVerseSpan('${v.number}', v.text, isHighlighted: isHighlighted),
        ),
      ),
    );
  }

  Widget _buildVerseSpan(String number, String text, {bool isHighlighted = false}) {
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            child: Transform.translate(
              offset: const Offset(0, -4),
              child: Text(
                '$number ',
                style: TextStyle(
                  fontFamily: 'Hanken Grotesk',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isHighlighted ? PColors.clay : PColors.ink40,
                ),
              ),
            ),
          ),
          TextSpan(
            text: text,
            style: PType.scripture.copyWith(
              color: PColors.ink,
              fontSize: 18 + _fontSizeDelta,
              height: 1.65,
              fontWeight: isHighlighted ? FontWeight.w400 : FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  String _numberToWords(int n) {
    const words = [
      'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
      'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen',
      'Nineteen', 'Twenty', 'Twenty-One', 'Twenty-Two', 'Twenty-Three', 'Twenty-Four', 'Twenty-Five',
    ];
    return n < words.length ? words[n] : '$n';
  }
}

// ─── Books content (Responsive grid with compact cards) ───────────────────────
class _BooksContent extends StatelessWidget {
  const _BooksContent({
    required this.provider,
    required this.currentTab,
    required this.onBookTap,
  });

  final BibleProvider provider;
  final int currentTab;
  final void Function(Book) onBookTap;

  @override
  Widget build(BuildContext context) {
    if (provider.books is AsyncLoading) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('Loading books...', style: TextStyle(color: PColors.bone45)),
        ),
      );
    }

    if (provider.books is AsyncError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PEyebrow('Error loading books'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => provider.loadBooks(),
            child: Text('Try again', style: PType.uiStrong),
          ),
        ],
      );
    }

    if (provider.books is AsyncData<List<Book>>) {
      final allBooks = provider.filteredBooks;
      final targetTestament = currentTab == 0 ? 'OT' : 'NT';
      final filtered = allBooks.where((b) => b.testament == targetTestament).toList();

      if (filtered.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: PEyebrow('No matching books found')),
        );
      }

      final isDesktop = AppBreakpoints.isDesktop(context);
      final isTablet = AppBreakpoints.isTablet(context);

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: isDesktop ? 220 : (isTablet ? 190 : 180),
          mainAxisExtent: 74,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final book = filtered[index];
          final isActive = provider.selectedBook != null &&
              book.id.toLowerCase() == provider.selectedBook!.toLowerCase();

          return _BookCard(
            book: book,
            isActive: isActive,
            activeChapter: isActive ? provider.selectedChapter : null,
            onTap: () => onBookTap(book),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}

class _BookCard extends StatefulWidget {
  const _BookCard({
    required this.book,
    required this.isActive,
    this.activeChapter,
    required this.onTap,
  });

  final Book book;
  final bool isActive;
  final int? activeChapter;
  final VoidCallback onTap;

  @override
  State<_BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<_BookCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final isActive = widget.isActive;
    final abbr = book.name.length <= 3 ? book.name : book.name.substring(0, 2);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0x33FFFFFF)
                : (_isHovered ? const Color(0x2BFFFFFF) : PColors.glassFill),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? PColors.bone
                  : (_isHovered ? PColors.bone70 : PColors.hairline),
              width: isActive ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isActive ? PColors.bone : PColors.hairline,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    abbr,
                    style: TextStyle(
                      color: isActive ? PColors.ink : PColors.bone,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      book.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PType.rowTitle.copyWith(
                        fontSize: 14,
                        color: _isHovered || isActive ? PColors.bone : PColors.bone85,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isActive
                          ? 'Reading · ch. ${widget.activeChapter ?? 1}'
                          : '${book.chapters} ch.',
                      style: PType.meta.copyWith(
                        fontSize: 11,
                        color: isActive ? PColors.clay : PColors.bone55,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: _isHovered ? PColors.bone : PColors.bone45,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Text tab row (Old Testament / New Testament) ─────────────────────────────
class _TabRow extends StatelessWidget {
  const _TabRow({required this.labels, required this.activeIndex, required this.onTap});
  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: labels.asMap().entries.map((e) {
        final isActive = e.key == activeIndex;
        return Padding(
          padding: EdgeInsets.only(right: e.key < labels.length - 1 ? 24 : 0),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onTap(e.key),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.value,
                    style: PType.uiStrong.copyWith(
                      color: isActive ? PColors.bone : PColors.bone45,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 1.5,
                    width: 60,
                    color: isActive ? PColors.bone : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Bottom floating chapter pager ────────────────────────────────────────────
class _ChapterPager extends StatelessWidget {
  const _ChapterPager({
    required this.currentChapter,
    required this.totalChapters,
    required this.bookName,
    this.onPrev,
    this.onNext,
  });

  final int currentChapter;
  final int totalChapters;
  final String bookName;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: PColors.bone,
        borderRadius: BorderRadius.circular(PRadius.pill),
        border: Border.all(color: PColors.ink14, width: 1.0),
        boxShadow: PShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MouseRegion(
            cursor: onPrev != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: onPrev,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: onPrev != null ? PColors.ink10 : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: onPrev != null ? PColors.ink : PColors.ink14,
                  size: 20,
                ),
              ),
            ),
          ),
          Text(
            '$bookName $currentChapter of $totalChapters',
            style: PType.meta.copyWith(color: PColors.ink, fontWeight: FontWeight.w600, fontSize: 13),
          ),
          MouseRegion(
            cursor: onNext != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: onNext,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: onNext != null ? PColors.ink : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: onNext != null ? PColors.bone : PColors.ink14,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header for BONE screens ──────────────────────────────────────────────────
class _BoneHeader extends StatelessWidget {
  const _BoneHeader({
    required this.title,
    required this.onBack,
    this.titleSuffix,
    this.action,
  });

  final String title;
  final VoidCallback onBack;
  final Widget? titleSuffix;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Icons.chevron_left_rounded, color: PColors.ink, size: 28),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: PType.uiStrong.copyWith(color: PColors.ink, fontSize: 16),
                ),
                ?titleSuffix,
              ],
            ),
          ),
          action ?? const SizedBox(width: 36),
        ],
      ),
    );
  }
}
