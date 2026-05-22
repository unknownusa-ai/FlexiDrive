import 'package:flexidrive/core/api/api_client.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// Modelos de publicaciones
import 'package:flexidrive/features/publications/domain/entities/publication_models.dart';

// Base de datos local de publicaciones
class LocalPublicationDb {
  // Constructor privado para singleton
  LocalPublicationDb._();

  // Instancia unica de la base de datos
  static final LocalPublicationDb instance = LocalPublicationDb._();

  // Ya cargamos los datos?
  bool? _loaded = false;
  static const _publicationsOverridesKey = 'local_publications_created_v1';
  static const _pricesOverridesKey = 'local_publication_prices_created_v1';
  static const _imagesOverridesKey = 'local_publication_images_created_v1';

  // Listas de datos en memoria
  final List<PublicationModel> publications = []; // Publicaciones de carros
  final List<PublicationPriceModel> publicationPrices =
      []; // Precios por dia/semana/mes
  final List<PublicationImageModel> publicationImages =
      []; // Fotos de los carros
  final List<PublicationModel> _createdPublications = [];
  final List<PublicationPriceModel> _createdPublicationPrices = [];
  final List<PublicationImageModel> _createdPublicationImages = [];

  // Carga todos los datos si no estan cargados
  Future<void> loadIfNeeded() async {
    // Si ya cargamos, no hacemos nada
    if (_loaded == true) return;

    final publicationsLoad = await _safeLoadList('publications');
    final pricesLoad = await _safeLoadList('publication-prices');
    final imagesLoad = await _safeLoadList('publication-images');

    // Cargamos las publicaciones principales
    publications
      ..clear()
      ..addAll(
        _parseList(
          publicationsLoad.data,
          PublicationModel.fromJson,
        ),
      );

    // Cargamos los precios de las publicaciones
    publicationPrices
      ..clear()
      ..addAll(
        _parseList(
          pricesLoad.data,
          PublicationPriceModel.fromJson,
        ),
      );

    // Cargamos las imagenes de las publicaciones
    publicationImages
      ..clear()
      ..addAll(
        _parseList(
          imagesLoad.data,
          PublicationImageModel.fromJson,
        ),
      );

    _createdPublications
      ..clear()
      ..addAll(await _loadPublicationOverrides());
    _createdPublicationPrices
      ..clear()
      ..addAll(await _loadPublicationPriceOverrides());
    _createdPublicationImages
      ..clear()
      ..addAll(await _loadPublicationImageOverrides());

    // Si hay conexión con backend, priorizamos datos remotos para evitar
    // que overrides locales viejos inflen conteos o dupliquen publicaciones.
    if (!publicationsLoad.succeeded) {
      publications.addAll(_createdPublications);
    } else if (_createdPublications.isNotEmpty) {
      _createdPublications.clear();
      await _savePublicationOverrides();
    }

    if (!pricesLoad.succeeded) {
      publicationPrices.addAll(_createdPublicationPrices);
    } else if (_createdPublicationPrices.isNotEmpty) {
      _createdPublicationPrices.clear();
      await _savePublicationPriceOverrides();
    }

    if (!imagesLoad.succeeded) {
      publicationImages.addAll(_createdPublicationImages);
    } else if (_createdPublicationImages.isNotEmpty) {
      _createdPublicationImages.clear();
      await _savePublicationImageOverrides();
    }
    _dedupeById();

    // Marcamos como cargado
    _loaded = true;
  }

  /// Gestiona recargar dentro de esta parte del flujo.
  Future<void> reload() async {
    _loaded = false;
    await loadIfNeeded();
  }

  // Convierte una lista dinamica a lista tipada
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
  Future<_LoadListResult> _safeLoadList(String endpoint) async {
    try {
      final data =
          await _loadList(endpoint).timeout(const Duration(seconds: 6));
      return _LoadListResult(data: data, succeeded: true);
    } catch (_) {
      return const _LoadListResult(data: <dynamic>[], succeeded: false);
    }
  }

