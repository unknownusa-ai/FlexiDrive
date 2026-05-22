import '../../domain/entities/auth_session.dart';
import '../../domain/ports/auth_repository_port.dart';

/// Caso de uso para obtener la sesión actual
class GetCurrentSessionUseCase {
  /// Crea una instancia y prepara el estado inicial de `GetCurrentSessionUseCase`.
  GetCurrentSessionUseCase(this._repository);

  final AuthRepositoryPort _repository;

  /// Obtiene la sesión actual del usuario
  Future<AuthSession?> execute() async {
    return _repository.getCurrentSession();
  }
}
