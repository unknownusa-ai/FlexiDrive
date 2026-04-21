import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/publication_models.dart';

class LocalPublicationDb {
  LocalPublicationDb._();

  static final LocalPublicationDb instance = LocalPublicationDb._();

  bool? _loaded = false;

  final List<PublicationModel> publications = [];
  final List<PublicationPriceModel> publicationPrices = [];
  final List<PublicationImageModel> publicationImages = [];

  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    final rawJson = await rootBundle.loadString('assets/data/operations_data.json');
    final decoded = json.decode(rawJson) as Map<String, dynamic>;

    publications
      ..clear()
      ..addAll(_parseList(decoded['publicacion'], PublicationModel.fromJson));
    publicationPrices
      ..clear()
      ..addAll(
        _parseList(decoded['precio_publicacion'], PublicationPriceModel.fromJson),
      );
    publicationImages
      ..clear()
      ..addAll(
        _parseList(decoded['imagen_publicacion'], PublicationImageModel.fromJson),
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
