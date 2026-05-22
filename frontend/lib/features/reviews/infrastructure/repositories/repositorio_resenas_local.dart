import 'package:flutter/foundation.dart';
import 'package:flexidrive/features/reviews/domain/ports/repositorio_resenas_puerto.dart';
import 'package:flexidrive/features/reviews/domain/entities/review_models.dart';
import 'package:flexidrive/features/reviews/infrastructure/datasources/local_review_db.dart';

/// Define la responsabilidad de `RepositorioResenasLocal` dentro de este módulo.
class RepositorioResenasLocal implements RepositorioResenasPuerto {
  RepositorioResenasLocal({LocalReviewDb? origen})
      : _origen = origen ?? LocalReviewDb.instance;

  final LocalReviewDb _origen;

  /// Gestiona inicializar dentro de esta parte del flujo.
  @override
  Future<void> inicializar() async {
    await _origen.loadIfNeeded();
  }

  /// Obtiene la información asociada a obtener opiniones.
  @override
  List<OpinionModel> obtenerOpiniones() => _origen.opinions;

  /// Obtiene la información asociada a obtener resenas.
  @override
  List<ReviewModel> obtenerResenas() => _origen.reviews;

  /// Obtiene la información asociada a obtener cambios.
  @override
  ValueListenable<int> obtenerCambios() => _origen.changes;

  @override
  Future<ReviewModel> agregarOActualizarResena({
    required int userId,
    required int publicationId,
    required int rating,
    String? description,
    int? reviewId,
  }) {
    return _origen.addOrUpdateReview(
      userId: userId,
      publicationId: publicationId,
      rating: rating,
      description: description,
      reviewId: reviewId,
    );
  }

  /// Elimina los datos vinculados a eliminar resena.
  @override
  Future<void> eliminarResena(int reviewId) {
    return _origen.deleteReview(reviewId);
  }

  LocalReviewDb get origen => _origen;
}
