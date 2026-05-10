import 'package:flexidrive/features/reviews/domain/entities/review_models.dart';

abstract class RepositorioResenasPuerto {
  Future<void> inicializar();
  List<OpinionModel> obtenerOpiniones();
  List<ReviewModel> obtenerResenas();
}
