import 'package:flutter/material.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../widgets/forms/bangla_text_field.dart';
import '../../widgets/forms/date_field_bn.dart';

/// Form to add or edit a task: hero task input card, priority cards with
/// color feedback, due date selector, status toggle, and sticky bottom action button.
class TaskEditScreen extends StatefulWidget {
  const TaskEditScreen({
    super.key,
    required this.taskService,
    this.existing,
  });

  final TaskService taskService;
  final Task? existing;

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  late final TextEditingController _titleC;
  late final TextEditingController _noteC;

  TaskPriority _priority = TaskPriority.normal;
  TaskStatus _status = TaskStatus.pending;
  DateTime? _dueDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleC = TextEditingController(text: e?.title ?? '');
    _noteC = TextEditingController(text: e?.note ?? '');
    _priority = e?.priority ?? TaskPriority.normal;
    _status = e?.status ?? TaskStatus.pending;
    _dueDate = e?.dueDate;
  }

  @override
  void dispose() {
    _titleC.dispose();
    _noteC.dispose();
    super.dispose();
  }

  bool get _isEditing =>
      widget.existing != null && widget.existing!.id.isNotEmpty;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      id: _isEditing
          ? widget.existing!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleC.text.trim(),
      note: _noteC.text.trim().isEmpty ? null : _noteC.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
      status: _status,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      await widget.taskService.update(task);
    } else {
      await widget.taskService.add(task);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? l10n.taskEditTitle : l10n.taskAddTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: 0.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE8EEF2)),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: l10n.commonDelete,
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final existing = widget.existing;
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
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
                if (ok == true && existing != null) {
                  await widget.taskService.delete(existing.id);
                  if (!mounted) return;
                  navigator.pop();
                }
              },
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _save,
              child: const Text(
                'সংরক্ষণ',
                style: TextStyle(
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded, size: 20),
              label: Text(
                l10n.commonSave,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: AppColors.white,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // Task Title Card
            _buildTitleCard(l10n),
            const SizedBox(height: 20),

            // Priority Selector Card
            _buildPriorityCard(l10n),
            const SizedBox(height: 20),

            // Due Date Card
            _buildDateCard(l10n),
            const SizedBox(height: 20),

            // Notes Card
            _buildNotesCard(l10n),
            const SizedBox(height: 20),

            // Status Card (if editing)
            if (widget.existing != null) ...[
              _buildStatusCard(l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTitleCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'কাজের বিবরণ বা শিরোনাম',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 10),
          BanglaTextField(
            controller: _titleC,
            label: l10n.taskFieldTitle,
            hint: l10n.taskFieldTitleHint,
            required: true,
            prefixIcon: Icons.task_alt_rounded,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.taskFieldPriority,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: TaskPriority.values.map((p) {
              final selected = _priority == p;
              final color = priorityColor(p);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: TaskPriority.values.indexOf(p) ==
                            TaskPriority.values.length - 1
                        ? 0
                        : 8,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withValues(alpha: 0.12)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? color : const Color(0xFFE2E8F0),
                          width: selected ? 1.6 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _priorityLabel(l10n, p),
                        style: TextStyle(
                          color: selected ? color : AppColors.ink,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'কাজের শেষ সময়সীমা (ঐচ্ছিক)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          DateFieldBn(
            label: l10n.taskFieldDueDate,
            value: _dueDate,
            onChanged: (d) => setState(() => _dueDate = d),
            onCleared: () => setState(() => _dueDate = null),
            allowClear: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'অতিরিক্ত নোট বা তথ্য',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          BanglaTextField(
            controller: _noteC,
            label: l10n.taskFieldNote,
            hint: l10n.taskFieldNoteHint,
            prefixIcon: Icons.notes_rounded,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(AppLocalizations l10n) {
    final isDone = _status == TaskStatus.done;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone ? const Color(0xFF10B981) : const Color(0xFFE8EEF2),
          width: isDone ? 1.4 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDone ? Icons.task_alt_rounded : Icons.pending_actions_rounded,
              color: isDone ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDone ? l10n.taskStatusDone : l10n.taskStatusPending,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  isDone ? l10n.taskStatusDoneHint : l10n.taskStatusPendingHint,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isDone,
            onChanged: (v) => setState(() {
              _status = v ? TaskStatus.done : TaskStatus.pending;
            }),
            activeTrackColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  static String _priorityLabel(AppLocalizations l10n, TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return l10n.taskPriorityHigh;
      case TaskPriority.normal:
        return l10n.taskPriorityNormal;
      case TaskPriority.low:
        return l10n.taskPriorityLow;
    }
  }
}