import '../../../../core/infrastructure/http/http_client.dart';
import '../../../../core/infrastructure/offline/offline_manager.dart';
import '../../../../core/infrastructure/errors/app_exception.dart';
import '../../domain/models/daily_verse.dart';
import '../../domain/ports/home_repository.dart';

class HomeApiAdapter implements HomeRepository {
  HomeApiAdapter({required this.httpClient, OfflineManager? offlineManager})
      : _offlineManager = offlineManager ?? OfflineManager.instance;

  final PregareHttpClient httpClient;
  final OfflineManager _offlineManager;

  @override
  Future<HomeData> getHomeData() async {
    try {
      final data = await httpClient.get(
        '/home/daily-verse',
        parser: (json) => json,
      );
      if (data is Map) {
        await _offlineManager.save('home_daily_verse', data);
        return HomeData.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {
      // Network failed or server is down: try offline cache
    }

    final cached = _offlineManager.get('home_daily_verse');
    if (cached is Map) {
      try {
        return HomeData.fromJson(Map<String, dynamic>.from(cached));
      } catch (_) {}
    }

    // No mock data: if no cache and no network, rethrow so UI handles it gracefully
    throw const NetworkException('No connection to server and no cached home data available');
  }

  @override
  Future<void> toggleFavorite({required String verseReference}) async {
    try {
      await httpClient.post('/home/favorite', data: {'reference': verseReference});
    } catch (_) {
      // Soft failure when offline - can be synced later
    }
  }
}
