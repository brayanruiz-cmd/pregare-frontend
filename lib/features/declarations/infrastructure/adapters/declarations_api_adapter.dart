import '../../../../core/infrastructure/http/http_client.dart';
import '../../domain/models/declaration.dart';
import '../../domain/ports/declarations_repository.dart';

class DeclarationsApiAdapter implements DeclarationsRepository {
  DeclarationsApiAdapter({required this.httpClient});

  final PregareHttpClient httpClient;

  @override
  Future<List<Declaration>> getDailyDeclarations({String? gender, List<String>? topics, int? count}) async {
    final queryParams = <String, String>{};
    if (gender != null) queryParams['gender'] = gender;
    if (topics != null && topics.isNotEmpty) queryParams['topics'] = topics.join(',');
    if (count != null) queryParams['count'] = count.toString();

    final data = await httpClient.get(
      '/declarations/daily',
      parser: (json) => json,
      queryParameters: queryParams,
    );
    return (data as List).map((d) => Declaration.fromJson(d)).toList();
  }

  @override
  Future<Declaration> getTodayDeclaration({String? gender, int? day}) async {
    final queryParams = <String, String>{};
    if (gender != null) queryParams['gender'] = gender;
    if (day != null) queryParams['day'] = day.toString();

    final data = await httpClient.get(
      '/declarations/today',
      parser: (json) => json,
      queryParameters: queryParams,
    );
    return Declaration.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, String>> getTopics() async {
    final data = await httpClient.get('/declarations/topics', parser: (json) => json);
    return Map<String, String>.from(data);
  }
}
