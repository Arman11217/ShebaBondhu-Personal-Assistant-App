import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/warranty_product.dart';
import '../services/firebase/firestore_sync_service.dart';

/// Single source of truth for family warranties. UI subscribes via
/// [watchAll]; mutations go through [add] / [update] / [delete].
abstract class WarrantyRepository {
  List<WarrantyProduct> getAll();
  Stream<List<WarrantyProduct>> watchAll();
  Future<WarrantyProduct> add(WarrantyProduct product);
  Future<void> update(WarrantyProduct product);
  Future<void> delete(String id);
}

/// In-memory and Firestore synchronized warranty repository.
class MockWarrantyRepository extends ChangeNotifier
    implements WarrantyRepository {
  MockWarrantyRepository({List<WarrantyProduct>? seed})
      : _items = seed ?? [] {
    _loadFromCloud();
  }

  void _loadFromCloud() async {
    final cloud = await FirestoreSyncService.instance.fetchWarranty();
    _items.clear();
    _items.addAll(cloud);
    _emit();
  }

  final List<WarrantyProduct> _items;
  final _controller = StreamController<List<WarrantyProduct>>.broadcast();

  @override
  List<WarrantyProduct> getAll() {
    const order = <WarrantyStatus, int>{
      WarrantyStatus.expired: 0,
      WarrantyStatus.expiringSoon: 1,
      WarrantyStatus.active: 2,
    };
    final sorted = [..._items]
      ..sort((a, b) => order[a.status]!.compareTo(order[b.status]!));
    return sorted;
  }

  @override
  Stream<List<WarrantyProduct>> watchAll() async* {
    yield getAll();
    yield* _controller.stream;
  }

  @override
  Future<WarrantyProduct> add(WarrantyProduct product) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final withStatus = product.copyWith(
      status: computeWarrantyStatus(product.expiryDate),
    );
    _items.add(withStatus);
    _emit();
    await FirestoreSyncService.instance.saveWarranty(withStatus);
    return withStatus;
  }

  @override
  Future<void> update(WarrantyProduct product) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final withStatus = product.copyWith(
      status: computeWarrantyStatus(product.expiryDate),
    );
    final i = _items.indexWhere((e) => e.id == product.id);
    if (i >= 0) {
      _items[i] = withStatus;
      _emit();
      await FirestoreSyncService.instance.saveWarranty(withStatus);
    }
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _items.removeWhere((e) => e.id == id);
    _emit();
    await FirestoreSyncService.instance.deleteWarranty(id);
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
