import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flexidrive/models/publications/publication_models.dart';

class LocalPublicationDb {
  LocalPublicationDb._();

  static final LocalPublicationDb instance = LocalPublicationDb._();

  bool? _loaded = false;

  final List<PublicationModel> publications = [];
  final List<PublicationPriceModel> publicationPrices = [];
  final List<PublicationImageModel> publicationImages = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    publications
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/operations/publications.json'),
          PublicationModel.fromJson,
        ),
      );
    publicationPrices
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/operations/publication_prices.json'),
          PublicationPriceModel.fromJson,
        ),
      );
    publicationImages
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/operations/publication_images.json'),
          PublicationImageModel.fromJson,
        ),
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
