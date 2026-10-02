import '../../domain/models/auth_session.dart';
import '../../domain/ports/auth_repository.dart';

class RefreshTokenUseCase {
  RefreshTokenUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> execute({required String refreshToken}) {
    return _repository.refreshToken(refreshToken: refreshToken);
  }
}
