import 'package:flexidrive/features/publications/domain/entities/publication_models.dart';

/// Define la responsabilidad de `RepositorioPublicacionesPuerto` dentro de este módulo.
abstract class RepositorioPublicacionesPuerto {
  Future<void> inicializar();
  Future<void> recargar();
  List<PublicationModel> obtenerPublicaciones();
  List<PublicationPriceModel> obtenerPreciosPublicacion();
  List<PublicationImageModel> obtenerImagenesPublicacion();
  Future<PublicationModel> agregarPublicacion(PublicationModel publication);
  Future<PublicationModel> actualizarPublicacion(PublicationModel publication);
  Future<void> eliminarPublicacion(int publicationId);
  Future<PublicationPriceModel> agregarPrecioPublicacion(
    PublicationPriceModel publicationPrice,
  );
  Future<PublicationPriceModel> actualizarPrecioPublicacion(
    PublicationPriceModel publicationPrice,
  );
  Future<PublicationImageModel> agregarImagenPublicacion(
    PublicationImageModel publicationImage,
  );
}
