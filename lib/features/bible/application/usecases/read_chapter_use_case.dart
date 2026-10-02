import '../../domain/models/chapter.dart';
import '../../domain/ports/bible_repository.dart';

class ReadChapterUseCase {
  ReadChapterUseCase({required this.repository});

  final BibleRepository repository;

  Future<Chapter> execute(String book, int chapter, String version) async {
    return repository.getChapter(book, chapter, version);
  }
}
