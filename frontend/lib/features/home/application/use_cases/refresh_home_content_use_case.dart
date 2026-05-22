import '../../domain/entities/home_content.dart';
import '../../domain/ports/home_repository_port.dart';

/// Caso de uso para refrescar el contenido de home
class RefreshHomeContentUseCase {
  /// Crea una instancia y prepara el estado inicial de `RefreshHomeContentUseCase`.
  RefreshHomeContentUseCase(this._repository);

  final HomeRepositoryPort _repository;

  /// Fuerza la actualización del contenido desde el servidor
  Future<HomeContent> execute() async {
    return _repository.refreshContent();
  }
}
