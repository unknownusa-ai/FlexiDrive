import 'package:flexidrive/features/documents/domain/ports/repositorio_documentos_puerto.dart';
import 'package:flexidrive/features/documents/infrastructure/datasources/local_document_db.dart';

/// Define la responsabilidad de `RepositorioDocumentosLocal` dentro de este módulo.
class RepositorioDocumentosLocal implements RepositorioDocumentosPuerto {
  RepositorioDocumentosLocal({LocalDocumentDb? origen})
      : _origen = origen ?? LocalDocumentDb.instance;

  final LocalDocumentDb _origen;

  /// Gestiona inicializar dentro de esta parte del flujo.
  @override
  Future<void> inicializar() async {
    await _origen.loadIfNeeded();
  }

  LocalDocumentDb get origen => _origen;
}
