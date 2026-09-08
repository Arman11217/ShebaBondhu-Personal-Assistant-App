import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/money_entry.dart';
import '../services/firebase/firestore_sync_service.dart';

/// Single source of truth for Money entries.
abstract class MoneyRepository {
  /// All current money entries, newest due-date first.
  List<MoneyEntry> getAll();

  /// Subscribe to a stream of money entry changes. Useful for screens that
  /// want to react without polling.
  Stream<List<MoneyEntry>> watchAll();

  Future<MoneyEntry> add(MoneyEntry entry);
  Future<void> update(MoneyEntry entry);
  Future<void> delete(String id);
}

/// In-memory and Firestore synchronized repository.
class MockMoneyRepository extends ChangeNotifier implements MoneyRepository {
  MockMoneyRepository({List<MoneyEntry>? seed})
      : _entries = seed ?? [] {
    _loadFromCloud();
  }

  void _loadFromCloud() async {
    final cloud = await FirestoreSyncService.instance.fetchMoney();
    _entries.clear();
    _entries.addAll(cloud);
    _emit();
  }

  final List<MoneyEntry> _entries;
  final _controller = StreamController<List<MoneyEntry>>.broadcast();

  @override
  List<MoneyEntry> getAll() {
    final sorted = [..._entries]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return sorted;
  }

  @override
  Stream<List<MoneyEntry>> watchAll() async* {
    yield getAll();
    yield* _controller.stream;
  }

  @override
  Future<MoneyEntry> add(MoneyEntry entry) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _entries.add(entry);
    _emit();
    await FirestoreSyncService.instance.saveMoney(entry);
    return entry;
  }

  @override
  Future<void> update(MoneyEntry entry) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final i = _entries.indexWhere((e) => e.id == entry.id);
    if (i >= 0) {
      _entries[i] = entry;
      _emit();
      await FirestoreSyncService.instance.saveMoney(entry);
    }
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _entries.removeWhere((e) => e.id == id);
    _emit();
    await FirestoreSyncService.instance.deleteMoney(id);
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