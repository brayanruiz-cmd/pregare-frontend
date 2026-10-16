import '../models/declaration.dart';

abstract class DeclarationsRepository {
  Future<List<Declaration>> getDailyDeclarations({String? gender, List<String>? topics, int? count});
  Future<Declaration> getTodayDeclaration({String? gender, int? day});
  Future<Map<String, String>> getTopics();
}
