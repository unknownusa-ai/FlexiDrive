import 'package:flutter/foundation.dart';
import 'package:flexidrive/features/reviews/domain/entities/review_models.dart';

/// Define la responsabilidad de `RepositorioResenasPuerto` dentro de este módulo.
abstract class RepositorioResenasPuerto {
  Future<void> inicializar();
  List<OpinionModel> obtenerOpiniones();
  List<ReviewModel> obtenerResenas();
  ValueListenable<int> obtenerCambios();
  Future<ReviewModel> agregarOActualizarResena({
    required int userId,
    required int publicationId,
    required int rating,
    String? description,
    int? reviewId,
  });
  Future<void> eliminarResena(int reviewId);
}
