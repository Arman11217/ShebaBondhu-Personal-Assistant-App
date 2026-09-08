import '../models/family_member.dart';
import '../repositories/family_repository.dart';

/// Public API for the Family Bondhu module. Backed by a
/// [FamilyRepository].
class FamilyService {
  FamilyService({FamilyRepository? repository})
      : _repo = repository ?? MockFamilyRepository();

  final FamilyRepository _repo;

  FamilyRepository get repository => _repo;
  Stream<List<FamilyMember>> watchAll() => _repo.watchAll();
  List<FamilyMember> getAll() => _repo.getAll();

  FamilyMember? getById(String id) {
    try {
      return _repo.getAll().firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<FamilyMember> add(FamilyMember member) => _repo.add(member);
  Future<void> update(FamilyMember member) => _repo.update(member);
  Future<void> delete(String id) => _repo.delete(id);
}
