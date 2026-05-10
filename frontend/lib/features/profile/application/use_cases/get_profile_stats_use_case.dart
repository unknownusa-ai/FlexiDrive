import '../../domain/entities/profile_stats.dart';
import '../../domain/ports/profile_repository_port.dart';

/// Caso de uso para obtener las estadísticas del perfil
class GetProfileStatsUseCase {
  GetProfileStatsUseCase(this._repository);

  final ProfileRepositoryPort _repository;

  /// Obtiene las estadísticas del perfil
  Future<ProfileStats> execute(int userId) async {
    return _repository.getProfileStats(userId);
  }
}
