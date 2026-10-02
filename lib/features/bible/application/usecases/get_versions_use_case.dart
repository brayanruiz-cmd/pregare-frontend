import '../../domain/models/bible_version.dart';
import '../../domain/ports/bible_repository.dart';

class GetVersionsUseCase {
  GetVersionsUseCase({required this.repository});

  final BibleRepository repository;

  Future<List<BibleVersion>> execute() async {
    return repository.getVersions();
  }
}
