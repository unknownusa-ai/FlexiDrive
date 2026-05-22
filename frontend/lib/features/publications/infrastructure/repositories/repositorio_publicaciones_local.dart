import 'package:flexidrive/features/publications/domain/ports/repositorio_publicaciones_puerto.dart';
import 'package:flexidrive/features/publications/domain/entities/publication_models.dart';
import 'package:flexidrive/features/publications/infrastructure/datasources/local_publication_db.dart';

/// Define la responsabilidad de `RepositorioPublicacionesLocal` dentro de este módulo.
class RepositorioPublicacionesLocal implements RepositorioPublicacionesPuerto {
  RepositorioPublicacionesLocal({LocalPublicationDb? origen})
      : _origen = origen ?? LocalPublicationDb.instance;

  final LocalPublicationDb _origen;

  /// Gestiona inicializar dentro de esta parte del flujo.
  @override
  Future<void> inicializar() async {
    await _origen.loadIfNeeded();
  }

  /// Gestiona recargar dentro de esta parte del flujo.
  @override
  Future<void> recargar() async {
    await _origen.reload();
  }

  /// Obtiene la información asociada a obtener publicaciones.
  @override
  List<PublicationModel> obtenerPublicaciones() => _origen.publications;

  /// Obtiene la información asociada a obtener precios publicacion.
  @override
  List<PublicationPriceModel> obtenerPreciosPublicacion() {
    return _origen.publicationPrices;
  }

  /// Obtiene la información asociada a obtener imagenes publicacion.
  @override
  List<PublicationImageModel> obtenerImagenesPublicacion() {
    return _origen.publicationImages;
  }

  /// Agregar publicacion esta parte del flujo de trabajo.
  @override
  Future<PublicationModel> agregarPublicacion(PublicationModel publication) {
    return _origen.addPublication(publication);
  }

  @override
  Future<PublicationPriceModel> agregarPrecioPublicacion(
    PublicationPriceModel publicationPrice,
  ) {
    return _origen.addPublicationPrice(publicationPrice);
  }

  @override
  Future<PublicationImageModel> agregarImagenPublicacion(
    PublicationImageModel publicationImage,
  ) {
    return _origen.addPublicationImage(publicationImage);
  }

  LocalPublicationDb get origen => _origen;
}
