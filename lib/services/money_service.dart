import '../models/money_entry.dart';
import '../repositories/money_repository.dart';
import 'notification/notification_service.dart';

/// Public API for money data. Backed by a [MoneyRepository] — in Phase 2
/// the repo is the in-memory mock; in Phase 3 it'll be a Firestore-backed
/// implementation, swapped here in `main.dart`.
class MoneyService {
  MoneyService({MoneyRepository? repository})
      : _repo = repository ?? MockMoneyRepository();

  final MoneyRepository _repo;

  MoneyRepository get repository => _repo;
  Stream<List<MoneyEntry>> watchAll() => _repo.watchAll();
  List<MoneyEntry> getAll() => _repo.getAll();

  Future<MoneyEntry> add(MoneyEntry entry) async {
    final result = await _repo.add(entry);
    final typeLabel = result.direction == MoneyDirection.receive
        ? 'টাকা পাওয়ার তাগাদা'
        : 'টাকা পরিশোধের রিমাইন্ডার';
    await NotificationService.instance.scheduleItemReminders(
      itemId: result.id,
      title: '$typeLabel (${result.person})',
      subtitle: 'পরিমাণ: ৳${result.amount.toStringAsFixed(0)}',
      dueDateTime: result.dueDate,
    );
    return result;
  }

  Future<void> update(MoneyEntry entry) async {
    await _repo.update(entry);
    final typeLabel = entry.direction == MoneyDirection.receive
        ? 'টাকা পাওয়ার তাগাদা'
        : 'টাকা পরিশোধের রিমাইন্ডার';
    await NotificationService.instance.scheduleItemReminders(
      itemId: entry.id,
      title: '$typeLabel (${entry.person})',
      subtitle: 'পরিমাণ: ৳${entry.amount.toStringAsFixed(0)}',
      dueDateTime: entry.dueDate,
    );
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await NotificationService.instance.cancelItemReminders(id);
  }
}