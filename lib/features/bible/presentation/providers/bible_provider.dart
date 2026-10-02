import 'package:flutter/material.dart';
import '../../../../core/state/async_state.dart';
import '../../domain/models/bible_version.dart';
import '../../domain/models/book.dart';
import '../../domain/models/chapter.dart';
import '../../domain/ports/bible_repository.dart';
import '../../application/usecases/get_versions_use_case.dart';
import '../../application/usecases/get_books_use_case.dart';
import '../../application/usecases/read_chapter_use_case.dart';

class BibleProvider extends ChangeNotifier {
  BibleProvider({required BibleRepository repository})
      : _getVersions = GetVersionsUseCase(repository: repository),
        _getBooks = GetBooksUseCase(repository: repository),
        _readChapter = ReadChapterUseCase(repository: repository);

  final GetVersionsUseCase _getVersions;
  final GetBooksUseCase _getBooks;
  final ReadChapterUseCase _readChapter;

  AsyncState<List<BibleVersion>> _versions = const AsyncInitial();
  AsyncState<List<BibleVersion>> get versions => _versions;

  AsyncState<List<Book>> _books = const AsyncInitial();
  AsyncState<List<Book>> get books => _books;

  AsyncState<Chapter> _chapter = const AsyncInitial();
  AsyncState<Chapter> get chapter => _chapter;

  String _selectedVersion = 'NIV';
  String get selectedVersion => _selectedVersion;

  String? _selectedBook;
  String? get selectedBook => _selectedBook;

  int _selectedChapter = 1;
  int get selectedChapter => _selectedChapter;

  List<Book> _filteredBooks = [];
  List<Book> get filteredBooks => _filteredBooks;

  // Set of highlighted verse keys in format "bookId:chapter:verseNum"
  final Set<String> _highlightedVerses = {};
  Set<String> get highlightedVerses => _highlightedVerses;

  bool isVerseHighlighted(String bookId, int chapter, int verseNum) {
    return _highlightedVerses.contains('${bookId.toLowerCase()}:$chapter:$verseNum');
  }

  void toggleVerseHighlight(String bookId, int chapter, int verseNum) {
    final key = '${bookId.toLowerCase()}:$chapter:$verseNum';
    if (_highlightedVerses.contains(key)) {
      _highlightedVerses.remove(key);
    } else {
      _highlightedVerses.add(key);
    }
    notifyListeners();
  }

  Future<void> loadVersions() async {
    _versions = const AsyncLoading();
    notifyListeners();

    try {
      final result = await _getVersions.execute();
      _versions = AsyncData(result);
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

  Future<void> loadChapter(String bookId, int chapterNum) async {
    _selectedBook = bookId;
    _selectedChapter = chapterNum;
    _chapter = const AsyncLoading();
    notifyListeners();

    try {
      final result = await _readChapter.execute(bookId, chapterNum, _selectedVersion);
      _chapter = AsyncData(result);
    } catch (e) {
      _chapter = AsyncError(e.toString());
    }
    notifyListeners();
  }

  void setVersion(String version) {
    _selectedVersion = version;
    loadBooks();
    if (_selectedBook != null) {
      loadChapter(_selectedBook!, _selectedChapter);
    }
  }

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
}
