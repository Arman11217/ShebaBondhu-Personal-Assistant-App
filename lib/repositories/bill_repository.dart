import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/bill.dart';
import '../services/firebase/firestore_sync_service.dart';

/// Single source of truth for household Bills.
abstract class BillRepository {
  /// All current bills, nearest due-date first.
  List<Bill> getAll();

  /// Subscribe to a stream of bill-list changes.
  Stream<List<Bill>> watchAll();

  Future<Bill> add(Bill bill);
  Future<void> update(Bill bill);
  Future<void> delete(String id);
}

/// In-memory and Firestore synchronized repository.
class MockBillRepository extends ChangeNotifier implements BillRepository {
  MockBillRepository({List<Bill>? seed}) : _bills = seed ?? [] {
    _loadFromCloud();
  }

  void _loadFromCloud() async {
    final cloud = await FirestoreSyncService.instance.fetchBills();
    _bills.clear();
    _bills.addAll(cloud);
    _emit();
  }

  final List<Bill> _bills;
  final _controller = StreamController<List<Bill>>.broadcast();

  @override
  List<Bill> getAll() {
    final sorted = [..._bills]..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return sorted;
  }

  @override
  Stream<List<Bill>> watchAll() async* {
    yield getAll();
    yield* _controller.stream;
  }

  @override
  Future<Bill> add(Bill bill) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _bills.add(bill);
    _emit();
    await FirestoreSyncService.instance.saveBill(bill);
    return bill;
  }

  @override
  Future<void> update(Bill bill) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final i = _bills.indexWhere((e) => e.id == bill.id);
    if (i >= 0) {
      _bills[i] = bill;
      _emit();
      await FirestoreSyncService.instance.saveBill(bill);
    }
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _bills.removeWhere((e) => e.id == id);
    _emit();
    await FirestoreSyncService.instance.deleteBill(id);
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
