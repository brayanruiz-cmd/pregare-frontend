import '../../../../core/infrastructure/http/http_client.dart';
import '../../domain/models/devotional.dart';
import '../../domain/ports/devotionals_repository.dart';

class DevotionalsApiAdapter implements DevotionalsRepository {
  DevotionalsApiAdapter({required this.httpClient});

  final PregareHttpClient httpClient;

  @override
  Future<Devotional> getDaily() async {
    final data = await httpClient.get('/devotionals/daily', parser: (json) => json);
    return Devotional.fromJson(data);
  }

  @override
  Future<List<Devotional>> getAll() async {
    final data = await httpClient.get('/devotionals', parser: (json) => json);
    return (data as List).map((d) => Devotional.fromJson(d)).toList();
  }

  @override
  Future<Devotional> getById(int id) async {
    final data = await httpClient.get('/devotionals/$id', parser: (json) => json);
    return Devotional.fromJson(data);
  }
}
