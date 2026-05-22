import 'package:flexidrive/features/publications/domain/entities/publication_models.dart';
import 'package:flexidrive/features/publications/domain/ports/repositorio_publicaciones_puerto.dart';

/// Define la responsabilidad de `PublicationAccessUseCase` dentro de este módulo.
class PublicationAccessUseCase {
  /// Crea una instancia y prepara el estado inicial de `PublicationAccessUseCase`.
  PublicationAccessUseCase(this._repository);

  final RepositorioPublicacionesPuerto _repository;

  /// Carga los datos necesarios para cargar if needed.
  Future<void> loadIfNeeded() => _repository.inicializar();

  /// Gestiona recargar dentro de esta parte del flujo.
  Future<void> reload() => _repository.recargar();

  List<PublicationModel> get publications => _repository.obtenerPublicaciones();

  List<PublicationPriceModel> get publicationPrices {
    return _repository.obtenerPreciosPublicacion();
  }

  List<PublicationImageModel> get publicationImages {
    return _repository.obtenerImagenesPublicacion();
  }

  /// Agregar publicación esta parte del flujo de trabajo.
  Future<PublicationModel> addPublication(PublicationModel publication) {
    return _repository.agregarPublicacion(publication);
  }

  Future<PublicationPriceModel> addPublicationPrice(
    PublicationPriceModel publicationPrice,
  ) {
    return _repository.agregarPrecioPublicacion(publicationPrice);
  }

  Future<PublicationImageModel> addPublicationImage(
    PublicationImageModel publicationImage,
  ) {
    return _repository.agregarImagenPublicacion(publicationImage);
  }
}
