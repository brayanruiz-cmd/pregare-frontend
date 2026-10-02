import '../models/devotional.dart';

abstract class DevotionalsRepository {
  Future<Devotional> getDaily();
  Future<List<Devotional>> getAll();
  Future<Devotional> getById(int id);
}
