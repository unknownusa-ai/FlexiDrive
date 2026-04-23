import 'package:flexidrive/utils/json_utils.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.subject,
    required this.description,
    required this.status,
    required this.sentAt,
  });

  final int id;
  final int userId;
  final int categoryId;
  final String subject;
  final String description;
  final String status;
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
