import 'package:flutter/material.dart';
import '../../../../core/state/async_state.dart';
import '../../domain/models/bible_highlight.dart';
import '../../domain/models/bible_version.dart';
import '../../domain/models/book.dart';
import '../../domain/models/chapter.dart';
import '../../domain/ports/bible_repository.dart';
import '../../application/usecases/get_versions_use_case.dart';
import '../../application/usecases/get_books_use_case.dart';
import '../../application/usecases/read_chapter_use_case.dart';

class BibleProvider extends ChangeNotifier {
  BibleProvider({required BibleRepository repository})
      : _repository = repository,
        _getVersions = GetVersionsUseCase(repository: repository),
        _getBooks = GetBooksUseCase(repository: repository),
        _readChapter = ReadChapterUseCase(repository: repository);

  final BibleRepository _repository;
  final GetVersionsUseCase _getVersions;
  final GetBooksUseCase _getBooks;
  final ReadChapterUseCase _readChapter;

  AsyncState<List<BibleVersion>> _versions = const AsyncInitial();
  AsyncState<List<BibleVersion>> get versions => _versions;

  AsyncState<List<Book>> _books = const AsyncInitial();
  AsyncState<List<Book>> get books => _books;

  AsyncState<Chapter> _chapter = const AsyncInitial();
  AsyncState<Chapter> get chapter => _chapter;

  String _selectedVersion = 'RVR1960';
  String get selectedVersion => _selectedVersion;

  String? _selectedBook;
  String? get selectedBook => _selectedBook;

  int _selectedChapter = 1;
  int get selectedChapter => _selectedChapter;

  List<Book> _filteredBooks = [];
  List<Book> get filteredBooks => _filteredBooks;

  // ── Chapter cache: key = "version:bookId:chapterNum" ────────────────────
  // Chapters are immutable text — safe to cache indefinitely per session.
  final Map<String, Chapter> _chapterCache = {};

  // ── Highlights ───────────────────────────────────────────────────────────
  final Set<String> _highlightedVerses = {};
  Set<String> get highlightedVerses => _highlightedVerses;

  final Map<String, BibleHighlight> _highlightsMap = {};
  Map<String, BibleHighlight> get highlightsMap => _highlightsMap;

  List<BibleHighlight> _highlights = [];
  List<BibleHighlight> get highlights => _highlights;

  // ────────────────────────────────────────────────────────────────────────
  // Highlights
  // ────────────────────────────────────────────────────────────────────────

  bool isVerseHighlighted(String bookId, int chapter, int verseNum) {
    return _highlightedVerses.contains('${bookId.toLowerCase()}:$chapter:$verseNum');
  }

  String? getVerseHighlightColor(String bookId, int chapter, int verseNum) {
    final key = '${bookId.toLowerCase()}:$chapter:$verseNum';
    return _highlightsMap[key]?.colorHex;
  }

  BibleHighlight? getVerseHighlight(String bookId, int chapter, int verseNum) {
    final key = '${bookId.toLowerCase()}:$chapter:$verseNum';
    return _highlightsMap[key];
  }

