import 'package:flexidrive/features/publications/domain/entities/publication_models.dart';
import 'package:flexidrive/features/publications/domain/ports/repositorio_publicaciones_puerto.dart';

class PublicationAccessUseCase {
  PublicationAccessUseCase(this._repository);

  final RepositorioPublicacionesPuerto _repository;

  Future<void> loadIfNeeded() => _repository.inicializar();

  List<PublicationModel> get publications => _repository.obtenerPublicaciones();

  List<PublicationPriceModel> get publicationPrices {
    return _repository.obtenerPreciosPublicacion();
  }

  List<PublicationImageModel> get publicationImages {
    return _repository.obtenerImagenesPublicacion();
  }

  void addPublication(PublicationModel publication) {
    _repository.agregarPublicacion(publication);
  }

  void addPublicationPrice(PublicationPriceModel publicationPrice) {
    _repository.agregarPrecioPublicacion(publicationPrice);
  }
}
