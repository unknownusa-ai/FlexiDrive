import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/review_models.dart';

class LocalReviewDb {
  LocalReviewDb._();

  static final LocalReviewDb instance = LocalReviewDb._();

  bool? _loaded = false;

  final List<OpinionModel> opinions = [];
  final List<ReviewModel> reviews = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    final rawJson = await rootBundle.loadString('assets/data/operations_data.json');
    final decoded = json.decode(rawJson) as Map<String, dynamic>;

    opinions
      ..clear()
      ..addAll(_parseList(decoded['opinion'], OpinionModel.fromJson));
    reviews
      ..clear()
      ..addAll(_parseList(decoded['resena'], ReviewModel.fromJson));

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
