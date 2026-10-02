import '../../../../core/infrastructure/http/http_client.dart';
import '../../domain/models/topic.dart';
import '../../domain/ports/topics_repository.dart';

class TopicsApiAdapter implements TopicsRepository {
  TopicsApiAdapter({required this.httpClient});

  final PregareHttpClient httpClient;

  @override
  Future<List<Topic>> getAll() async {
    final data = await httpClient.get('/topics', parser: (json) => json);
    return (data as List).map((t) => Topic.fromJson(t)).toList();
  }

  @override
  Future<Topic> getById(int id) async {
    final data = await httpClient.get('/topics/$id', parser: (json) => json);
    return Topic.fromJson(data);
  }
}
