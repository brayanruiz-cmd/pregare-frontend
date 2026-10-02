import '../../domain/models/auth_session.dart';
import '../../domain/ports/auth_repository.dart';

class GoogleAuthUseCase {
  GoogleAuthUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> execute({required String idToken}) {
    return _repository.googleAuth(idToken: idToken);
  }
}
