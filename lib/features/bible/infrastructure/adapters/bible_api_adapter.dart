import '../../../../core/infrastructure/http/http_client.dart';
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
}
