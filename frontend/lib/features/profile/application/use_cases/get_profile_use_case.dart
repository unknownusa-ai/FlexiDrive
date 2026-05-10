import '../../domain/entities/user_profile.dart';
import '../../domain/ports/profile_repository_port.dart';

/// Caso de uso para obtener el perfil del usuario actual
class GetProfileUseCase {
  GetProfileUseCase(this._repository);

  final ProfileRepositoryPort _repository;

  /// Obtiene el perfil del usuario actual
  Future<UserProfile?> execute() async {
    return _repository.getCurrentProfile();
  }

  /// Obtiene el perfil por ID específico
  Future<UserProfile?> byId(int userId) async {
    return _repository.getProfileById(userId);
  }
}
