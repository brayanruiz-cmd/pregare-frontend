import '../../domain/models/daily_verse.dart';
import '../../domain/ports/home_repository.dart';

class GetDailyVerseUseCase {
  GetDailyVerseUseCase(this._repository);

  final HomeRepository _repository;

  Future<HomeData> execute() {
    return _repository.getHomeData();
  }
}
