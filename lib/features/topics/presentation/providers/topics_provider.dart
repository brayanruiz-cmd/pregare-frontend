import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/state/async_state.dart';
import '../../domain/models/topic.dart';
import '../../domain/ports/topics_repository.dart';

class TopicsProvider extends ChangeNotifier {
  TopicsProvider({required TopicsRepository repository})
      // ignore: prefer_initializing_formals
      : _repository = repository;

  final TopicsRepository _repository;

  AsyncState<List<Topic>> _topics = const AsyncInitial();
  AsyncState<List<Topic>> get topics => _topics;

  AsyncState<Topic> _selectedTopic = const AsyncInitial();
  AsyncState<Topic> get selectedTopic => _selectedTopic;

  List<Topic> get currentTopics {
    if (_topics is AsyncData) {
      return (_topics as AsyncData).data;
    }
    return [];
  }

  Future<void> loadTopics() async {
    _topics = const AsyncLoading();
    notifyListeners();

    try {
      final result = await _repository.getAll();
      _topics = AsyncData(result);
    } catch (e) {
      _topics = AsyncError(e.toString());
    }
    notifyListeners();
  }

  Future<void> loadTopic(int id) async {
    _selectedTopic = const AsyncLoading();
    notifyListeners();

    try {
      final result = await _repository.getById(id);
      _selectedTopic = AsyncData(result);
    } catch (e) {
      _selectedTopic = AsyncError(e.toString());
    }
    notifyListeners();
  }

  Future<void> openYouTube(String query) async {
    final url = Uri.parse('https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
