import '../../domain/ports/profile_repository_port.dart';

/// Caso de uso para cambiar el modo de usuario
class ToggleUserModeUseCase {
  /// Crea una instancia y prepara el estado inicial de `ToggleUserModeUseCase`.
  ToggleUserModeUseCase(this._repository);

  final ProfileRepositoryPort _repository;

  /// Cambia el modo del usuario entre arrendatario y arrendador
  Future<void> execute(int userId, bool canPublish) async {
    return _repository.toggleUserMode(userId, canPublish);
  }

  /// Verifica si el usuario puede publicar vehículos
  Future<bool> canPublish(int userId) async {
    return _repository.canUserPublish(userId);
  }
}
