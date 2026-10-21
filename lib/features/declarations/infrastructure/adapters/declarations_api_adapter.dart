import '../../../../core/infrastructure/http/http_client.dart';
import '../../../../core/infrastructure/offline/offline_manager.dart';
import '../../../../core/infrastructure/errors/app_exception.dart';
import '../../domain/models/declaration.dart';
import '../../domain/ports/declarations_repository.dart';

class DeclarationsApiAdapter implements DeclarationsRepository {
  DeclarationsApiAdapter({required this.httpClient, OfflineManager? offlineManager})
      : _offlineManager = offlineManager ?? OfflineManager.instance;

  final PregareHttpClient httpClient;
  final OfflineManager _offlineManager;

  @override
  Future<List<Declaration>> getDailyDeclarations({String? gender, List<String>? topics, int? count}) async {
    final queryParams = <String, String>{};
    if (gender != null) queryParams['gender'] = gender;
    if (topics != null && topics.isNotEmpty) queryParams['topics'] = topics.join(',');
    if (count != null) queryParams['count'] = count.toString();

    final cacheKey = 'declarations_daily_${gender ?? "all"}_${topics?.join("-") ?? "all"}';

    try {
      final data = await httpClient.get(
        '/declarations/daily',
        parser: (json) => json,
        queryParameters: queryParams,
      );
      if (data is List && data.isNotEmpty) {
        await _offlineManager.save(cacheKey, data);
        return data.map((d) => Declaration.fromJson(d as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Network failed: attempt offline cache
    }

    final cached = _offlineManager.get(cacheKey);
    if (cached is List && cached.isNotEmpty) {
      try {
        return cached.map((d) => Declaration.fromJson(d as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    throw const NetworkException('No connection to server and no cached declarations available');
  }

  @override
  Future<Declaration> getTodayDeclaration({String? gender, int? day}) async {
    final queryParams = <String, String>{};
    if (gender != null) queryParams['gender'] = gender;
    if (day != null) queryParams['day'] = day.toString();

    final cacheKey = 'declarations_today_${gender ?? "all"}_${day ?? "current"}';

    try {
      final data = await httpClient.get(
        '/declarations/today',
        parser: (json) => json,
        queryParameters: queryParams,
      );
      if (data is Map) {
        await _offlineManager.save(cacheKey, data);
        return Declaration.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {
      // Network failed
    }

    final cached = _offlineManager.get(cacheKey);
    if (cached is Map) {
      try {
        return Declaration.fromJson(Map<String, dynamic>.from(cached));
      } catch (_) {}
    }

    throw const NetworkException('No connection to server and no cached declaration available');
  }

  @override
  Future<Map<String, String>> getTopics() async {
    const cacheKey = 'declarations_topics';
    try {
      final data = await httpClient.get('/declarations/topics', parser: (json) => json);
      if (data is Map) {
        await _offlineManager.save(cacheKey, data);
        return Map<String, String>.from(data);
      }
    } catch (_) {}

    final cached = _offlineManager.get(cacheKey);
    if (cached is Map) {
      try {
        return Map<String, String>.from(cached);
      } catch (_) {}
    }

    throw const NetworkException('No connection to server and no cached topics available');
  }
}
