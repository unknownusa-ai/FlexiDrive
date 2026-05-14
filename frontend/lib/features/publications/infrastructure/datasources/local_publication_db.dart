import 'package:flexidrive/core/api/api_client.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// Modelos de publicaciones
import 'package:flexidrive/features/publications/domain/entities/publication_models.dart';

// Base de datos local de publicaciones
// Carga las publicaciones, precios e imagenes desde JSON
class LocalPublicationDb {
  // Constructor privado para singleton
  LocalPublicationDb._();

  // Instancia unica de la base de datos
  static final LocalPublicationDb instance = LocalPublicationDb._();

  // Ya cargamos los datos?
  bool? _loaded = false;
  static const _publicationsOverridesKey = 'local_publications_created_v1';
  static const _pricesOverridesKey = 'local_publication_prices_created_v1';

  // Listas de datos en memoria
  final List<PublicationModel> publications = []; // Publicaciones de carros
  final List<PublicationPriceModel> publicationPrices =
      []; // Precios por dia/semana/mes
  final List<PublicationImageModel> publicationImages =
      []; // Fotos de los carros
  final List<PublicationModel> _createdPublications = [];
  final List<PublicationPriceModel> _createdPublicationPrices = [];

  // Carga todos los datos si no estan cargados
  Future<void> loadIfNeeded() async {
    // Si ya cargamos, no hacemos nada
    if (_loaded == true) return;

    // Cargamos las publicaciones principales
    publications
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('publications'),
          PublicationModel.fromJson,
        ),
      );

    // Cargamos los precios de las publicaciones
    publicationPrices
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('publication-prices'),
          PublicationPriceModel.fromJson,
        ),
      );

    // Cargamos las imagenes de las publicaciones
    publicationImages
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('publication-images'),
          PublicationImageModel.fromJson,
        ),
      );

    _createdPublications
      ..clear()
      ..addAll(await _loadPublicationOverrides());
    _createdPublicationPrices
      ..clear()
      ..addAll(await _loadPublicationPriceOverrides());
    publications.addAll(_createdPublications);
    publicationPrices.addAll(_createdPublicationPrices);

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

  Future<List<dynamic>> _loadList(String endpoint) =>
      ApiClient.instance.getList(endpoint);

  int nextPublicationId() {
    if (publications.isEmpty) return 1;
    return publications
            .map((item) => item.id)
            .reduce((current, next) => current > next ? current : next) +
        1;
  }

  int nextPublicationPriceId() {
    if (publicationPrices.isEmpty) return 1;
    return publicationPrices
            .map((item) => item.id)
            .reduce((current, next) => current > next ? current : next) +
        1;
  }

  void addPublication(PublicationModel publication) {
    publications.add(publication);
    _createdPublications.add(publication);
    _savePublicationOverrides();
  }

  void addPublicationPrice(PublicationPriceModel publicationPrice) {
    publicationPrices.add(publicationPrice);
    _createdPublicationPrices.add(publicationPrice);
    _savePublicationPriceOverrides();
  }

  Future<List<PublicationModel>> _loadPublicationOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_publicationsOverridesKey);
    if (raw == null || raw.isEmpty) return <PublicationModel>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <PublicationModel>[];
      return decoded
          .whereType<Map>()
          .map(
            (item) => PublicationModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } catch (_) {
      return <PublicationModel>[];
    }
  }

  Future<List<PublicationPriceModel>> _loadPublicationPriceOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pricesOverridesKey);
    if (raw == null || raw.isEmpty) return <PublicationPriceModel>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <PublicationPriceModel>[];
      return decoded
          .whereType<Map>()
          .map(
            (item) => PublicationPriceModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } catch (_) {
      return <PublicationPriceModel>[];
    }
  }

  void _savePublicationOverrides() {
    SharedPreferences.getInstance().then((prefs) {
      final created = _createdPublications
          .map((publication) => publication.toJson())
          .toList();
      prefs.setString(_publicationsOverridesKey, jsonEncode(created));
    });
  }

  void _savePublicationPriceOverrides() {
    SharedPreferences.getInstance().then((prefs) {
      final created =
          _createdPublicationPrices.map((price) => price.toJson()).toList();
      prefs.setString(_pricesOverridesKey, jsonEncode(created));
    });
  }
}
