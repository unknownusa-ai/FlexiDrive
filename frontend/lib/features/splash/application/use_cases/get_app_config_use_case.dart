import '../../domain/entities/app_config.dart';
import '../../domain/ports/config_repository_port.dart';

/// Caso de uso para obtener la configuración de la app
class GetAppConfigUseCase {
  GetAppConfigUseCase(this._repository);

  final ConfigRepositoryPort _repository;

  /// Obtiene la configuración actual de la aplicación
  Future<AppConfig> execute() async {
    return _repository.getAppConfig();
  }
}
