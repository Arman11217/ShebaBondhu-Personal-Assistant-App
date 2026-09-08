import '../models/sim_card.dart';
import '../repositories/sim_repository.dart';

/// Public API for the family SIM/recharge module. Backed by a
/// [SimRepository] - in Phase 2 the repo is the in-memory mock; in
/// Phase 3 a Firestore-backed implementation will be swapped in
/// `main.dart`.
class SimService {
  SimService({SimRepository? repository})
      : _repo = repository ?? MockSimRepository();

  final SimRepository _repo;

  SimRepository get repository => _repo;
  Stream<List<SimCard>> watchAll() => _repo.watchAll();
  List<SimCard> getAll() => _repo.getAll();

  SimCard? getById(String id) {
    try {
      return _repo.getAll().firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<SimCard> add(SimCard sim) => _repo.add(sim);
  Future<void> update(SimCard sim) => _repo.update(sim);
  Future<void> delete(String id) => _repo.delete(id);
}
