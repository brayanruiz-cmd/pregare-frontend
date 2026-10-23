import '../../../../core/infrastructure/http/http_client.dart';
import '../../domain/models/streak.dart';
import '../../domain/models/streak_activity.dart';
import '../../domain/ports/streaks_repository.dart';

import '../../domain/models/user_badge_model.dart';

class StreaksApiAdapter implements StreaksRepository {
  StreaksApiAdapter({required this.httpClient});

  final PregareHttpClient httpClient;

  @override
  Future<Streak> getStreak() async {
    final data = await httpClient.get('/streaks/me', parser: (json) => json);
    return Streak.fromJson(data);
  }

  @override
  Future<Streak> checkIn() async {
    final data = await httpClient.post('/streaks/checkin', data: {});
    return Streak.fromJson(data);
  }

  @override
  Future<MonthActivity> getMonthActivity({int? year, int? month}) async {
    final queryParams = <String, dynamic>{};
    if (year != null) queryParams['year'] = year.toString();
    if (month != null) queryParams['month'] = month.toString();

    final data = await httpClient.get(
      '/streaks/activity',
      queryParameters: queryParams,
      parser: (json) => json,
    );
    return MonthActivity.fromJson(data);
  }

  @override
  Future<List<UserBadgeModel>> getBadges() async {
    final data = await httpClient.get('/streaks/badges', parser: (json) => json);
    if (data is List) {
      return data
          .map((b) => UserBadgeModel.fromJson(b as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<bool> completeDevotional(String devotionalId) async {
    final res = await httpClient.post('/streaks/devotionals/$devotionalId/complete', data: {});
    return res != null;
  }

  @override
  Future<bool> proclaimDeclaration(String declarationId, {String? gender}) async {
    final body = <String, dynamic>{};
    if (gender != null && gender.isNotEmpty) {
      body['gender'] = gender;
    }
    final res = await httpClient.post(
      '/streaks/declarations/$declarationId/proclaim',
      data: body,
    );
    return res != null;
  }

  @override
  Future<List<String>> getProclaimedDeclarations() async {
    try {
      final res = await httpClient.get('/streaks/declarations/proclaimed');
      if (res is List) {
        return res.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<List<String>> getTodayProclaimedGenders() async {
    try {
      final res = await httpClient.get('/streaks/declarations/today-genders');
      if (res is List) {
        return res.map((e) => e.toString().toLowerCase()).toList();
      }
    } catch (_) {}
    return [];
  }
}

