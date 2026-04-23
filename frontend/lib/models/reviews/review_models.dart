import 'package:flexidrive/utils/json_utils.dart';

class OpinionModel {
  const OpinionModel({
    required this.id,
    required this.rating,
    this.description,
  });

  final int id;
  final int rating;
  final String? description;

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

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.userId,
    required this.publicationId,
    required this.opinionId,
    required this.date,
  });

  final int id;
  final int userId;
  final int publicationId;
  final int opinionId;
  final DateTime date;

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
