import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/document_models.dart';

class LocalDocumentDb {
  LocalDocumentDb._();

  static final LocalDocumentDb instance = LocalDocumentDb._();

  bool? _loaded = false;

  final List<LandlordDocumentModel> documents = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    final rawJson = await rootBundle.loadString('assets/data/operations_data.json');
    final decoded = json.decode(rawJson) as Map<String, dynamic>;

    documents
      ..clear()
      ..addAll(
        _parseList(decoded['documento_arrendador'], LandlordDocumentModel.fromJson),
      );

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
