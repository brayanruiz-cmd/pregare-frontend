import '../../../../core/infrastructure/http/http_client.dart';
import '../../../../core/infrastructure/offline/offline_manager.dart';
import '../../../../core/infrastructure/errors/app_exception.dart';
import '../../domain/models/bible_highlight.dart';
import '../../domain/models/bible_version.dart';
import '../../domain/models/book.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/verse_collection.dart';
import '../../domain/ports/bible_repository.dart';

class BibleApiAdapter implements BibleRepository {
  BibleApiAdapter({required this.httpClient, OfflineManager? offlineManager})
      : _offlineManager = offlineManager ?? OfflineManager.instance;

  final PregareHttpClient httpClient;
  final OfflineManager _offlineManager;

  @override
  Future<List<BibleVersion>> getVersions() async {
    const cacheKey = 'bible_versions';
    try {
      final data = await httpClient.get('/bible/versions', parser: (json) => json);
      if (data is List && data.isNotEmpty) {
        await _offlineManager.save(cacheKey, data);
        return data.map((v) => BibleVersion.fromJson(v as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Offline fallback
    }

    final cached = _offlineManager.get(cacheKey);
    if (cached is List && cached.isNotEmpty) {
      try {
        return cached.map((v) => BibleVersion.fromJson(v as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    throw const NetworkException('No connection to server and no cached versions available');
  }

  @override
  Future<List<Book>> getBooks(String version) async {
    final cacheKey = 'bible_books_$version';
    try {
      final data = await httpClient.get(
        '/bible/books',
        parser: (json) => json,
        queryParameters: {'version': version},
      );
      if (data is List && data.isNotEmpty) {
        await _offlineManager.save(cacheKey, data);
        return data.map((b) => Book.fromJson(b as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Offline fallback
    }

    final cached = _offlineManager.get(cacheKey);
    if (cached is List && cached.isNotEmpty) {
      try {
        return cached.map((b) => Book.fromJson(b as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    throw const NetworkException('No connection to server and no cached books available');
  }

  @override
  Future<Chapter> getChapter(String book, int chapter, String version) async {
    final cacheKey = 'bible_ch_${version}_${book.toLowerCase()}_$chapter';

    try {
      final data = await httpClient.get(
        '/bible/read/$book/$chapter',
        parser: (json) => json,
        queryParameters: {'version': version},
      );
      if (data is Map) {
        await _offlineManager.save(cacheKey, data);
        return Chapter.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      // Network failed or offline: check local cache
    }

    final cached = _offlineManager.get(cacheKey);
    if (cached is Map) {
      try {
        return Chapter.fromJson(Map<String, dynamic>.from(cached));
      } catch (_) {}
    }

    throw Exception('Capítulo no disponible sin conexión. Conéctate a internet para cargarlo por primera vez.');
  }

  @override
  Future<List<BibleHighlight>> getHighlights() async {
    const cacheKey = 'bible_highlights';
    try {
      final data = await httpClient.get('/bible/highlights', parser: (json) => json);
      if (data is List) {
        await _offlineManager.save(cacheKey, data);
        return data.map((h) => BibleHighlight.fromJson(h as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    final cached = _offlineManager.get(cacheKey);
    if (cached is List) {
      try {
        return cached.map((h) => BibleHighlight.fromJson(h as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    return [];
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
      // Return true when offline so local optimistic highlight is preserved
      return true;
    }
  }

  @override
  Future<List<VerseCollection>> getCollections() async {
    const cacheKey = 'bible_verse_collections';
    try {
      final data = await httpClient.get('/bible/collections', parser: (json) => json);
      if (data is List) {
        await _offlineManager.save(cacheKey, data);
        return data.map((c) => VerseCollection.fromJson(c as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    final cached = _offlineManager.get(cacheKey);
    if (cached is List) {
      try {
        return cached.map((c) => VerseCollection.fromJson(c as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    return [];
  }

  @override
  Future<VerseCollection> createCollection(String title, {String? colorHex, String? description}) async {
    final payload = <String, dynamic>{
      'title': title,
      if (colorHex != null) 'colorHex': colorHex,
      if (description != null) 'description': description,
    };
    final res = await httpClient.post(
      '/bible/collections',
      data: payload,
      parser: (json) => json,
    );
    return VerseCollection.fromJson(Map<String, dynamic>.from(res as Map));
  }

  @override
  Future<bool> deleteCollection(String id) async {
    try {
      await httpClient.delete('/bible/collections/$id');
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<String>> getVerseCollectionIds({
    required String bookId,
    required int chapter,
    required int verseNumber,
  }) async {
    try {
      final data = await httpClient.get(
        '/bible/collections/verse-status',
        queryParameters: {
          'bookId': bookId,
          'chapter': chapter.toString(),
          'verseNumber': verseNumber.toString(),
        },
        parser: (json) => json,
      );
      if (data is List) {
        return data.map((id) => id.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<bool> toggleVerseInCollection({
    required String collectionId,
    required String bookId,
    String? bookName,
    required int chapter,
    required int verseNumber,
    required String verseText,
    String? colorHex,
    String? version,
  }) async {
    final payload = <String, dynamic>{
      'bookId': bookId,
      'bookName': bookName ?? bookId,
      'chapter': chapter,
      'verseNumber': verseNumber,
      'verseText': verseText,
      'version': version ?? 'RVR1960',
      'colorHex': colorHex ?? '#F7EBD2',
    };
    try {
      final res = await httpClient.post(
        '/bible/collections/$collectionId/toggle-verse',
        data: payload,
        parser: (json) => json,
      );
      if (res is Map && res['inCollection'] != null) {
        return res['inCollection'] as bool;
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<VerseCollection?> getCollectionDetails(String id) async {
    try {
      final res = await httpClient.get('/bible/collections/$id', parser: (json) => json);
      if (res is Map) {
        return VerseCollection.fromJson(Map<String, dynamic>.from(res));
      }
    } catch (_) {}
    return null;
  }
}
