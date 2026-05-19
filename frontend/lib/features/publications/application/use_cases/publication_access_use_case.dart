import 'package:flexidrive/features/publications/domain/entities/publication_models.dart';
import 'package:flexidrive/features/publications/domain/ports/repositorio_publicaciones_puerto.dart';

class PublicationAccessUseCase {
  PublicationAccessUseCase(this._repository);

  final RepositorioPublicacionesPuerto _repository;

  Future<void> loadIfNeeded() => _repository.inicializar();
  Future<void> reload() => _repository.recargar();

  List<PublicationModel> get publications => _repository.obtenerPublicaciones();

  List<PublicationPriceModel> get publicationPrices {
    return _repository.obtenerPreciosPublicacion();
  }

  List<PublicationImageModel> get publicationImages {
    return _repository.obtenerImagenesPublicacion();
  }

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
