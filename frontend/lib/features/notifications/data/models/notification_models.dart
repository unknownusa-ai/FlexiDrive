import '../../../shared/utils/json_utils.dart';
import '../../domain/entities/notification_entities.dart';

class NotificationModel extends Notification {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.categoryId,
    required super.subject,
    required super.description,
    required super.status,
    required super.sentAt,
  });

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
