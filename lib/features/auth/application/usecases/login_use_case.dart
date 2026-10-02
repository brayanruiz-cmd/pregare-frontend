import '../../domain/models/auth_session.dart';
import '../../domain/ports/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> execute({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
