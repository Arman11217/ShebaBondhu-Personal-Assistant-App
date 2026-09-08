import '../core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Status of a [Task]. Drives section grouping on the list screen
/// and the accent color on each card.
enum TaskStatus { pending, done }

extension TaskStatusX on TaskStatus {
  String get key => name;

  /// True if the task is still open. Convenience for callers that
  /// want to check "is this thing still on the to-do list?".
  bool get isPending => this == TaskStatus.pending;
}

/// Priority bucket — used for sorting and color cue.
enum TaskPriority { low, normal, high }

extension TaskPriorityX on TaskPriority {
  String get key => name;
}

Color priorityColor(TaskPriority p) {
  switch (p) {
    case TaskPriority.high:
      return AppColors.critical;
    case TaskPriority.normal:
      return AppColors.brandGreen;
    case TaskPriority.low:
      return AppColors.inkMuted;
  }
}

/// A single to-do entry. Title is required; due date, note and priority
/// are optional. [status] controls whether it shows up under Pending or
/// Done on the list screen.
class Task {
  final String id;
  final String title;
  final String? note;
  final DateTime? dueDate;
  final TaskPriority priority;
  final TaskStatus status;

  /// When the task was created — used for stable sort of undated entries.
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.note,
    this.dueDate,
    this.priority = TaskPriority.normal,
    this.status = TaskStatus.pending,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? note,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Days until [dueDate]. Negative = overdue, null = no due date.
  int? get daysUntilDue {
    final d = dueDate;
    if (d == null) return null;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final target = DateTime(d.year, d.month, d.day);
    return target.difference(start).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'note': note,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] as String? ?? '',
      note: map['note'] as String?,
      dueDate: map['dueDate'] != null
          ? DateTime.tryParse(map['dueDate'] as String)
          : null,
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == map['priority'],
        orElse: () => TaskPriority.normal,
      ),
      status: TaskStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
