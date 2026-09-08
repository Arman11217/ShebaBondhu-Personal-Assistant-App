import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/medicine.dart';
import '../services/firebase/firestore_sync_service.dart';

/// Single source of truth for medicines. UI subscribes via [watchAll];
/// mutations go through [add] / [update] / [delete].
abstract class MedicineRepository {
  /// All current medicines, soonest-expiring first (lowest daysRemaining).
  List<Medicine> getAll();

  /// Subscribe to a stream of medicine-list changes.
  Stream<List<Medicine>> watchAll();

  Future<Medicine> add(Medicine medicine);
  Future<void> update(Medicine medicine);
  Future<void> delete(String id);
}

/// In-memory and Firestore synchronized medicine repository.
class MockMedicineRepository extends ChangeNotifier
    implements MedicineRepository {
  MockMedicineRepository({List<Medicine>? seed})
      : _meds = seed ?? [] {
    _loadFromCloud();
  }

  void _loadFromCloud() async {
    final cloud = await FirestoreSyncService.instance.fetchMedicines();
    _meds.clear();
    _meds.addAll(cloud);
    _emit();
  }

  final List<Medicine> _meds;
  final _controller = StreamController<List<Medicine>>.broadcast();

  @override
  List<Medicine> getAll() {
    final sorted = [..._meds]
      ..sort((a, b) => a.estimatedDaysRemaining
          .compareTo(b.estimatedDaysRemaining));
    return sorted;
  }

  @override
  Stream<List<Medicine>> watchAll() async* {
    yield getAll();
    yield* _controller.stream;
  }

  @override
  Future<Medicine> add(Medicine medicine) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _meds.add(medicine);
    _emit();
    await FirestoreSyncService.instance.saveMedicine(medicine);
    return medicine;
  }

  @override
  Future<void> update(Medicine medicine) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final i = _meds.indexWhere((e) => e.id == medicine.id);
    if (i >= 0) {
      _meds[i] = medicine;
      _emit();
      await FirestoreSyncService.instance.saveMedicine(medicine);
    }
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _meds.removeWhere((e) => e.id == id);
    _emit();
    await FirestoreSyncService.instance.deleteMedicine(id);
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
