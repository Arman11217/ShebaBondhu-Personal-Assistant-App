import '../models/task.dart';
import '../repositories/task_repository.dart';
import 'notification/notification_service.dart';

/// Thin public facade over [TaskRepository]. Future Firebase swaps land
/// here without touching screens.
class TaskService {
  TaskService({TaskRepository? repository})
      : repository = repository ?? MockTaskRepository();

  final TaskRepository repository;

  Future<List<Task>> getAll() => repository.getAll();
  List<Task> getAllSync() => repository.getAllSync();
  Stream<List<Task>> watchAll() => repository.watchAll();
  Task? getById(String id) => repository.getById(id);

  Future<void> add(Task task) async {
    await repository.add(task);
    if (task.dueDate != null) {
      await NotificationService.instance.scheduleItemReminders(
        itemId: task.id,
        title: task.title,
        subtitle: task.note ?? 'টাস্ক সম্পন্ন করার সময় হয়েছে',
        dueDateTime: task.dueDate!,
      );
    }
  }

  Future<void> update(Task task) async {
    await repository.update(task);
    if (task.dueDate != null) {
      await NotificationService.instance.scheduleItemReminders(
        itemId: task.id,
        title: task.title,
        subtitle: task.note ?? 'টাস্ক সম্পন্ন করার সময় হয়েছে',
        dueDateTime: task.dueDate!,
      );
    }
  }

  Future<void> delete(String id) async {
    await repository.delete(id);
    await NotificationService.instance.cancelItemReminders(id);
  }
}
