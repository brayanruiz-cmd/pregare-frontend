import '../../../../core/infrastructure/http/http_client.dart';
import '../../../topics/domain/models/topic.dart';
import '../../../devotionals/domain/models/devotional.dart';
import '../../../onboarding/domain/models/focus_area.dart';
import '../../domain/ports/admin_repository.dart';

class AdminApiAdapter implements AdminRepository {
  AdminApiAdapter({required this.httpClient});

  final PregareHttpClient httpClient;

  @override
  Future<Map<String, dynamic>> getStats() async {
    final data = await httpClient.get('/admin/stats', parser: (json) => json);
    return Map<String, dynamic>.from(data);
  }

  @override
  Future<List<Topic>> getTopics() async {
    final data = await httpClient.get('/admin/topics', parser: (json) => json);
    return (data as List).map((t) => Topic.fromJson(t)).toList();
  }

  @override
  Future<Topic> createTopic(Map<String, dynamic> data) async {
    final res = await httpClient.post('/admin/topics', data: data);
    return Topic.fromJson(res);
  }

  @override
  Future<Topic> updateTopic(String id, Map<String, dynamic> data) async {
    final res = await httpClient.put('/admin/topics/$id', data: data);
    return Topic.fromJson(res);
  }

  @override
  Future<void> deleteTopic(String id) async {
    await httpClient.delete('/admin/topics/$id');
  }

  @override
  Future<List<Devotional>> getDevotionals() async {
    final data = await httpClient.get('/admin/devotionals', parser: (json) => json);
    return (data as List).map((d) => Devotional.fromJson(d)).toList();
  }

  @override
  Future<Devotional> createDevotional(Map<String, dynamic> data) async {
    final res = await httpClient.post('/admin/devotionals', data: data);
    return Devotional.fromJson(res);
  }

  @override
  Future<Devotional> updateDevotional(String id, Map<String, dynamic> data) async {
    final res = await httpClient.put('/admin/devotionals/$id', data: data);
    return Devotional.fromJson(res);
  }

  @override
  Future<void> deleteDevotional(String id) async {
    await httpClient.delete('/admin/devotionals/$id');
  }

  @override
  Future<List<FocusArea>> getFocusAreas() async {
    final data = await httpClient.get('/admin/focus-areas', parser: (json) => json);
    return (data as List).map((f) => FocusArea.fromJson(f)).toList();
  }

  @override
  Future<FocusArea> createFocusArea(Map<String, dynamic> data) async {
    final res = await httpClient.post('/admin/focus-areas', data: data);
    return FocusArea.fromJson(res);
  }

  @override
  Future<FocusArea> updateFocusArea(int id, Map<String, dynamic> data) async {
    final res = await httpClient.put('/admin/focus-areas/$id', data: data);
    return FocusArea.fromJson(res);
  }

  @override
  Future<void> deleteFocusArea(int id) async {
    await httpClient.delete('/admin/focus-areas/$id');
  }
}
