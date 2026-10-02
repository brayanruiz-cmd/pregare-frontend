import '../models/topic.dart';

abstract class TopicsRepository {
  Future<List<Topic>> getAll();
  Future<Topic> getById(int id);
}
