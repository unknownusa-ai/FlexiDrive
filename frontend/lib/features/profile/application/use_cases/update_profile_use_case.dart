import '../../domain/entities/user_profile.dart';
import '../../domain/ports/profile_repository_port.dart';

/// Caso de uso para actualizar el perfil
class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repository);

  final ProfileRepositoryPort _repository;

  /// Actualiza el perfil del usuario
  Future<UserProfile> execute(UserProfile profile) async {
    return _repository.updateProfile(profile);
  }
}
