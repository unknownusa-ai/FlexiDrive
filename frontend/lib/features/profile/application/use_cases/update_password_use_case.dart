import '../../domain/ports/profile_repository_port.dart';

/// Caso de uso para actualizar la contraseña
class UpdatePasswordUseCase {
  UpdatePasswordUseCase(this._repository);

  final ProfileRepositoryPort _repository;

  /// Actualiza la contraseña del usuario
  Future<void> execute({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    return _repository.updatePassword(userId, currentPassword, newPassword);
  }
}
