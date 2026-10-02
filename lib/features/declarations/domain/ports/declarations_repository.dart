import '../models/declaration.dart';

abstract class DeclarationsRepository {
  Future<List<Declaration>> getDailyDeclarations({String? gender, List<String>? topics, int? count});
  Future<Map<String, String>> getTopics();
}
