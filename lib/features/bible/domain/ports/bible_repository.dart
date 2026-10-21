import '../models/bible_highlight.dart';
import '../models/bible_version.dart';
import '../models/book.dart';
import '../models/chapter.dart';
import '../models/verse_collection.dart';

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

  // Verse Collections
  Future<List<VerseCollection>> getCollections();
  Future<VerseCollection> createCollection(String title, {String? colorHex, String? description});
  Future<bool> deleteCollection(String id);
  Future<List<String>> getVerseCollectionIds({
    required String bookId,
    required int chapter,
    required int verseNumber,
  });
  Future<bool> toggleVerseInCollection({
    required String collectionId,
    required String bookId,
    String? bookName,
    required int chapter,
    required int verseNumber,
    required String verseText,
    String? colorHex,
    String? version,
  });
  Future<VerseCollection?> getCollectionDetails(String id);
}
