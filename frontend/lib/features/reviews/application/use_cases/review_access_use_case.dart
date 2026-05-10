import 'package:flexidrive/features/reviews/domain/entities/review_models.dart';
import 'package:flexidrive/features/reviews/domain/ports/repositorio_resenas_puerto.dart';

class ReviewAccessUseCase {
  ReviewAccessUseCase(this._repository);

  final RepositorioResenasPuerto _repository;

  Future<void> loadIfNeeded() => _repository.inicializar();

  List<OpinionModel> get opinions => _repository.obtenerOpiniones();

  List<ReviewModel> get reviews => _repository.obtenerResenas();
}
