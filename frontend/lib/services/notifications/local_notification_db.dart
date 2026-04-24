import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
          await _loadList('assets/data/operations/notifications.json'),
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

    final notification = NotificationModel(
      id: _nextNotificationId(),
      userId: userId,
      categoryId: categoryId,
      subject: subject,
      description: description,
      status: status,
      sentAt: sentAt ?? DateTime.now(),
    );

    notifications.add(notification);
    changes.value = changes.value + 1;
    return notification;
  }

  int _nextNotificationId() {
    if (notifications.isEmpty) return 1;
    final maxId =
        notifications.map((n) => n.id).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  List<T> _parseList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) parser,
  ) {
    final raw = (source as List<dynamic>? ?? const []);
    return raw.map((item) => parser(item as Map<String, dynamic>)).toList();
  }

  Future<List<dynamic>> _loadList(String assetPath) async {
    final rawJson = await rootBundle.loadString(assetPath);
    return (json.decode(rawJson) as List<dynamic>? ?? const []);
  }
}
