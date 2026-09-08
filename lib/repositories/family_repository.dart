import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/family_member.dart';
import '../services/firebase/firestore_sync_service.dart';

/// Single source of truth for family members. UI subscribes via
/// [watchAll]; mutations go through [add] / [update] / [delete].
abstract class FamilyRepository {
  List<FamilyMember> getAll();
  Stream<List<FamilyMember>> watchAll();
  Future<FamilyMember> add(FamilyMember member);
  Future<void> update(FamilyMember member);
  Future<void> delete(String id);
}

class MockFamilyRepository extends ChangeNotifier
    implements FamilyRepository {
  MockFamilyRepository({List<FamilyMember>? seed})
      : _members = seed ?? [] {
    _loadFromCloud();
  }

  void _loadFromCloud() async {
    final cloud = await FirestoreSyncService.instance.fetchFamily();
    _members.clear();
    _members.addAll(cloud);
    _emit();
  }

  final List<FamilyMember> _members;
  final _controller = StreamController<List<FamilyMember>>.broadcast();

  @override
  List<FamilyMember> getAll() {
    // Self first, then sort by relation order, then by name.
    const order = <FamilyRelation, int>{
      FamilyRelation.self: 0,
      FamilyRelation.spouse: 1,
      FamilyRelation.father: 2,
      FamilyRelation.mother: 3,
      FamilyRelation.son: 4,
      FamilyRelation.daughter: 5,
      FamilyRelation.brother: 6,
      FamilyRelation.sister: 7,
      FamilyRelation.grandfather: 8,
      FamilyRelation.grandmother: 9,
      FamilyRelation.other: 10,
    };
    final sorted = [..._members]..sort((a, b) {
        final byRel = order[a.relation]!.compareTo(order[b.relation]!);
        if (byRel != 0) return byRel;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return sorted;
  }

  @override
  Stream<List<FamilyMember>> watchAll() async* {
    yield getAll();
    yield* _controller.stream;
  }

  @override
  Future<FamilyMember> add(FamilyMember member) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _members.add(member);
    _emit();
    await FirestoreSyncService.instance.saveFamily(member);
    return member;
  }

  @override
  Future<void> update(FamilyMember member) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final i = _members.indexWhere((e) => e.id == member.id);
    if (i >= 0) {
      _members[i] = member;
      _emit();
      await FirestoreSyncService.instance.saveFamily(member);
    }
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _members.removeWhere((e) => e.id == id);
    _emit();
    await FirestoreSyncService.instance.deleteFamily(id);
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
