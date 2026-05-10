import '../../domain/entities/auth_session.dart';
import '../../domain/ports/auth_repository_port.dart';

/// Caso de uso para iniciar sesión
class LoginUseCase {
  LoginUseCase(this._repository);

  final AuthRepositoryPort _repository;

  /// Ejecuta el login con email y contraseña
  Future<AuthSession?> execute({
    required String email,
    required String password,
  }) async {
    return _repository.login(
      email: email,
      password: password,
    );
  }
}
