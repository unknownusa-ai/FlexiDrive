import '../../domain/ports/auth_repository_port.dart';

/// Caso de uso para cerrar sesión
class LogoutUseCase {
  LogoutUseCase(this._repository);

  final AuthRepositoryPort _repository;

  /// Ejecuta el logout y limpia la sesión
  Future<void> execute() async {
    await _repository.logout();
  }
}
