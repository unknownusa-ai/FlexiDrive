import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flexidrive/models/reviews/review_models.dart';

class LocalReviewDb {
  LocalReviewDb._();

  static final LocalReviewDb instance = LocalReviewDb._();

  bool? _loaded = false;

  final List<OpinionModel> opinions = [];
  final List<ReviewModel> reviews = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    opinions
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/operations/opinions.json'),
          OpinionModel.fromJson,
        ),
      );
    reviews
      ..clear()
      ..addAll(
        _parseList(await _loadList('assets/data/operations/reviews.json'), ReviewModel.fromJson),
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

  Future<List<dynamic>> _loadList(String assetPath) async {
    final rawJson = await rootBundle.loadString(assetPath);
    return (json.decode(rawJson) as List<dynamic>? ?? const []);
  }
}
