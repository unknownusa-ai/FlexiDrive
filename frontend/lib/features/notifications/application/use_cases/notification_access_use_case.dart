import 'package:flutter/foundation.dart';
import 'package:flexidrive/features/notifications/domain/entities/notification_models.dart';
import 'package:flexidrive/features/notifications/domain/ports/repositorio_notificaciones_puerto.dart';

class NotificationAccessUseCase {
  NotificationAccessUseCase(this._repository);

  final RepositorioNotificacionesPuerto _repository;

  Future<void> loadIfNeeded() => _repository.inicializar();

  List<NotificationModel> get notifications {
    return _repository.obtenerNotificaciones();
  }

  ValueListenable<int> get changes => _repository.obtenerCambios();

  Future<NotificationModel> addNotification({
    required int userId,
    required int categoryId,
    required String subject,
    required String description,
    String status = 'no_leida',
    DateTime? sentAt,
  }) {
    return _repository.agregarNotificacion(
      userId: userId,
      categoryId: categoryId,
      subject: subject,
      description: description,
      status: status,
      sentAt: sentAt,
    );
  }

  Future<void> markAsRead(int notificationId) {
    return _repository.marcarComoLeida(notificationId);
  }

  Future<void> deleteNotification(int notificationId) {
    return _repository.eliminarNotificacion(notificationId);
  }
}