  Future<void> loadHighlights() async {
    try {
      final result = await _repository.getHighlights();
      _highlights = result;
      _highlightedVerses.clear();
      _highlightsMap.clear();
      for (final h in result) {
        final key = '${h.bookId.toLowerCase()}:${h.chapter}:${h.verseNumber}';
        _highlightedVerses.add(key);
        _highlightsMap[key] = h;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> setVerseHighlight(
    String bookId,
    int chapter,
    int verseNum, {
    required String colorHex,
    String? verseText,
  }) async {
    final key = '${bookId.toLowerCase()}:$chapter:$verseNum';
    final existing = _highlightsMap[key];

    // If already highlighted with the exact same color, toggle it off
    if (existing != null && existing.colorHex.toUpperCase() == colorHex.toUpperCase()) {
      return removeVerseHighlight(bookId, chapter, verseNum);
    }

    final newHighlight = BibleHighlight(
      id: existing?.id ?? '',
      userId: existing?.userId ?? '',
      bookId: bookId.toLowerCase(),
      chapter: chapter,
      verseNumber: verseNum,
      verseText: verseText ?? existing?.verseText ?? '',
      version: _selectedVersion,
      colorHex: colorHex,
      createdAt: DateTime.now(),
    );

    _highlightsMap[key] = newHighlight;
    _highlightedVerses.add(key);
    _highlights.removeWhere(
      (h) =>
          h.bookId.toLowerCase() == bookId.toLowerCase() &&
          h.chapter == chapter &&
          h.verseNumber == verseNum,
    );
    _highlights.insert(0, newHighlight);
    notifyListeners();

    try {
      final isNowHighlighted = await _repository.toggleHighlight(
        bookId: bookId,
        chapter: chapter,
        verseNumber: verseNum,
        verseText: verseText ?? existing?.verseText ?? '',
        version: _selectedVersion,
        colorHex: colorHex,
      );
      if (!isNowHighlighted) {
        _highlightsMap.remove(key);
        _highlightedVerses.remove(key);
        _highlights.removeWhere(
          (h) =>
              h.bookId.toLowerCase() == bookId.toLowerCase() &&
              h.chapter == chapter &&
              h.verseNumber == verseNum,
        );
        notifyListeners();
      }
      return isNowHighlighted;
    } catch (_) {
      if (existing != null) {
        _highlightsMap[key] = existing;
        _highlightedVerses.add(key);
      } else {
        _highlightsMap.remove(key);
        _highlightedVerses.remove(key);
        _highlights.removeWhere(
          (h) =>
              h.bookId.toLowerCase() == bookId.toLowerCase() &&
              h.chapter == chapter &&
              h.verseNumber == verseNum,
        );
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeVerseHighlight(
    String bookId,
    int chapter,
    int verseNum,
  ) async {
    final key = '${bookId.toLowerCase()}:$chapter:$verseNum';
    final existing = _highlightsMap.remove(key);
    _highlightedVerses.remove(key);
    _highlights.removeWhere(
      (h) =>
          h.bookId.toLowerCase() == bookId.toLowerCase() &&
          h.chapter == chapter &&
          h.verseNumber == verseNum,
    );
    notifyListeners();

    try {
      await _repository.toggleHighlight(
        bookId: bookId,
        chapter: chapter,
        verseNumber: verseNum,
        verseText: existing?.verseText ?? '',
        version: _selectedVersion,
        colorHex: existing?.colorHex,
      );
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleVerseHighlight(
    String bookId,
    int chapter,
    int verseNum, {
    String? verseText,
    String? colorHex,
  }) async {
    final key = '${bookId.toLowerCase()}:$chapter:$verseNum';
    if (_highlightedVerses.contains(key)) {
      if (colorHex != null &&
          _highlightsMap[key]?.colorHex.toUpperCase() != colorHex.toUpperCase()) {
        return setVerseHighlight(
          bookId,
          chapter,
          verseNum,
          colorHex: colorHex,
          verseText: verseText,
        );
      }
      return removeVerseHighlight(bookId, chapter, verseNum);
    } else {
      return setVerseHighlight(
        bookId,
        chapter,
        verseNum,
        colorHex: colorHex ?? '#F7EBD2',
        verseText: verseText,
      );
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Versions & Books
  // ────────────────────────────────────────────────────────────────────────

  Future<void> loadVersions() async {
    _versions = const AsyncLoading();
    notifyListeners();

    try {
      final result = await _getVersions.execute();
      _versions = AsyncData(result);
      if (result.isNotEmpty && !result.any((v) => v.id == _selectedVersion)) {
        _selectedVersion = result.first.id;
      }
    } catch (e) {
      _versions = AsyncError(e.toString());
    }
    notifyListeners();
  }

  Future<void> loadBooks() async {
    _books = const AsyncLoading();
    notifyListeners();

    try {
      final result = await _getBooks.execute(_selectedVersion);
      _books = AsyncData(result);
      _filteredBooks = result;
    } catch (e) {
      _books = AsyncError(e.toString());
    }
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────────────────
  // Chapters — with in-memory cache
  // ────────────────────────────────────────────────────────────────────────

  Future<void> loadChapter(String bookId, int chapterNum) async {
    _selectedBook = bookId;
    _selectedChapter = chapterNum;

    // Serve instantly from cache if available — avoids hitting the network
    final cacheKey = '$_selectedVersion:${bookId.toLowerCase()}:$chapterNum';
    final cached = _chapterCache[cacheKey];
    if (cached != null) {
      _chapter = AsyncData(cached);
      notifyListeners();
      return;
    }

    _chapter = const AsyncLoading();
    notifyListeners();

    try {
      final result = await _readChapter.execute(bookId, chapterNum, _selectedVersion);
      _chapterCache[cacheKey] = result; // Warm the cache
      _chapter = AsyncData(result);
    } catch (e) {
      _chapter = AsyncError(e.toString());
    }
    notifyListeners();
  }

  /// Silently pre-fetches adjacent chapters in the background so the user
  /// gets instant navigation without any loading spinner.
  /// Uses fire-and-forget to avoid Future type issues with catchError.
  void prefetchChapter(String bookId, int chapterNum, int totalChapters) {
    if (chapterNum < totalChapters) {
      final nextKey = '$_selectedVersion:${bookId.toLowerCase()}:${chapterNum + 1}';
      if (!_chapterCache.containsKey(nextKey)) {
        _warmCache(nextKey, bookId, chapterNum + 1);
      }
    }
    if (chapterNum > 1) {
      final prevKey = '$_selectedVersion:${bookId.toLowerCase()}:${chapterNum - 1}';
      if (!_chapterCache.containsKey(prevKey)) {
        _warmCache(prevKey, bookId, chapterNum - 1);
      }
    }
  }

  /// Fire-and-forget single chapter prefetch — errors are silently ignored.
  Future<void> _warmCache(String key, String bookId, int chapterNum) async {
    try {
      final result = await _readChapter.execute(bookId, chapterNum, _selectedVersion);
      _chapterCache[key] = result;
    } catch (_) {}
  }

  /// Clears the chapter cache (needed when the version changes).
  void clearChapterCache() => _chapterCache.clear();

  void setVersion(String version) {
    _selectedVersion = version;
    clearChapterCache(); // Different version = different text
    loadBooks();
    if (_selectedBook != null) {
      loadChapter(_selectedBook!, _selectedChapter);
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // Book filtering
  // ────────────────────────────────────────────────────────────────────────

  void filterBooks(String query) {
    if (_books is! AsyncData<List<Book>>) return;
    final allBooks = (_books as AsyncData<List<Book>>).data;
    if (query.isEmpty) {
      _filteredBooks = allBooks;
    } else {
      final normalized = _removeAccents(query.toLowerCase());
      _filteredBooks = allBooks
          .where((b) => _removeAccents(b.name.toLowerCase()).contains(normalized))
          .toList();
    }
    notifyListeners();
  }

  String _removeAccents(String input) {
    const accents = 'áéíóúàèìòùäëïöüâêîôûñÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÂÊÎÔÛÑ';
    const noAccents = 'aeiouaeiouaeiouaeiounAEIOUAEIOUAEIOUAEIOUN';
    var result = input;
    for (var i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], noAccents[i]);
    }
    return result;
  }

  /// Returns the exact total number of chapters for a given book,
  /// querying loaded books or falling back to the canonical chapter map.
  int getBookTotalChapters(String bookId, {int defaultChapters = 1}) {
    final cleanId = _removeAccents(bookId.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''));
    if (_books is AsyncData<List<Book>>) {
      final list = (_books as AsyncData<List<Book>>).data;
      for (final b in list) {
        final bClean = _removeAccents(b.id.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''));
        final bNameClean = _removeAccents(b.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''));
        if (bClean == cleanId || bNameClean == cleanId) {
          if (b.chapters > 0) return b.chapters;
        }
      }
    }
    return _canonicalBookChapters[cleanId] ?? defaultChapters;
  }

  static const Map<String, int> _canonicalBookChapters = {
    // Old Testament
    'genesis': 50, 'exodus': 40, 'exodo': 40, 'leviticus': 27, 'levitico': 27,
    'numbers': 36, 'numeros': 36, 'deuteronomy': 34, 'deuteronomio': 34,
    'joshua': 24, 'josue': 24, 'judges': 21, 'jueces': 21, 'ruth': 4, 'rut': 4,
    '1samuel': 31, '2samuel': 24, '1kings': 22, '1reyes': 22, '2kings': 25, '2reyes': 25,
    '1chronicles': 29, '1cronicas': 29, '2chronicles': 36, '2cronicas': 36,
    'ezra': 10, 'esdras': 10, 'nehemiah': 13, 'nehemias': 13, 'esther': 10, 'ester': 10,
    'job': 42, 'psalms': 150, 'psalm': 150, 'salmos': 150, 'salmo': 150,
    'proverbs': 31, 'proverbios': 31, 'ecclesiastes': 12, 'eclesiastes': 12,
    'songofsolomon': 8, 'cantares': 8, 'songofsongs': 8,
    'isaiah': 66, 'isaias': 66, 'jeremiah': 52, 'jeremias': 52,
    'lamentations': 5, 'lamentaciones': 5, 'ezekiel': 48, 'ezequiel': 48,
    'daniel': 12, 'hosea': 14, 'oseas': 14, 'joel': 3, 'amos': 9,
    'obadiah': 1, 'abdias': 1, 'jonah': 4, 'jonas': 4, 'micah': 7, 'miqueas': 7,
    'nahum': 3, 'habakkuk': 3, 'habacuc': 3, 'zephaniah': 3, 'sofonias': 3,
    'haggai': 2, 'hageo': 2, 'zechariah': 14, 'zacarias': 14, 'malachi': 4, 'malaquias': 4,
    // New Testament
    'matthew': 28, 'mateo': 28, 'mark': 16, 'marcos': 16, 'luke': 24, 'lucas': 24,
    'john': 21, 'juan': 21, 'acts': 28, 'hechos': 28, 'romans': 16, 'romanos': 16,
    '1corinthians': 16, '1corintios': 16, '2corinthians': 13, '2corintios': 13,
    'galatians': 6, 'galatas': 6, 'ephesians': 6, 'efesios': 6,
    'philippians': 4, 'filipenses': 4, 'colossians': 4, 'colosenses': 4,
    '1thessalonians': 5, '1tesalonicenses': 5, '2thessalonians': 3, '2tesalonicenses': 3,
    '1timothy': 6, '1timoteo': 6, '2timothy': 4, '2timoteo': 4,
    'titus': 3, 'tito': 3, 'philemon': 1, 'filemon': 1,
    'hebrews': 13, 'hebreos': 13, 'james': 5, 'santiago': 5,
    '1peter': 5, '1pedro': 5, '2peter': 3, '2pedro': 3,
    '1john': 5, '1juan': 5, '2john': 1, '2juan': 1, '3john': 1, '3juan': 1,
    'jude': 1, 'judas': 1, 'revelation': 22, 'apocalipsis': 22,
  };
}
