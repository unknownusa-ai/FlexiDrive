import '../../domain/entities/auth_session.dart';
import '../../domain/ports/auth_repository_port.dart';

/// Caso de uso para iniciar sesión
class LoginUseCase {
  /// Crea una instancia y prepara el estado inicial de `LoginUseCase`.
  LoginUseCase(this._repository);

  final AuthRepositoryPort _repository;

  /// Ejecuta el inicio de sesión con correo y contraseña
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
