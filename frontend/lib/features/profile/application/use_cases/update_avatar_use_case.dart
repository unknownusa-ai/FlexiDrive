import '../../domain/ports/profile_repository_port.dart';

/// Caso de uso para actualizar el avatar del usuario
class UpdateAvatarUseCase {
  /// Crea una instancia y prepara el estado inicial de `UpdateAvatarUseCase`.
  UpdateAvatarUseCase(this._repository);

  final ProfileRepositoryPort _repository;

  /// Actualiza el avatar del usuario
  Future<String?> execute(int userId, String imagePath) async {
    return _repository.updateAvatar(userId, imagePath);
  }
}
