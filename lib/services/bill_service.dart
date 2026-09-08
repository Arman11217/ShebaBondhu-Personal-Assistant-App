import '../models/bill.dart';
import '../repositories/bill_repository.dart';
import 'notification/notification_service.dart';

/// Public API for bills. Backed by a [BillRepository] — in Phase 2 the
/// repo is the in-memory mock; in Phase 3 it'll be a Firestore-backed
/// implementation, swapped in `main.dart`.
class BillService {
  BillService({BillRepository? repository})
      : _repo = repository ?? MockBillRepository();

  final BillRepository _repo;

  BillRepository get repository => _repo;
  Stream<List<Bill>> watchAll() => _repo.watchAll();
  List<Bill> getAll() => _repo.getAll();
  Bill? getById(String id) =>
      _repo.getAll().firstWhere((b) => b.id == id, orElse: () => _missing);
  Future<Bill> add(Bill bill) async {
    final result = await _repo.add(bill);
    await NotificationService.instance.scheduleItemReminders(
      itemId: result.id,
      title: '${result.label} বিল পরিশোধ',
      subtitle: '${result.provider} - ৳${result.amount.toStringAsFixed(0)}',
      dueDateTime: result.nextDueDate,
    );
    return result;
  }

  Future<void> update(Bill bill) async {
    await _repo.update(bill);
    await NotificationService.instance.scheduleItemReminders(
      itemId: bill.id,
      title: '${bill.label} বিল পরিশোধ',
      subtitle: '${bill.provider} - ৳${bill.amount.toStringAsFixed(0)}',
      dueDateTime: bill.nextDueDate,
    );
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await NotificationService.instance.cancelItemReminders(id);
  }

  static final Bill _missing = Bill(
    id: '',
    label: '',
    provider: '',
    type: BillType.other,
    amount: 0,
    nextDueDate: DateTime(1970),
  );
}