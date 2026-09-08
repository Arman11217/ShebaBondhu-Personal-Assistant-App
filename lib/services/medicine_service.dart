import '../models/medicine.dart';
import '../repositories/medicine_repository.dart';

/// Public API for the family medicine stock. Backed by a [MedicineRepository]
/// — in Phase 2 the repo is the in-memory mock; in Phase 3 a Firestore-backed
/// implementation will be swapped in `main.dart`.
class MedicineService {
  MedicineService({MedicineRepository? repository})
      : _repo = repository ?? MockMedicineRepository();

  final MedicineRepository _repo;

  MedicineRepository get repository => _repo;
  Stream<List<Medicine>> watchAll() => _repo.watchAll();
  List<Medicine> getAll() => _repo.getAll();

  Medicine? getById(String id) {
    try {
      return _repo.getAll().firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Medicine> add(Medicine medicine) => _repo.add(medicine);
  Future<void> update(Medicine medicine) => _repo.update(medicine);
  Future<void> delete(String id) => _repo.delete(id);
}
