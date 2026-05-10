import 'package:flutter/foundation.dart';

import 'package:flexidrive/core/api/api_client.dart';
import 'package:flexidrive/models/notifications/notification_models.dart';

class LocalNotificationDb {
  LocalNotificationDb._();

  static final LocalNotificationDb instance = LocalNotificationDb._();

  bool? _loaded = false;

  final List<NotificationModel> notifications = [];
  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    notifications
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('notifications'),
          NotificationModel.fromJson,
        ),
      );

    _loaded = true;
  }

  Future<NotificationModel> addNotification({
    required int userId,
    required int categoryId,
    required String subject,
    required String description,
    String status = 'no_leida',
    DateTime? sentAt,
  }) async {
    await loadIfNeeded();

    final notification = NotificationModel.fromJson(
      await ApiClient.instance.postMap('notifications', {
        'usuario_id': userId,
        'categoria_notificacion_id': categoryId,
        'asunto': subject,
        'descripcion': description,
        'estado': status,
        'fecha_envio': (sentAt ?? DateTime.now()).toIso8601String(),
      }),
    );

    notifications.add(notification);
    changes.value = changes.value + 1;
    return notification;
  }

  List<T> _parseList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) parser,
  ) {
    final raw = (source as List<dynamic>? ?? const []);
    return raw.map((item) => parser(item as Map<String, dynamic>)).toList();
  }

  Future<List<dynamic>> _loadList(String endpoint) =>
      ApiClient.instance.getList(endpoint);
}
