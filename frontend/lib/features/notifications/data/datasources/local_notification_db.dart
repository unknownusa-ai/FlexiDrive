import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/notification_models.dart';

class LocalNotificationDb {
  LocalNotificationDb._();

  static final LocalNotificationDb instance = LocalNotificationDb._();

  bool? _loaded = false;

  final List<NotificationModel> notifications = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    final rawJson = await rootBundle.loadString('assets/data/operations_data.json');
    final decoded = json.decode(rawJson) as Map<String, dynamic>;

    notifications
      ..clear()
      ..addAll(_parseList(decoded['notificacion'], NotificationModel.fromJson));

    _loaded = true;
  }

  List<T> _parseList<T>(
    dynamic source,
    T Function(Map<String, dynamic>) parser,
  ) {
    final raw = (source as List<dynamic>? ?? const []);
    return raw.map((item) => parser(item as Map<String, dynamic>)).toList();
  }
}
