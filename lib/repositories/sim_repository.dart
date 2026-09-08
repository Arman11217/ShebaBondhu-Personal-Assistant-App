import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/sim_card.dart';
import '../services/firebase/firestore_sync_service.dart';

/// Single source of truth for family SIM cards. UI subscribes via
/// [watchAll]; mutations go through [add] / [update] / [delete].
abstract class SimRepository {
  /// All current SIM cards, most urgent first.
  List<SimCard> getAll();

  /// Subscribe to a stream of SIM-list changes.
  Stream<List<SimCard>> watchAll();

  Future<SimCard> add(SimCard sim);
  Future<void> update(SimCard sim);
  Future<void> delete(String id);
}

/// In-memory and Firestore synchronized SIM repository.
class MockSimRepository extends ChangeNotifier implements SimRepository {
  MockSimRepository({List<SimCard>? seed}) : _sims = seed ?? [] {
    _loadFromCloud();
  }

  void _loadFromCloud() async {
    final cloud = await FirestoreSyncService.instance.fetchSims();
    _sims.clear();
    _sims.addAll(cloud);
    _emit();
  }

  final List<SimCard> _sims;
  final _controller = StreamController<List<SimCard>>.broadcast();

  @override
  List<SimCard> getAll() {
    // Urgency order: needsRecharge > packageExpiringSoon > dataLow > active.
    const order = <SimStatus, int>{
      SimStatus.needsRecharge: 0,
      SimStatus.packageExpiringSoon: 1,
      SimStatus.dataLow: 2,
      SimStatus.active: 3,
    };
    final sorted = [..._sims]
      ..sort((a, b) => order[a.status]!.compareTo(order[b.status]!));
    return sorted;
  }

  @override
  Stream<List<SimCard>> watchAll() async* {
    yield getAll();
    yield* _controller.stream;
  }

  @override
  Future<SimCard> add(SimCard sim) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    // Always re-derive status on write so the list is consistent.
    final withStatus = sim.copyWith(
      status: computeSimStatus(
        lastRechargeDate: sim.lastRechargeDate,
        validityDays: sim.validityDays,
        dataBalanceGb: sim.dataBalanceGb,
      ),
    );
    _sims.add(withStatus);
    _emit();
    await FirestoreSyncService.instance.saveSim(withStatus);
    return withStatus;
  }

  @override
  Future<void> update(SimCard sim) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final withStatus = sim.copyWith(
      status: computeSimStatus(
        lastRechargeDate: sim.lastRechargeDate,
        validityDays: sim.validityDays,
        dataBalanceGb: sim.dataBalanceGb,
      ),
    );
    final i = _sims.indexWhere((e) => e.id == sim.id);
    if (i >= 0) {
      _sims[i] = withStatus;
      _emit();
      await FirestoreSyncService.instance.saveSim(withStatus);
    }
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _sims.removeWhere((e) => e.id == id);
    _emit();
    await FirestoreSyncService.instance.deleteSim(id);
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