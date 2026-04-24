// Para trabajar con JSON
import 'dart:convert';
// Para leer archivos locales (assets)
import 'package:flutter/services.dart';
// Modelos de publicaciones
import 'package:flexidrive/models/publications/publication_models.dart';

// Base de datos local de publicaciones
// Carga las publicaciones, precios e imagenes desde JSON
class LocalPublicationDb {
  // Constructor privado para singleton
  LocalPublicationDb._();

  // Instancia unica de la base de datos
  static final LocalPublicationDb instance = LocalPublicationDb._();

  // Ya cargamos los datos?
  bool? _loaded = false;

  // Listas de datos en memoria
  final List<PublicationModel> publications = []; // Publicaciones de carros
  final List<PublicationPriceModel> publicationPrices =
      []; // Precios por dia/semana/mes
  final List<PublicationImageModel> publicationImages =
      []; // Fotos de los carros

  // Carga todos los datos si no estan cargados
  Future<void> loadIfNeeded() async {
    // Si ya cargamos, no hacemos nada
    if (_loaded == true) return;

    // Cargamos las publicaciones principales
    publications
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/operations/publications.json'),
          PublicationModel.fromJson,
        ),
      );

    // Cargamos los precios de las publicaciones
    publicationPrices
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/operations/publication_prices.json'),
          PublicationPriceModel.fromJson,
        ),
      );

    // Cargamos las imagenes de las publicaciones
    publicationImages
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('assets/data/operations/publication_images.json'),
          PublicationImageModel.fromJson,
        ),
      );

    // Marcamos como cargado
    _loaded = true;
  }

  // Convierte una lista dinamica a lista tipada
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
