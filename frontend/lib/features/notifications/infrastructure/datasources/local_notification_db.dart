import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flexidrive/core/api/api_client.dart';
import 'package:flexidrive/features/notifications/domain/entities/notification_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Define la responsabilidad de `LocalNotificationDb` dentro de este módulo.
class LocalNotificationDb {
  /// Crea una instancia y prepara el estado inicial de `LocalNotificationDb`.
  LocalNotificationDb._();

  static final LocalNotificationDb instance = LocalNotificationDb._();
  static const _notificationsOverridesKey = 'local_notifications_created_v1';

  bool? _loaded = false;

  final List<NotificationModel> notifications = [];
  final List<NotificationModel> _createdNotifications = [];
  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  /// Carga los datos necesarios para cargar if needed.
  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;
    await reload();
  }

  /// Gestiona recargar dentro de esta parte del flujo.
  Future<void> reload() async {
    final remote = _parseList(
      await _safeLoadList('notifications'),
      NotificationModel.fromJson,
    );
    _createdNotifications
      ..clear()
      ..addAll(await _loadNotificationOverrides());
    final merged = <int, NotificationModel>{
      for (final item in remote) item.id: item,
      for (final item in _createdNotifications) item.id: item,
    };

    notifications
      ..clear()
      ..addAll(merged.values);

    _loaded = true;
    changes.value = changes.value + 1;
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

    NotificationModel notification;
    try {
      notification = NotificationModel.fromJson(
        await ApiClient.instance.postMap('notifications', {
          'usuario_id': userId,
          'categoria_notificacion_id': categoryId,
          'asunto': subject,
          'descripcion': description,
          'estado': status,
          'fecha_envio': (sentAt ?? DateTime.now()).toIso8601String(),
        }),
      );
    } catch (_) {
      final nextId = notifications.isEmpty
          ? 1
          : notifications
                  .map((item) => item.id)
                  .reduce((a, b) => a > b ? a : b) +
              1;
      notification = NotificationModel(
        id: nextId,
        userId: userId,
        categoryId: categoryId,
        subject: subject,
        description: description,
        status: status,
        sentAt: sentAt ?? DateTime.now(),
      );
    }

    final index =
        notifications.indexWhere((item) => item.id == notification.id);
    if (index == -1) {
      notifications.add(notification);
    } else {
      notifications[index] = notification;
    }
    final createdIndex =
        _createdNotifications.indexWhere((item) => item.id == notification.id);
    if (createdIndex == -1) {
      _createdNotifications.add(notification);
    } else {
      _createdNotifications[createdIndex] = notification;
    }
    await _saveNotificationOverrides();
    changes.value = changes.value + 1;
    return notification;
  }

  /// Marca una notificación como leída.
  Future<void> markAsRead(int notificationId) async {
    await loadIfNeeded();
    NotificationModel? updatedModel;
    try {
      final updated = await ApiClient.instance.patchMap(
        'notifications/$notificationId',
        {'estado': 'leida'},
      );
      updatedModel = NotificationModel.fromJson(updated);
    } catch (_) {}
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final current = notifications[index];
      notifications[index] = updatedModel ??
          NotificationModel(
            id: current.id,
            userId: current.userId,
            categoryId: current.categoryId,
            subject: current.subject,
            description: current.description,
            status: 'leida',
            sentAt: current.sentAt,
          );
      final createdIndex =
          _createdNotifications.indexWhere((item) => item.id == notificationId);
      if (createdIndex != -1) {
        _createdNotifications[createdIndex] = notifications[index];
      }
      await _saveNotificationOverrides();
    }
    changes.value = changes.value + 1;
  }

  /// Elimina los datos vinculados a eliminar notificación.
  Future<void> deleteNotification(int notificationId) async {
    await loadIfNeeded();
    try {
      await ApiClient.instance.delete('notifications/$notificationId');
    } catch (_) {}
    notifications.removeWhere((n) => n.id == notificationId);
    _createdNotifications.removeWhere((n) => n.id == notificationId);
    await _saveNotificationOverrides();
    changes.value = changes.value + 1;
  }

  List<T> _parseList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) parser,
  ) {
    final raw = (source as List<dynamic>? ?? const []);
    return raw.map((item) => parser(item as Map<String, dynamic>)).toList();
  }

  /// Carga los datos necesarios para cargar lista.
  Future<List<dynamic>> _loadList(String endpoint) =>
      ApiClient.instance.getList(endpoint);

  /// Gestiona carga segura de lista dentro de esta parte del flujo.
  Future<List<dynamic>> _safeLoadList(String endpoint) async {
    try {
      return await _loadList(endpoint).timeout(const Duration(seconds: 6));
    } catch (_) {
      return const [];
    }
  }

  /// Carga los cambios locales sobrescritos de notificación.
  Future<List<NotificationModel>> _loadNotificationOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_notificationsOverridesKey);
    if (raw == null || raw.isEmpty) return <NotificationModel>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <NotificationModel>[];
      return decoded
          .whereType<Map>()
          .map(
            (item) => NotificationModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } catch (_) {
      return <NotificationModel>[];
    }
  }

  /// Guardar notificación cambios locales esta parte del flujo de trabajo.
  Future<void> _saveNotificationOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _createdNotifications.map((item) => item.toJson()).toList();
    await prefs.setString(_notificationsOverridesKey, jsonEncode(data));
  }
}
