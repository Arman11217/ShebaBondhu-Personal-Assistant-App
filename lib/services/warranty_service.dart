import '../models/warranty_product.dart';
import '../repositories/warranty_repository.dart';

/// Public API for the warranty module. Backed by a [WarrantyRepository].
class WarrantyService {
  WarrantyService({WarrantyRepository? repository})
      : _repo = repository ?? MockWarrantyRepository();

  final WarrantyRepository _repo;

  WarrantyRepository get repository => _repo;
  Stream<List<WarrantyProduct>> watchAll() => _repo.watchAll();
  List<WarrantyProduct> getAll() => _repo.getAll();

  WarrantyProduct? getById(String id) {
    try {
      return _repo.getAll().firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<WarrantyProduct> add(WarrantyProduct product) => _repo.add(product);
  Future<void> update(WarrantyProduct product) => _repo.update(product);
  Future<void> delete(String id) => _repo.delete(id);
}
