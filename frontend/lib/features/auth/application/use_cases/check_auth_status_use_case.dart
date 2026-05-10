import '../../domain/ports/auth_repository_port.dart';

/// Caso de uso para verificar si el usuario está autenticado
class CheckAuthStatusUseCase {
  CheckAuthStatusUseCase(this._repository);

  final AuthRepositoryPort _repository;

  /// Verifica si hay una sesión activa válida
  Future<bool> execute() async {
    return _repository.isAuthenticated();
  }
}
