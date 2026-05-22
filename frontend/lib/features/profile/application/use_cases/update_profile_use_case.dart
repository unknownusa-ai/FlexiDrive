import '../../domain/entities/user_profile.dart';
import '../../domain/ports/profile_repository_port.dart';

/// Caso de uso para actualizar el perfil
class UpdateProfileUseCase {
  /// Crea una instancia y prepara el estado inicial de `UpdateProfileUseCase`.
  UpdateProfileUseCase(this._repository);

  final ProfileRepositoryPort _repository;

  /// Actualiza el perfil del usuario
  Future<UserProfile> execute(UserProfile profile) async {
    return _repository.updateProfile(profile);
  }
}
