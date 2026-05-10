import 'package:flexidrive/features/documents/domain/ports/repositorio_documentos_puerto.dart';
import 'package:flexidrive/features/documents/infrastructure/datasources/local_document_db.dart';

class RepositorioDocumentosLocal implements RepositorioDocumentosPuerto {
  RepositorioDocumentosLocal({LocalDocumentDb? origen})
      : _origen = origen ?? LocalDocumentDb.instance;

  final LocalDocumentDb _origen;

  @override
  Future<void> inicializar() async {
    await _origen.loadIfNeeded();
  }

  LocalDocumentDb get origen => _origen;
}
