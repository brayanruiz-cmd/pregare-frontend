import '../models/streak.dart';
import '../models/streak_activity.dart';
import '../models/user_badge_model.dart';

abstract class StreaksRepository {
  Future<Streak> getStreak();
  Future<Streak> checkIn();
  Future<MonthActivity> getMonthActivity({int? year, int? month});
  Future<List<UserBadgeModel>> getBadges();
  Future<bool> completeDevotional(String devotionalId);
  Future<bool> proclaimDeclaration(String declarationId);
  Future<List<String>> getProclaimedDeclarations();
}

