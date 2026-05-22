import 'package:flexidrive/core/api/api_client.dart';
import 'package:flexidrive/features/documents/domain/entities/document_models.dart';

/// Define la responsabilidad de `LocalDocumentDb` dentro de este módulo.
class LocalDocumentDb {
  /// Crea una instancia y prepara el estado inicial de `LocalDocumentDb`.
  LocalDocumentDb._();

  static final LocalDocumentDb instance = LocalDocumentDb._();

  bool? _loaded = false;

  final List<LandlordDocumentModel> documents = [];

  /// Carga los datos necesarios para cargar if needed.
  Future<void> loadIfNeeded() async {
    if (_loaded == true) return;

    documents
      ..clear()
      ..addAll(
        _parseList(
          await _loadList('landlord-documents'),
          LandlordDocumentModel.fromJson,
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

  /// Carga los datos necesarios para cargar lista.
  Future<List<dynamic>> _loadList(String endpoint) =>
      ApiClient.instance.getList(endpoint);
}
