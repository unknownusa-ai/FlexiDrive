import 'package:flexidrive/features/publications/domain/entities/publication_models.dart';

abstract class RepositorioPublicacionesPuerto {
  Future<void> inicializar();
  Future<void> recargar();
  List<PublicationModel> obtenerPublicaciones();
  List<PublicationPriceModel> obtenerPreciosPublicacion();
  List<PublicationImageModel> obtenerImagenesPublicacion();
  Future<PublicationModel> agregarPublicacion(PublicationModel publication);
  Future<PublicationPriceModel> agregarPrecioPublicacion(
    PublicationPriceModel publicationPrice,
  );
  Future<PublicationImageModel> agregarImagenPublicacion(
    PublicationImageModel publicationImage,
  );
}
