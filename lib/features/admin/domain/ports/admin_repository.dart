import '../../../topics/domain/models/topic.dart';
import '../../../devotionals/domain/models/devotional.dart';
import '../../../onboarding/domain/models/focus_area.dart';

abstract class AdminRepository {
  Future<Map<String, dynamic>> getStats();
  Future<List<Topic>> getTopics();
  Future<Topic> createTopic(Map<String, dynamic> data);
  Future<Topic> updateTopic(String id, Map<String, dynamic> data);
  Future<void> deleteTopic(String id);

  Future<List<Devotional>> getDevotionals();
  Future<Devotional> createDevotional(Map<String, dynamic> data);
  Future<Devotional> updateDevotional(String id, Map<String, dynamic> data);
  Future<void> deleteDevotional(String id);

  Future<List<FocusArea>> getFocusAreas();
  Future<FocusArea> createFocusArea(Map<String, dynamic> data);
  Future<FocusArea> updateFocusArea(int id, Map<String, dynamic> data);
  Future<void> deleteFocusArea(int id);
}
