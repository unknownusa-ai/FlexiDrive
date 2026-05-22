import 'package:flutter/foundation.dart';
import 'package:flexidrive/features/reviews/domain/entities/review_models.dart';
import 'package:flexidrive/features/reviews/domain/ports/repositorio_resenas_puerto.dart';

/// Define la responsabilidad de `ReviewAccessUseCase` dentro de este módulo.
class ReviewAccessUseCase {
  /// Crea una instancia y prepara el estado inicial de `ReviewAccessUseCase`.
  ReviewAccessUseCase(this._repository);

  final RepositorioResenasPuerto _repository;

  /// Carga los datos necesarios para cargar if needed.
  Future<void> loadIfNeeded() => _repository.inicializar();

  List<OpinionModel> get opinions => _repository.obtenerOpiniones();

  List<ReviewModel> get reviews => _repository.obtenerResenas();

  ValueListenable<int> get changes => _repository.obtenerCambios();

  Future<ReviewModel> addOrUpdateReview({
    required int userId,
    required int publicationId,
    required int rating,
    String? description,
    int? reviewId,
  }) {
    return _repository.agregarOActualizarResena(
      userId: userId,
      publicationId: publicationId,
      rating: rating,
      description: description,
      reviewId: reviewId,
    );
  }

  /// Elimina los datos vinculados a eliminar reseña.
  Future<void> deleteReview(int reviewId) {
    return _repository.eliminarResena(reviewId);
  }
}
