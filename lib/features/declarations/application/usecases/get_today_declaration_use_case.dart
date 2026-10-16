import '../../domain/models/declaration.dart';
import '../../domain/ports/declarations_repository.dart';

class GetTodayDeclarationUseCase {
  GetTodayDeclarationUseCase({required this.repository});

  final DeclarationsRepository repository;

  Future<Declaration> execute({String? gender, int? day}) async {
    return repository.getTodayDeclaration(gender: gender, day: day);
  }
}
