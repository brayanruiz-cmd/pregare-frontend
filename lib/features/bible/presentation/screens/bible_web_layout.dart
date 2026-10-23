import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/state/async_state.dart';
import '../../../../../core/theme/tokens.dart';
import '../../../../../core/ui/primitives/primitives.dart';
import '../providers/bible_provider.dart';
import '../../../../core/ui/molecules/auth_prompt_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/book.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/highlight_color_option.dart';
import '../widgets/highlight_color_picker_sheet.dart';

/// Web layout for Bible: book list on left, reader on right adhering to tokens.
class BibleWebLayout extends StatefulWidget {
  const BibleWebLayout({super.key});

  @override
  State<BibleWebLayout> createState() => _BibleWebLayoutState();
}

class _BibleWebLayoutState extends State<BibleWebLayout> {
  final _searchController = TextEditingController();
  Book? _activeBook;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bible = context.read<BibleProvider>();
      if (bible.books is AsyncInitial) {
        bible.loadVersions();
        bible.loadBooks();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectBook(BibleProvider bible, Book book) {
    setState(() => _activeBook = book);
    bible.loadChapter(book.id, 1);
  }

  @override
  Widget build(BuildContext context) {
    final bible = context.watch<BibleProvider>();

    return Scaffold(
      backgroundColor: PColors.ink,
      body: SafeArea(
        child: Row(
          children: [
            // ─── Left panel: search + book list ───
            Container(
              width: 320,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(color: PColors.hairline, width: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bible', style: PType.display.copyWith(fontSize: 26)),
                        const SizedBox(height: 4),
                        const PEyebrow('Select a book to read'),
                      ],
                    ),
                  ),

                  // Version chips
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _VersionChip(
                          label: 'KJV',
                          isSelected: bible.selectedVersion == 'KJV',
                          onTap: () => bible.setVersion('KJV'),
                        ),
                        const SizedBox(width: 8),
                        _VersionChip(
                          label: 'RVR1960',
                          isSelected: bible.selectedVersion == 'RVR1960',
                          onTap: () => bible.setVersion('RVR1960'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: PColors.glassFill,
                        borderRadius: BorderRadius.circular(PRadius.chip),
                        border: Border.all(color: PColors.hairline),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => bible.filterBooks(v),
                        style: PType.meta.copyWith(color: PColors.bone),
                        decoration: InputDecoration(
                          hintText: 'Search books…',
                          hintStyle: PType.meta.copyWith(color: PColors.bone45),
                          prefixIcon: const Icon(Icons.search, size: 18, color: PColors.bone45),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Book list
                  Expanded(
                    child: bible.books is AsyncLoading || bible.books is AsyncInitial
                        ? const Center(child: CircularProgressIndicator(color: PColors.bone))
                        : bible.books is AsyncError
                            ? Center(
                                child: GestureDetector(
                                  onTap: () {
                                    bible.loadBooks();
                                    bible.loadVersions();
                                  },
                                  child: Text('Retry', style: PType.uiStrong),
                                ),
                              )
                            : _WebBookList(
                                books: bible.filteredBooks,
                                selectedBookId: _activeBook?.id,
                                onBookTap: (book) => _selectBook(bible, book),
                              ),
                  ),
                ],
              ),
            ),

            // ─── Right panel: reader ───
            Expanded(
              child: _activeBook == null
                  ? const _BibleWelcomePanel()
                  : _BibleChapterReader(
                      book: _activeBook!,
                      bible: bible,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BibleWelcomePanel extends StatelessWidget {
  const _BibleWelcomePanel();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_stories_outlined, size: 56, color: PColors.bone45),
          const SizedBox(height: 16),
          const PEyebrow('Select a book'),
          const SizedBox(height: 6),
          Text('Choose a book from the left panel to begin reading.', style: PType.body),
        ],
      ),
    );
  }
}

class _BibleChapterReader extends StatelessWidget {
  const _BibleChapterReader({
    required this.book,
    required this.bible,
  });

  final Book book;
  final BibleProvider bible;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: PColors.hairline, width: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${book.name} ${bible.selectedChapter}',
                    style: PType.display.copyWith(fontSize: 24),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: PColors.glassFill,
                      borderRadius: BorderRadius.circular(PRadius.chip),
                      border: Border.all(color: PColors.hairline),
                    ),
                    child: Text(
                      bible.selectedVersion,
                      style: PType.meta.copyWith(color: PColors.bone, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Chapter pills
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: book.chapters,
                  itemBuilder: (context, index) {
                    final chapterNum = index + 1;
                    final isSelected = bible.selectedChapter == chapterNum;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => bible.loadChapter(book.id, chapterNum),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? PColors.bone : PColors.glassFill,
                            borderRadius: BorderRadius.circular(PRadius.pill),
                            border: Border.all(color: isSelected ? PColors.bone : PColors.hairline),
                          ),
                          child: Center(
                            child: Text(
                              'Ch. $chapterNum',
                              style: PType.meta.copyWith(
                                color: isSelected ? PColors.ink : PColors.bone70,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Verses reading area
        Expanded(
          child: _buildVersesContent(bible),
        ),
      ],
    );
  }

  Widget _buildVersesContent(BibleProvider bible) {
    if (bible.chapter is AsyncLoading || bible.chapter is AsyncInitial) {
      return const Center(child: CircularProgressIndicator(color: PColors.bone));
    }

    if (bible.chapter is AsyncError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PEyebrow('Could not load chapter'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => bible.loadChapter(book.id, bible.selectedChapter),
              child: Text('Retry', style: PType.uiStrong),
            ),
          ],
        ),
      );
    }

    if (bible.chapter is AsyncData) {
      final chapterData = (bible.chapter as AsyncData<Chapter>).data;
      final verses = chapterData.verses;

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        itemCount: verses.length,
        itemBuilder: (context, index) {
          final v = verses[index];
          final isHighlighted = bible.isVerseHighlighted(book.id, bible.selectedChapter, v.number);
          final colorHex = bible.getVerseHighlightColor(book.id, bible.selectedChapter, v.number);
          final colorOption = HighlightColorOption.fromHex(colorHex);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  final auth = context.read<AuthProvider>();
                  if (!auth.isAuthenticated) {
                    AuthPromptSheet.show(
                      context,
                      isLoginOnly: false,
                      onSuccess: () {
                        HighlightColorPickerSheet.show(
                          context,
                          bookId: book.id,
                          bookName: book.name,
                          chapter: bible.selectedChapter,
                          verse: v,
                        );
                      },
                    );
                  } else {
                    HighlightColorPickerSheet.show(
                      context,
                      bookId: book.id,
                      bookName: book.name,
                      chapter: bible.selectedChapter,
                      verse: v,
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: isHighlighted
                      ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
                      : const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? colorOption.fill.withValues(alpha: 0.22)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(PRadius.tile),
                    border: isHighlighted
                        ? Border.all(color: colorOption.accent, width: 1.5)
                        : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${v.number}',
                          style: PType.meta.copyWith(
                            color: isHighlighted ? colorOption.accent : PColors.bone45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          v.text,
                          style: PType.scripture.copyWith(
                            fontSize: 18,
                            height: 1.65,
                            color: isHighlighted ? PColors.bone : PColors.bone85,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}

class _WebBookList extends StatelessWidget {
  const _WebBookList({
    required this.books,
    required this.onBookTap,
    this.selectedBookId,
  });

  final List<Book> books;
  final ValueChanged<Book> onBookTap;
  final String? selectedBookId;

  @override
  Widget build(BuildContext context) {
    final oldBooks = books.where((b) => b.testament == 'OT').toList();
    final newBooks = books.where((b) => b.testament == 'NT').toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        if (oldBooks.isNotEmpty) ...[
          const PEyebrow('Old Testament'),
          const SizedBox(height: 8),
          ...oldBooks.map((b) => _WebBookTile(
                book: b,
                isSelected: b.id == selectedBookId,
                onTap: () => onBookTap(b),
              )),
          const SizedBox(height: 16),
        ],
        if (newBooks.isNotEmpty) ...[
          const PEyebrow('New Testament'),
          const SizedBox(height: 8),
          ...newBooks.map((b) => _WebBookTile(
                book: b,
                isSelected: b.id == selectedBookId,
                onTap: () => onBookTap(b),
              )),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _WebBookTile extends StatelessWidget {
  const _WebBookTile({
    required this.book,
    required this.onTap,
    this.isSelected = false,
  });

  final Book book;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? PColors.glassFill : Colors.transparent,
            borderRadius: BorderRadius.circular(PRadius.tile),
            border: isSelected ? Border.all(color: PColors.hairline) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.name,
                      style: PType.rowTitle.copyWith(
                        color: isSelected ? PColors.bone : PColors.bone70,
                      ),
                    ),
                    Text('${book.chapters} chapters', style: PType.meta),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 16, color: PColors.bone45),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionChip extends StatelessWidget {
  const _VersionChip({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? PColors.bone : PColors.glassFill,
          borderRadius: BorderRadius.circular(PRadius.chip),
          border: Border.all(color: isSelected ? PColors.bone : PColors.hairline),
        ),
        child: Text(
          label,
          style: PType.meta.copyWith(
            color: isSelected ? PColors.ink : PColors.bone70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
