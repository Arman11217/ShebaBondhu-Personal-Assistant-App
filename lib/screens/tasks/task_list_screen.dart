import 'package:flutter/material.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../widgets/empty_state.dart';
import 'task_edit_screen.dart';

enum _TaskFilter { all, pending, done }

/// Tasks Bondhu: world-class to-do & personal task manager.
/// Executive progress hub, interactive filter pills, animated checkbubbles,
/// priority indicators, and non-truncating task cards.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, required this.taskService});

  final TaskService taskService;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> _future;
  late final Listenable _repoListenable =
      widget.taskService.repository as Listenable;
  _TaskFilter _filter = _TaskFilter.all;

  @override
  void initState() {
    super.initState();
    _future = widget.taskService.getAll();
    _repoListenable.addListener(_refresh);
  }

  @override
  void dispose() {
    _repoListenable.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() => _future = widget.taskService.getAll());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          l10n.taskListTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE8EEF2)),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _openEditor(context, null),
          backgroundColor: const Color(0xFF4F46E5),
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          icon: const Icon(Icons.add_task_rounded, size: 22),
          label: Text(
            l10n.commonAdd,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Task>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4F46E5),
              ),
            );
          }
          final all = snapshot.data ?? const <Task>[];
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: l10n.taskListEmptyTitle,
              message: l10n.taskListEmptyBody,
            );
          }
          final pending =
              all.where((t) => t.status == TaskStatus.pending).toList();
          final done = all.where((t) => t.status == TaskStatus.done).toList();
          final overdue = pending
              .where((t) =>
                  (t.daysUntilDue ?? 1) < 0 || t.daysUntilDue == 0)
              .toList();

          List<Task> displayed;
          switch (_filter) {
            case _TaskFilter.all:
              displayed = all;
              break;
            case _TaskFilter.pending:
              displayed = pending;
              break;
            case _TaskFilter.done:
              displayed = done;
              break;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              _SummaryCard(
                pendingCount: pending.length,
                doneCount: done.length,
                overdueCount: overdue.length,
                totalCount: all.length,
              ),
              const SizedBox(height: 16),
              _buildFilterBar(
                allCount: all.length,
                pendingCount: pending.length,
                doneCount: done.length,
              ),
              const SizedBox(height: 16),
              if (_filter == _TaskFilter.all) ...[
                if (pending.isEmpty)
                  _AllDoneBanner(l10n: l10n)
                else ...[
                  _SectionLabel(
                    label: l10n.taskSectionPending,
                    count: pending.length,
                    color: const Color(0xFF4F46E5),
                  ),
                  const SizedBox(height: 10),
                  ...pending.map((t) => _TaskCard(
                        task: t,
                        onTap: () => _openEditor(context, t),
                        onToggle: () => _toggleDone(t),
                        onDelete: () => _confirmDelete(context, t),
                      )),
                ],
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SectionLabel(
                    label: l10n.taskSectionDone,
                    count: done.length,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 10),
                  ...done.map((t) => _TaskCard(
                        task: t,
                        onTap: () => _openEditor(context, t),
                        onToggle: () => _toggleDone(t),
                        onDelete: () => _confirmDelete(context, t),
                      )),
                ],
              ] else ...[
                if (displayed.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Text(
                      'এই ফিল্টারে কোনো কাজ নেই',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  ...displayed.map((t) => _TaskCard(
                        task: t,
                        onTap: () => _openEditor(context, t),
                        onToggle: () => _toggleDone(t),
                        onDelete: () => _confirmDelete(context, t),
                      )),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar({
    required int allCount,
    required int pendingCount,
    required int doneCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _filterPill(_TaskFilter.all, 'সকল ($allCount)'),
          _filterPill(_TaskFilter.pending, 'বাকি ($pendingCount)'),
          _filterPill(_TaskFilter.done, 'সম্পন্ন ($doneCount)'),
        ],
      ),
    );
  }

  Widget _filterPill(_TaskFilter filter, String label) {
    final active = _filter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? AppColors.ink : AppColors.inkMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, Task? task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TaskEditScreen(
          taskService: widget.taskService,
          existing: task,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _toggleDone(Task task) async {
    final next = task.copyWith(
      status: task.status == TaskStatus.done
          ? TaskStatus.pending
          : TaskStatus.done,
    );
    await widget.taskService.update(next);
  }

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.taskService.delete(task.id);
    }
  }
}