  /// Gestiona siguiente publicación id dentro de esta parte del flujo.
  int nextPublicationId() {
    if (publications.isEmpty) return 1;
    return publications
            .map((item) => item.id)
            .reduce((current, next) => current > next ? current : next) +
        1;
  }

  /// Gestiona siguiente publicación precio id dentro de esta parte del flujo.
  int nextPublicationPriceId() {
    if (publicationPrices.isEmpty) return 1;
    return publicationPrices
            .map((item) => item.id)
            .reduce((current, next) => current > next ? current : next) +
        1;
  }

  /// Gestiona siguiente publicación imagen id dentro de esta parte del flujo.
  int nextPublicationImageId() {
    if (publicationImages.isEmpty) return 1;
    return publicationImages
            .map((item) => item.id)
            .reduce((current, next) => current > next ? current : next) +
        1;
  }

  /// Agregar publicación esta parte del flujo de trabajo.
  Future<PublicationModel> addPublication(PublicationModel publication) async {
    await loadIfNeeded();
    try {
      final createdRaw = await ApiClient.instance.postMap('publications', {
        'usuario_id': publication.userId,
        'vehiculo_id': publication.vehicleId,
        'fecha_publicacion': publication.publishDate.toIso8601String(),
        'activa': publication.active,
      });
      final created = PublicationModel.fromJson(createdRaw);
      _upsertPublication(created);
      return created;
    } catch (_) {
      _upsertPublication(publication);
      _upsertCreatedPublication(publication);
      await _savePublicationOverrides();
      return publication;
    }
  }

  Future<PublicationPriceModel> addPublicationPrice(
    PublicationPriceModel publicationPrice,
  ) async {
    await loadIfNeeded();
    try {
      final createdRaw =
          await ApiClient.instance.postMap('publication-prices', {
        'publicacion_id': publicationPrice.publicationId,
        'tipo_periodo_id': publicationPrice.periodTypeId,
        'precio': publicationPrice.price,
      });
      final created = PublicationPriceModel.fromJson(createdRaw);
      _upsertPublicationPrice(created);
      return created;
    } catch (_) {
      _upsertPublicationPrice(publicationPrice);
      _upsertCreatedPublicationPrice(publicationPrice);
      await _savePublicationPriceOverrides();
      return publicationPrice;
    }
  }

  Future<PublicationImageModel> addPublicationImage(
    PublicationImageModel publicationImage,
  ) async {
    await loadIfNeeded();
    try {
      final createdRaw =
          await ApiClient.instance.postMap('publication-images', {
        'publicacion_id': publicationImage.publicationId,
        'url_imagen': publicationImage.imageUrl,
        'orden': publicationImage.order,
        'es_principal': publicationImage.isMain,
        'fecha_subida': publicationImage.uploadDate.toIso8601String(),
      });
      final created = PublicationImageModel.fromJson(createdRaw);
      _upsertPublicationImage(created);
      return created;
    } catch (_) {
      _upsertPublicationImage(publicationImage);
      _upsertCreatedPublicationImage(publicationImage);
      await _savePublicationImageOverrides();
      return publicationImage;
    }
  }

  /// Carga los cambios locales sobrescritos de publicación.
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

  /// Carga los cambios locales sobrescritos de publicación price.
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

