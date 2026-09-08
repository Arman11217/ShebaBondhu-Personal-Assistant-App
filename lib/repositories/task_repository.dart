import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/firebase/firestore_sync_service.dart';

/// Storage-agnostic contract the rest of the app talks to.
abstract class TaskRepository {
  Future<List<Task>> getAll();
  List<Task> getAllSync();
  Stream<List<Task>> watchAll();
  Task? getById(String id);
  Future<void> add(Task task);
  Future<void> update(Task task);
  Future<void> delete(String id);
}

/// In-memory and Firestore synchronized task repository.
class MockTaskRepository extends ChangeNotifier
    implements TaskRepository {
  MockTaskRepository() {
    _items = [];
    _emit();
    _loadFromCloud();
  }

  void _loadFromCloud() async {
    final cloud = await FirestoreSyncService.instance.fetchTasks();
    _items = cloud;
    _emit();
  }

  late List<Task> _items;
  final _controller = StreamController<List<Task>>.broadcast();

  @override
  Future<List<Task>> getAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _sorted(_items);
  }

  @override
  List<Task> getAllSync() => _sorted(_items);

  @override
  Stream<List<Task>> watchAll() => _controller.stream;

  @override
  Task? getById(String id) {
    for (final t in _items) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  Future<void> add(Task task) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _items = [..._items, task];
    _emit();
    await FirestoreSyncService.instance.saveTask(task);
  }

  @override
  Future<void> update(Task task) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _items = _items.map((t) => t.id == task.id ? task : t).toList();
    _emit();
    await FirestoreSyncService.instance.saveTask(task);
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _items = _items.where((t) => t.id != id).toList();
    _emit();
    await FirestoreSyncService.instance.deleteTask(id);
  }

  void _emit() {
    notifyListeners();
    _controller.add(_sorted(_items));
  }

  /// Group Pending first, then Done. Inside each group, overdue / today
  /// first, then by due date ascending, then priority, then creation time.
  static List<Task> _sorted(List<Task> items) {
    final pending = items
        .where((t) => t.status == TaskStatus.pending)
        .toList()
      ..sort(_compare);
    final done = items
        .where((t) => t.status == TaskStatus.done)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return [...pending, ...done];
  }

  static int _compare(Task a, Task b) {
    final ad = a.daysUntilDue;
    final bd = b.daysUntilDue;

    // Items without a due date sort last within Pending.
    if (ad == null && bd == null) {
      final byPriority = _priorityOrder(a.priority)
          .compareTo(_priorityOrder(b.priority));
      if (byPriority != 0) return byPriority;
      return a.createdAt.compareTo(b.createdAt);
    }
    if (ad == null) return 1;
    if (bd == null) return -1;

    if (ad != bd) return ad.compareTo(bd);
    final byPriority =
        _priorityOrder(a.priority).compareTo(_priorityOrder(b.priority));
    if (byPriority != 0) return byPriority;
    return a.createdAt.compareTo(b.createdAt);
  }

  static int _priorityOrder(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return 0;
      case TaskPriority.normal:
        return 1;
      case TaskPriority.low:
        return 2;
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
