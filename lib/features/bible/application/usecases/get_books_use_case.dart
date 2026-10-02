import '../../domain/models/book.dart';
import '../../domain/ports/bible_repository.dart';

class GetBooksUseCase {
  GetBooksUseCase({required this.repository});

  final BibleRepository repository;

  Future<List<Book>> execute(String version) async {
    return repository.getBooks(version);
  }
}
