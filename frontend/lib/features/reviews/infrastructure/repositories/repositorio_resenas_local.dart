import 'package:flexidrive/features/reviews/domain/ports/repositorio_resenas_puerto.dart';
import 'package:flexidrive/features/reviews/domain/entities/review_models.dart';
import 'package:flexidrive/features/reviews/infrastructure/datasources/local_review_db.dart';

class RepositorioResenasLocal implements RepositorioResenasPuerto {
  RepositorioResenasLocal({LocalReviewDb? origen})
      : _origen = origen ?? LocalReviewDb.instance;

  final LocalReviewDb _origen;

  @override
  Future<void> inicializar() async {
    await _origen.loadIfNeeded();
  }

  @override
  List<OpinionModel> obtenerOpiniones() => _origen.opinions;

  @override
  List<ReviewModel> obtenerResenas() => _origen.reviews;

  LocalReviewDb get origen => _origen;
}
