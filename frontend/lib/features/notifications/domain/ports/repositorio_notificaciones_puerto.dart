import 'package:flutter/foundation.dart';
import 'package:flexidrive/features/notifications/domain/entities/notification_models.dart';

abstract class RepositorioNotificacionesPuerto {
  Future<void> inicializar();
  List<NotificationModel> obtenerNotificaciones();
  ValueListenable<int> obtenerCambios();
  Future<NotificationModel> agregarNotificacion({
    required int userId,
    required int categoryId,
    required String subject,
    required String description,
    String status,
    DateTime? sentAt,
  });
  Future<void> marcarComoLeida(int notificationId);
  Future<void> eliminarNotificacion(int notificationId);
}
