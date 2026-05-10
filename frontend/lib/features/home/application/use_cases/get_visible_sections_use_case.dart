import '../../domain/entities/home_section.dart';
import '../../domain/ports/home_repository_port.dart';

/// Caso de uso para obtener las secciones visibles de home
class GetVisibleSectionsUseCase {
  GetVisibleSectionsUseCase(this._repository);

  final HomeRepositoryPort _repository;

  /// Obtiene las secciones visibles ordenadas
  Future<List<HomeSection>> execute() async {
    return _repository.getVisibleSections();
  }
}
