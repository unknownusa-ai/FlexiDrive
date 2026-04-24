// Utilidades para convertir JSON
import 'package:flexidrive/utils/json_utils.dart';

// Modelo de notificación
// Representa una notificación enviada a un usuario
class NotificationModel {
  // Constructor con todos los datos de la notificación
  const NotificationModel({
    required this.id, // ID único de la notificación
    required this.userId, // ID del usuario destinatario
    required this.categoryId, // Categoría de la notificación (reserva, pago, etc)
    required this.subject, // Asunto o título de la notificación
    required this.description, // Descripción detallada del mensaje
    required this.status, // Estado (leída, no leída)
    required this.sentAt, // Fecha y hora de envío
  });

  // ID en la base de datos
  final int id;
  // ID del usuario que recibe la notificación
  final int userId;
  // ID de la categoría de notificación
  final int categoryId;
  // Asunto o título de la notificación
  final String subject;
  // Descripción o contenido del mensaje
  final String description;
  // Estado de la notificación (leída/no leída)
  final String status;
  // Fecha y hora de envío
  final DateTime sentAt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: JsonUtils.asInt(json['notificacion_id']),
      userId: JsonUtils.asInt(json['usuario_id']),
      categoryId: JsonUtils.asInt(json['categoria_notificacion_id']),
      subject: JsonUtils.asString(json['asunto']),
      description: JsonUtils.asString(json['descripcion']),
      status: JsonUtils.asString(json['estado']),
      sentAt: JsonUtils.asDateTime(json['fecha_envio']),
    );
  }

  Map<String, dynamic> toJson() => {
        'notificacion_id': id,
        'usuario_id': userId,
        'categoria_notificacion_id': categoryId,
        'asunto': subject,
        'descripcion': description,
        'estado': status,
        'fecha_envio': sentAt.toIso8601String(),
      };
}
