import '../../../../core/infrastructure/http/http_client.dart';
import '../../domain/models/daily_verse.dart';
import '../../domain/ports/home_repository.dart';

class HomeApiAdapter implements HomeRepository {
  HomeApiAdapter({required this.httpClient});

  final PregareHttpClient httpClient;

  @override
  Future<HomeData> getHomeData() async {
    final data = await httpClient.get(
      '/home/daily-verse',
      parser: (json) => json,
    );
    return HomeData.fromJson(data);
  }

  @override
  Future<void> toggleFavorite({required String verseReference}) async {
    await httpClient.post('/home/favorite', data: {'reference': verseReference});
  }
}
