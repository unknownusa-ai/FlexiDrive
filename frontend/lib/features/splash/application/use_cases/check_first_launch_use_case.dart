import '../../domain/ports/config_repository_port.dart';

/// Caso de uso para verificar si es el primer lanzamiento
class CheckFirstLaunchUseCase {
  /// Crea una instancia y prepara el estado inicial de `CheckFirstLaunchUseCase`.
  CheckFirstLaunchUseCase(this._repository);

  final ConfigRepositoryPort _repository;

  /// Verifica si es el primer lanzamiento de la app
  Future<bool> execute() async {
    return _repository.isFirstLaunch();
  }
}