  /// Carga los cambios locales sobrescritos de publicación image.
  Future<List<PublicationImageModel>> _loadPublicationImageOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_imagesOverridesKey);
    if (raw == null || raw.isEmpty) return <PublicationImageModel>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <PublicationImageModel>[];
      return decoded
          .whereType<Map>()
          .map(
            (item) => PublicationImageModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
    } catch (_) {
      return <PublicationImageModel>[];
    }
  }

  /// Guardar publicación cambios locales esta parte del flujo de trabajo.
  Future<void> _savePublicationOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final created = _createdPublications
        .map((publication) => publication.toJson())
        .toList();
    await prefs.setString(_publicationsOverridesKey, jsonEncode(created));
  }

  /// Guardar publicación precio cambios locales esta parte del flujo de trabajo.
  Future<void> _savePublicationPriceOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final created =
        _createdPublicationPrices.map((price) => price.toJson()).toList();
    await prefs.setString(_pricesOverridesKey, jsonEncode(created));
  }

  /// Guardar publicación imagen cambios locales esta parte del flujo de trabajo.
  Future<void> _savePublicationImageOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final created =
        _createdPublicationImages.map((image) => image.toJson()).toList();
    await prefs.setString(_imagesOverridesKey, jsonEncode(created));
  }

  /// Gestiona upsert publicación dentro de esta parte del flujo.
  void _upsertPublication(PublicationModel publication) {
    final index = publications.indexWhere((item) => item.id == publication.id);
    if (index == -1) {
      publications.add(publication);
      return;
    }
    publications[index] = publication;
  }

  /// Gestiona upsert publicación precio dentro de esta parte del flujo.
  void _upsertPublicationPrice(PublicationPriceModel publicationPrice) {
    final index =
        publicationPrices.indexWhere((item) => item.id == publicationPrice.id);
    if (index == -1) {
      publicationPrices.add(publicationPrice);
      return;
    }
    publicationPrices[index] = publicationPrice;
  }

  /// Gestiona upsert publicación imagen dentro de esta parte del flujo.
  void _upsertPublicationImage(PublicationImageModel publicationImage) {
    final index =
        publicationImages.indexWhere((item) => item.id == publicationImage.id);
    if (index == -1) {
      publicationImages.add(publicationImage);
      return;
    }
    publicationImages[index] = publicationImage;
  }

  /// Gestiona upsert created publicación dentro de esta parte del flujo.
  void _upsertCreatedPublication(PublicationModel publication) {
    final index =
        _createdPublications.indexWhere((item) => item.id == publication.id);
    if (index == -1) {
      _createdPublications.add(publication);
      return;
    }
    _createdPublications[index] = publication;
  }

  /// Gestiona upsert created publicación precio dentro de esta parte del flujo.
  void _upsertCreatedPublicationPrice(PublicationPriceModel publicationPrice) {
    final index = _createdPublicationPrices
        .indexWhere((item) => item.id == publicationPrice.id);
    if (index == -1) {
      _createdPublicationPrices.add(publicationPrice);
      return;
    }
    _createdPublicationPrices[index] = publicationPrice;
  }

  /// Gestiona upsert created publicación imagen dentro de esta parte del flujo.
  void _upsertCreatedPublicationImage(PublicationImageModel publicationImage) {
    final index = _createdPublicationImages
        .indexWhere((item) => item.id == publicationImage.id);
    if (index == -1) {
      _createdPublicationImages.add(publicationImage);
      return;
    }
    _createdPublicationImages[index] = publicationImage;
  }

  /// Gestiona dedupe por id dentro de esta parte del flujo.
  void _dedupeById() {
    final publicationsMap = <int, PublicationModel>{};
    for (final item in publications) {
      publicationsMap[item.id] = item;
    }
    publications
      ..clear()
      ..addAll(publicationsMap.values);

    final pricesMap = <int, PublicationPriceModel>{};
    for (final item in publicationPrices) {
      pricesMap[item.id] = item;
    }
    publicationPrices
      ..clear()
      ..addAll(pricesMap.values);

    final imagesMap = <int, PublicationImageModel>{};
    for (final item in publicationImages) {
      imagesMap[item.id] = item;
    }
    publicationImages
      ..clear()
      ..addAll(imagesMap.values);
  }
}

/// Define la responsabilidad de `_LoadListResult` dentro de este módulo.
class _LoadListResult {
  const _LoadListResult({
    required this.data,
    required this.succeeded,
  });

  final List<dynamic> data;
  final bool succeeded;
}