/// Executive progress summary card: total tasks, completion rate, overdue warnings.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.pendingCount,
    required this.doneCount,
    required this.overdueCount,
    required this.totalCount,
  });

  final int pendingCount;
  final int doneCount;
  final int overdueCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? doneCount / totalCount : 0.0;
    final percentage = (progress * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20312E81),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'টাস্ক ও কাজের অগ্রগতি',
                      style: TextStyle(
                        color: Color(0xFFA5B4FC),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$percentage% সম্পন্ন',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$pendingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'টি কাজ এখনো বাকি আছে',
                        style: TextStyle(
                          color: Color(0xFFC7D2FE),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF34D399),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: Color(0xFF34D399),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'সম্পন্ন কাজ: $doneCountটি',
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (overdueCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 3,
                          backgroundColor: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$overdueCountটি সময় উত্তীর্ণ',
                          style: const TextStyle(
                            color: Color(0xFFFCA5A5),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllDoneBanner extends StatelessWidget {
  const _AllDoneBanner({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sentiment_very_satisfied_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'অভিনন্দন! সব কাজ শেষ!',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.taskAllDoneBanner,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF047857),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.count,
    required this.color,
  });
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDone = task.status == TaskStatus.done;
    final days = task.daysUntilDue;
    final overdue = !isDone && days != null && days <= 0;
    final accent = isDone
        ? const Color(0xFF94A3B8)
        : overdue
            ? const Color(0xFFDC2626)
            : priorityColor(task.priority);

    final dueLabel = _dueLabel(l10n, days, isDone);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: overdue
              ? const Color(0xFFFECACA)
              : const Color(0xFFE8EEF2),
          width: overdue ? 1.4 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CheckBubble(
                  filled: isDone,
                  color: isDone ? const Color(0xFF10B981) : accent,
                  onTap: onToggle,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDone ? const Color(0xFF94A3B8) : AppColors.ink,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (task.note != null && task.note!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          task.note!,
                          style: const TextStyle(
                            color: AppColors.inkMuted,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (dueLabel != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: overdue
                                    ? const Color(0xFFFEF2F2)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    overdue
                                        ? Icons.error_outline_rounded
                                        : Icons.schedule_rounded,
                                    size: 12,
                                    color: overdue
                                        ? const Color(0xFFDC2626)
                                        : AppColors.inkMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dueLabel,
                                    style: TextStyle(
                                      color: overdue
                                          ? const Color(0xFFDC2626)
                                          : const Color(0xFF475569),
                                      fontSize: 11,
                                      fontWeight: overdue
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          _PriorityBadge(priority: task.priority),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.commonDelete,
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.inkMuted,
                  iconSize: 20,
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _dueLabel(AppLocalizations l10n, int? days, bool isDone) {
    if (days == null) return null;
    final abs = days.abs();
    if (isDone) {
      return l10n.taskCompletedOnDate(abs);
    }
    if (days < 0) {
      return l10n.taskOverdue(abs);
    }
    if (days == 0) return l10n.taskDueToday;
    if (days == 1) return l10n.taskDueTomorrow;
    return l10n.taskDueIn(days);
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    switch (priority) {
      case TaskPriority.high:
        label = 'উচ্চ অগ্রাধিকার';
        color = const Color(0xFFDC2626);
        break;
      case TaskPriority.normal:
        label = 'সাধারণ';
        color = const Color(0xFF059669);
        break;
      case TaskPriority.low:
        label = 'কম অগ্রাধিকার';
        color = const Color(0xFF64748B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CheckBubble extends StatelessWidget {
  const _CheckBubble({
    required this.filled,
    required this.color,
    required this.onTap,
  });

  final bool filled;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: filled ? color : const Color(0xFFCBD5E1),
            width: 2,
          ),
        ),
        child: filled
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}