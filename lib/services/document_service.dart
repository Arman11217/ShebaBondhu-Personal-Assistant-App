import '../models/identity_document.dart';
import '../repositories/document_repository.dart';

/// Public API for identity documents. Backed by a [DocumentRepository] —
/// in Phase 2 the repo is the in-memory mock; in Phase 3 it'll be a
/// Firestore-backed implementation, swapped in `main.dart`.
class DocumentService {
  DocumentService({DocumentRepository? repository})
      : _repo = repository ?? MockDocumentRepository();

  final DocumentRepository _repo;

  DocumentRepository get repository => _repo;
  Stream<List<IdentityDocument>> watchAll() => _repo.watchAll();
  List<IdentityDocument> getAll() => _repo.getAll();

  IdentityDocument? getById(String id) =>
      _repo.getAll().firstWhere((d) => d.id == id, orElse: () => _missing);

  Future<IdentityDocument> add(IdentityDocument doc) => _repo.add(doc);
  Future<void> update(IdentityDocument doc) => _repo.update(doc);
  Future<void> delete(String id) => _repo.delete(id);

  static final IdentityDocument _missing = IdentityDocument(
    id: '',
    type: DocumentType.other,
    label: '',
    expiryDate: DateTime(1970),
  );
}
