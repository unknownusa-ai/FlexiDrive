import 'package:flutter/foundation.dart';
import 'package:flexidrive/features/notifications/domain/ports/repositorio_notificaciones_puerto.dart';
import 'package:flexidrive/features/notifications/domain/entities/notification_models.dart';
import 'package:flexidrive/features/notifications/infrastructure/datasources/local_notification_db.dart';

class RepositorioNotificacionesLocal
    implements RepositorioNotificacionesPuerto {
  RepositorioNotificacionesLocal({LocalNotificationDb? origen})
      : _origen = origen ?? LocalNotificationDb.instance;

  final LocalNotificationDb _origen;

  @override
  Future<void> inicializar() async {
    await _origen.loadIfNeeded();
  }

  @override
  List<NotificationModel> obtenerNotificaciones() => _origen.notifications;

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

  LocalNotificationDb get origen => _origen;
}
