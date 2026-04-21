import '../../../shared/utils/json_utils.dart';
import '../../domain/entities/review_entities.dart';

class OpinionModel extends Opinion {
  const OpinionModel({
    required super.id,
    required super.rating,
    super.description,
  });

  factory OpinionModel.fromJson(Map<String, dynamic> json) {
    return OpinionModel(
      id: JsonUtils.asInt(json['opinion_id']),
      rating: JsonUtils.asInt(json['calificacion']),
      description: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'opinion_id': id,
    'calificacion': rating,
    'descripcion': description,
  };
}

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.publicationId,
    required super.opinionId,
    required super.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: JsonUtils.asInt(json['resena_id']),
      userId: JsonUtils.asInt(json['usuario_id']),
      publicationId: JsonUtils.asInt(json['publicacion_id']),
      opinionId: JsonUtils.asInt(json['opinion_id']),
      date: JsonUtils.asDateTime(json['fecha']),
    );
  }

  Map<String, dynamic> toJson() => {
    'resena_id': id,
    'usuario_id': userId,
    'publicacion_id': publicationId,
    'opinion_id': opinionId,
    'fecha': date.toIso8601String(),
  };
}
