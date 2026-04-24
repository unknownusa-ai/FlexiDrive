// Utilidades para convertir JSON
import 'package:flexidrive/utils/json_utils.dart';

// Modelo de una opinion/calificacion
// Guarda la calificacion y comentario de una reseña
class OpinionModel {
  // Constructor con datos de la opinion
  const OpinionModel({
    required this.id, // ID unico de la opinion
    required this.rating, // Calificacion de 1 a 5 estrellas
    this.description, // Comentario opcional
  });

  // ID de la opinion
  final int id;
  // Calificacion en estrellas (1-5)
  final int rating;
  // Comentario del usuario (puede ser null)
  final String? description;

  // Crea OpinionModel desde JSON
  factory OpinionModel.fromJson(Map<String, dynamic> json) {
    return OpinionModel(
      id: JsonUtils.asInt(json['opinion_id']),
      rating: JsonUtils.asInt(json['calificacion']),
      description: json['descripcion'] as String?,
    );
  }

  // Convierte a JSON para guardar
  Map<String, dynamic> toJson() => {
        'opinion_id': id,
        'calificacion': rating,
        'descripcion': description,
      };
}

// Modelo de una reseña completa
// Une usuario, publicacion y opinion
class ReviewModel {
  // Constructor con todos los datos de la reseña
  const ReviewModel({
    required this.id, // ID unico de la reseña
    required this.userId, // ID del usuario que hizo la reseña
    required this.publicationId, // ID del carro que se reseñó
    required this.opinionId, // ID de la opinion/calificacion
    required this.date, // Fecha cuando se hizo la reseña
  });

  // ID de la reseña
  final int id;
  // ID del usuario arrendatario
  final int userId;
  // ID de la publicacion/carro
  final int publicationId;
  // ID de la opinion (calificacion + comentario)
  final int opinionId;
  // Fecha y hora de la reseña
  final DateTime date;

  // Crea ReviewModel desde JSON
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: JsonUtils.asInt(json['resena_id']),
      userId: JsonUtils.asInt(json['usuario_id']),
      publicationId: JsonUtils.asInt(json['publicacion_id']),
      opinionId: JsonUtils.asInt(json['opinion_id']),
      date: JsonUtils.asDateTime(json['fecha']),
    );
  }

  // Convierte a JSON para guardar
  Map<String, dynamic> toJson() => {
        'resena_id': id,
        'usuario_id': userId,
        'publicacion_id': publicationId,
        'opinion_id': opinionId,
        'fecha': date.toIso8601String(),
      };
}
