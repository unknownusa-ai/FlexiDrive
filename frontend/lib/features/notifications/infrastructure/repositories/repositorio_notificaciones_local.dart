import 'package:flutter/foundation.dart';
import 'package:flexidrive/features/notifications/domain/ports/repositorio_notificaciones_puerto.dart';
import 'package:flexidrive/features/notifications/domain/entities/notification_models.dart';
import 'package:flexidrive/features/notifications/infrastructure/datasources/local_notification_db.dart';

/// Define la responsabilidad de `RepositorioNotificacionesLocal` dentro de este módulo.
class RepositorioNotificacionesLocal
    implements RepositorioNotificacionesPuerto {
  RepositorioNotificacionesLocal({LocalNotificationDb? origen})
      : _origen = origen ?? LocalNotificationDb.instance;

  final LocalNotificationDb _origen;

  /// Gestiona inicializar dentro de esta parte del flujo.
  @override
  Future<void> inicializar() async {
    await _origen.loadIfNeeded();
  }

  /// Obtiene la información asociada a obtener notificaciones.
  @override
  List<NotificationModel> obtenerNotificaciones() => _origen.notifications;

  /// Obtiene la información asociada a obtener cambios.
  @override
  ValueListenable<int> obtenerCambios() => _origen.changes;

  @override
  Future<NotificationModel> agregarNotificacion({
    required int userId,
    required int categoryId,
    required String subject,
    required String description,
    String status = 'no_leida',
    DateTime? sentAt,
  }) {
    return _origen.addNotification(
      userId: userId,
      categoryId: categoryId,
      subject: subject,
      description: description,
      status: status,
      sentAt: sentAt,
    );
  }

  /// Marcar como leida esta parte del flujo de trabajo.
  @override
  Future<void> marcarComoLeida(int notificationId) {
    return _origen.markAsRead(notificationId);
  }

  /// Elimina los datos vinculados a eliminar notificacion.
  @override
  Future<void> eliminarNotificacion(int notificationId) {
    return _origen.deleteNotification(notificationId);
  }

  LocalNotificationDb get origen => _origen;
}
