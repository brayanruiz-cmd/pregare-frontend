import '../models/daily_verse.dart';

abstract class HomeRepository {
  Future<HomeData> getHomeData();
  Future<void> toggleFavorite({required String verseReference});
}
