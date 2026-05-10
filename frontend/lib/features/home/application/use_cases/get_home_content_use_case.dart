import '../../domain/entities/home_content.dart';
import '../../domain/ports/home_repository_port.dart';

/// Caso de uso para obtener el contenido de la página home
class GetHomeContentUseCase {
  GetHomeContentUseCase(this._repository);

  final HomeRepositoryPort _repository;

  /// Obtiene el contenido completo de la página home
  Future<HomeContent> execute() async {
    return _repository.getHomeContent();
  }
}
