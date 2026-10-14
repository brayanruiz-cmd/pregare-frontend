import '../../../../core/infrastructure/http/http_client.dart';
import '../../domain/models/bible_highlight.dart';
import '../../domain/models/bible_version.dart';
import '../../domain/models/book.dart';
import '../../domain/models/chapter.dart';
import '../../domain/ports/bible_repository.dart';

class BibleApiAdapter implements BibleRepository {
  BibleApiAdapter({required this.httpClient});

  final PregareHttpClient httpClient;

  @override
  Future<List<BibleVersion>> getVersions() async {
    final data = await httpClient.get('/bible/versions', parser: (json) => json);
    return (data as List).map((v) => BibleVersion.fromJson(v)).toList();
  }

  @override
  Future<List<Book>> getBooks(String version) async {
    final data = await httpClient.get(
      '/bible/books',
      parser: (json) => json,
      queryParameters: {'version': version},
    );
    return (data as List).map((b) => Book.fromJson(b)).toList();
  }

  @override
  Future<Chapter> getChapter(String book, int chapter, String version) async {
    final data = await httpClient.get(
      '/bible/read/$book/$chapter',
      parser: (json) => json,
      queryParameters: {'version': version},
    );
    return Chapter.fromJson(data);
  }

  @override
  Future<List<BibleHighlight>> getHighlights() async {
    try {
      final data = await httpClient.get('/bible/highlights', parser: (json) => json);
      if (data is List) {
        return data.map((h) => BibleHighlight.fromJson(h as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> toggleHighlight({
    required String bookId,
    required int chapter,
    required int verseNumber,
    required String verseText,
    String? version,
    String? colorHex,
  }) async {
    try {
      final payload = <String, dynamic>{
        'bookId': bookId,
        'chapter': chapter,
        'verseNumber': verseNumber,
        'verseText': verseText,
        'version': version ?? 'RVR1960',
      };
      if (colorHex != null) {
        payload['colorHex'] = colorHex;
      }
      final res = await httpClient.post(
        '/bible/highlights/toggle',
        data: payload,
        parser: (json) => json,
      );
      if (res is Map && res['highlighted'] != null) {
        return res['highlighted'] as bool;
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
