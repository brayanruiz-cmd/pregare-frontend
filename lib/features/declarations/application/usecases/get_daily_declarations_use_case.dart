import '../../domain/models/declaration.dart';
import '../../domain/ports/declarations_repository.dart';

class GetDailyDeclarationsUseCase {
  GetDailyDeclarationsUseCase({required this.repository});

  final DeclarationsRepository repository;

  Future<List<Declaration>> execute({String? gender, List<String>? topics, int? count}) async {
    return repository.getDailyDeclarations(gender: gender, topics: topics, count: count);
  }
}
