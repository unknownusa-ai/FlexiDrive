import 'package:flexidrive/features/publications/domain/entities/publication_models.dart';

abstract class RepositorioPublicacionesPuerto {
  Future<void> inicializar();
  List<PublicationModel> obtenerPublicaciones();
  List<PublicationPriceModel> obtenerPreciosPublicacion();
  List<PublicationImageModel> obtenerImagenesPublicacion();
  Future<void> agregarPublicacion(PublicationModel publication);
  Future<void> agregarPrecioPublicacion(PublicationPriceModel publicationPrice);
}
