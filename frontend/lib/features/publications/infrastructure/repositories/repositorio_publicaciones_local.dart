import 'package:flexidrive/features/publications/domain/ports/repositorio_publicaciones_puerto.dart';
import 'package:flexidrive/features/publications/domain/entities/publication_models.dart';
import 'package:flexidrive/features/publications/infrastructure/datasources/local_publication_db.dart';

class RepositorioPublicacionesLocal implements RepositorioPublicacionesPuerto {
  RepositorioPublicacionesLocal({LocalPublicationDb? origen})
      : _origen = origen ?? LocalPublicationDb.instance;

  final LocalPublicationDb _origen;

  @override
  Future<void> inicializar() async {
    await _origen.loadIfNeeded();
  }

  @override
  Future<void> recargar() async {
    await _origen.reload();
  }

  @override
  List<PublicationModel> obtenerPublicaciones() => _origen.publications;

  @override
  List<PublicationPriceModel> obtenerPreciosPublicacion() {
    return _origen.publicationPrices;
  }

  @override
  List<PublicationImageModel> obtenerImagenesPublicacion() {
    return _origen.publicationImages;
  }

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
