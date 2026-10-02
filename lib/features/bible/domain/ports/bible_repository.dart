import '../models/bible_version.dart';
import '../models/book.dart';
import '../models/chapter.dart';

abstract class BibleRepository {
  Future<List<BibleVersion>> getVersions();
  Future<List<Book>> getBooks(String version);
  Future<Chapter> getChapter(String book, int chapter, String version);
}
