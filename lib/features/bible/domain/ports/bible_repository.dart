import '../models/bible_highlight.dart';
import '../models/bible_version.dart';
import '../models/book.dart';
import '../models/chapter.dart';

abstract class BibleRepository {
  Future<List<BibleVersion>> getVersions();
  Future<List<Book>> getBooks(String version);
  Future<Chapter> getChapter(String book, int chapter, String version);
  Future<List<BibleHighlight>> getHighlights();
  Future<bool> toggleHighlight({
    required String bookId,
    required int chapter,
    required int verseNumber,
    required String verseText,
    String? version,
    String? colorHex,
  });
}
