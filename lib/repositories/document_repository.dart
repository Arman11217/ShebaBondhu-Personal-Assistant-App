import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/identity_document.dart';
import '../services/firebase/firestore_sync_service.dart';

/// Single source of truth for identity documents (NID, passport, license,
/// certificates, etc.). UI subscribes via [watchAll]; mutations go through
/// [add] / [update] / [delete].
abstract class DocumentRepository {
  /// All current documents, soonest-expiring first.
  List<IdentityDocument> getAll();

  /// Subscribe to a stream of document-list changes.
  Stream<List<IdentityDocument>> watchAll();

  Future<IdentityDocument> add(IdentityDocument doc);
  Future<void> update(IdentityDocument doc);
  Future<void> delete(String id);
}

/// In-memory and Firestore synchronized document repository.
class MockDocumentRepository extends ChangeNotifier implements DocumentRepository {
  MockDocumentRepository({List<IdentityDocument>? seed})
      : _docs = seed ?? [] {
    _loadFromCloud();
  }

  void _loadFromCloud() async {
    final cloud = await FirestoreSyncService.instance.fetchDocuments();
    _docs.clear();
    _docs.addAll(cloud);
    _emit();
  }

  final List<IdentityDocument> _docs;
  final _controller = StreamController<List<IdentityDocument>>.broadcast();

  @override
  List<IdentityDocument> getAll() {
    final sorted = [..._docs]
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    return sorted;
  }

  @override
  Stream<List<IdentityDocument>> watchAll() async* {
    yield getAll();
    yield* _controller.stream;
  }

  @override
  Future<IdentityDocument> add(IdentityDocument doc) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _docs.add(doc);
    _emit();
    await FirestoreSyncService.instance.saveDocument(doc);
    return doc;
  }

  @override
  Future<void> update(IdentityDocument doc) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final i = _docs.indexWhere((e) => e.id == doc.id);
    if (i >= 0) {
      _docs[i] = doc;
      _emit();
      await FirestoreSyncService.instance.saveDocument(doc);
    }
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _docs.removeWhere((e) => e.id == id);
    _emit();
    await FirestoreSyncService.instance.deleteDocument(id);
  }

  void _emit() {
    notifyListeners();
    _controller.add(getAll());
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
