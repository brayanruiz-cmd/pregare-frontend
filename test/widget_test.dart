import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pregare_app/features/bible/presentation/providers/bible_provider.dart';
import 'package:pregare_app/features/bible/presentation/screens/bible_screen.dart';
import 'package:pregare_app/features/bible/domain/ports/bible_repository.dart';
import 'package:pregare_app/features/bible/domain/models/bible_highlight.dart';
import 'package:pregare_app/features/bible/domain/models/bible_version.dart';
import 'package:pregare_app/features/bible/domain/models/book.dart';
import 'package:pregare_app/features/bible/domain/models/chapter.dart';
import 'package:pregare_app/core/theme/app_theme.dart';

void main() {
  testWidgets('BibleScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: ChangeNotifierProvider(
          create: (_) => BibleProvider(repository: _MockBibleRepository()),
          child: const BibleScreen(),
        ),
      ),
    );
    expect(find.text('Bible'), findsOneWidget);
  });
}

class _MockBibleRepository implements BibleRepository {
  @override
  Future<List<BibleVersion>> getVersions() async => [];

  @override
  Future<List<Book>> getBooks(String version) async => [];

  @override
  Future<Chapter> getChapter(String book, int chapter, String version) async =>
      Chapter(book: book, chapter: chapter, verses: []);

  @override
  Future<List<BibleHighlight>> getHighlights() async => [];

  @override
  Future<bool> toggleHighlight({
    required String bookId,
    required int chapter,
    required int verseNumber,
    required String verseText,
    String? version,
    String? colorHex,
  }) async =>
      false;
}
