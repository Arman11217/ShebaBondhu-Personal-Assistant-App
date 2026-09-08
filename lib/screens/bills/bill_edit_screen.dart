import 'package:flutter/material.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/bill.dart';
import '../../models/recurring.dart';
import '../../models/severity.dart';
import '../../services/bill_service.dart';
import '../../widgets/forms/bangla_text_field.dart';
import '../../widgets/forms/date_field_bn.dart';

/// Production-grade add/edit form for a Bill: hero amount card with presets,
/// modern utility category grid, stylized provider inputs, recurrence & auto-pay controls.
class BillEditScreen extends StatefulWidget {
  const BillEditScreen({
    super.key,
    required this.billService,
    this.existing,
    this.billId,
  });

  final BillService billService;
  final Bill? existing;
  final String? billId;

  @override
  State<BillEditScreen> createState() => _BillEditScreenState();
}

class _BillEditScreenState extends State<BillEditScreen> {
  late final TextEditingController _label;
  late final TextEditingController _provider;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late BillType _type;
  late DateTime _dueDate;
  late Recurring _recurring;
  late Severity _severity;
  late bool _autoPay;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing =>
      (widget.existing != null && widget.existing!.id.isNotEmpty) ||
      widget.billId != null;

  @override
  void initState() {
    super.initState();
    Bill? b = widget.existing;
    if (b == null && widget.billId != null) {
      b = widget.billService.getById(widget.billId!);
    }
    _label = TextEditingController(text: b?.label ?? '');
    _provider = TextEditingController(text: b?.provider ?? '');
    _amount = TextEditingController(
      text: b == null ? '' : _formatForEdit(b.amount),
    );
    _note = TextEditingController(text: b?.note ?? '');
    _type = b?.type ?? BillType.electricity;
    _dueDate = b?.nextDueDate ?? DateTime.now().add(const Duration(days: 7));
    _recurring = b?.recurring ?? Recurring.monthly;
    _severity = b?.severity ?? Severity.normal;
    _autoPay = b?.autoPay ?? false;
  }

  @override
  void dispose() {
    _label.dispose();
    _provider.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  String _formatForEdit(double v) {
    final whole = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buf.write(',');
      buf.write(whole[i]);
    }
    return buf.toString();
  }

  void _addPreset(int delta) {
    final raw = _amount.text.replaceAll(',', '').replaceAll(' ', '');
    final current = double.tryParse(raw) ?? 0.0;
    final updated = current + delta;
    _amount.text = updated.toStringAsFixed(0);
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final rawAmount =
        _amount.text.replaceAll(',', '').replaceAll(' ', '');
    final amount = double.tryParse(rawAmount) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('সঠিক বিলের পরিমাণ লিখুন'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }
    final id = _isEditing
        ? (widget.existing?.id ?? widget.billId!)
        : 'b${DateTime.now().millisecondsSinceEpoch}';
    final bill = Bill(
      id: id,
      type: _type,
      label: _label.text.trim(),
      provider: _provider.text.trim(),
      amount: amount,
      nextDueDate: _dueDate,
      recurring: _recurring,
      severity: _severity,
      autoPay: _autoPay,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );
    if (_isEditing) {
      await widget.billService.update(bill);
    } else {
      await widget.billService.add(bill);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.billEditTitle : l10n.billAddTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE8EEF2)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _save,
              child: Text(
                l10n.commonSave,
                style: const TextStyle(
                  color: AppColors.brandGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
            children: [
              // Hero Amount Card
              _buildAmountCard(),
              const SizedBox(height: 20),

              // Utility Type Selector
              _TypeGrid(
                value: _type,
                onChanged: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: 20),

              // Nickname & Provider Details
              _buildSectionCard(
                title: 'বিলের বিবরণ ও প্রতিষ্ঠান',
                children: [
                  BanglaTextField(
                    controller: _label,
                    label: l10n.billFieldLabel,
                    hint: l10n.billFieldLabelHint,
                    required: true,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 14),
                  BanglaTextField(
                    controller: _provider,
                    label: l10n.billFieldProvider,
                    hint: l10n.billFieldProviderHint,
                    required: true,
                    textCapitalization: TextCapitalization.words,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Due Date & Scheduling
              _buildSectionCard(
                title: 'পরিশোধের সময়সীমা ও পুনরাবৃত্তি',
                children: [
                  DateFieldBn(
                    label: l10n.billFieldNextDue,
                    value: _dueDate,
                    onChanged: (d) => setState(() => _dueDate = d),
                  ),
                  const SizedBox(height: 16),
                  _RecurringSelector(
                    value: _recurring,
                    onChanged: (r) => setState(() => _recurring = r),
                  ),
                  const SizedBox(height: 16),
                  _SeveritySelector(
                    value: _severity,
                    onChanged: (s) => setState(() => _severity = s),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // AutoPay Toggle Card
              _AutoPaySwitch(
                value: _autoPay,
                onChanged: (v) => setState(() => _autoPay = v),
              ),
              const SizedBox(height: 20),

              // Additional Note
              _buildSectionCard(
                title: 'অতিরিক্ত নোট (ঐচ্ছিক)',
                children: [
                  BanglaTextField(
                    controller: _note,
                    label: l10n.billFieldNote,
                    hint: l10n.billFieldNoteHint,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Primary Save Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandGreen.withValues(alpha: 0.3),
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
                    backgroundColor: AppColors.brandGreen,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'বিলের পরিমাণ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '৳',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: '০.০০',
                    hintStyle: TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontWeight: FontWeight.w700,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'পরিমাণ উল্লেখ করুন';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _presetChip('+১০০', 100),
                _presetChip('+৫০০', 500),
                _presetChip('+১,০০০', 1000),
                _presetChip('+২,০০০', 2000),
                _presetChip('+৫,০০০', 5000),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetChip(String label, int delta) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _addPreset(delta),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
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
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _TypeGrid extends StatelessWidget {
  const _TypeGrid({required this.value, required this.onChanged});
  final BillType value;
  final ValueChanged<BillType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <(BillType, String, IconData, Color, List<Color>)>[
      (BillType.electricity, l10n.billTypeElectricity, Icons.bolt_rounded,
          const Color(0xFFD97706), const [Color(0xFFF59E0B), Color(0xFFD97706)]),
      (BillType.gas, l10n.billTypeGas, Icons.local_fire_department_rounded,
          const Color(0xFFDC2626), const [Color(0xFFEF4444), Color(0xFFDC2626)]),
      (BillType.water, l10n.billTypeWater, Icons.water_drop_rounded,
          const Color(0xFF0284C7), const [Color(0xFF38BDF8), Color(0xFF0284C7)]),
      (BillType.internet, l10n.billTypeInternet, Icons.wifi_rounded,
          const Color(0xFF059669), const [Color(0xFF10B981), Color(0xFF059669)]),
      (BillType.tv, l10n.billTypeTv, Icons.tv_rounded,
          const Color(0xFF7C3AED), const [Color(0xFFA78BFA), Color(0xFF7C3AED)]),
      (BillType.mobile, l10n.billTypeMobile, Icons.phone_iphone_rounded,
          const Color(0xFF0D9488), const [Color(0xFF14B8A6), Color(0xFF0D9488)]),
      (BillType.other, l10n.billTypeOther, Icons.receipt_long_rounded,
          const Color(0xFF64748B), const [Color(0xFF94A3B8), Color(0xFF64748B)]),
    ];

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
            'বিলের ধরন নির্ধারণ করুন',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = 8.0;
              final itemWidth = (constraints.maxWidth - spacing * 3) / 4;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: items.map((it) {
                  final selected = it.$1 == value;
                  return GestureDetector(
                    onTap: () => onChanged(it.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: itemWidth,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? it.$4.withValues(alpha: 0.1)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? it.$4 : const Color(0xFFE2E8F0),
                          width: selected ? 1.8 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              gradient: selected
                                  ? LinearGradient(colors: it.$5)
                                  : null,
                              color: selected ? null : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              it.$3,
                              color: selected ? Colors.white : const Color(0xFF64748B),
                              size: 19,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            it.$2,
                            style: TextStyle(
                              color: selected ? it.$4 : AppColors.ink,
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 11.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecurringSelector extends StatelessWidget {
  const _RecurringSelector({required this.value, required this.onChanged});
  final Recurring value;
  final ValueChanged<Recurring> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <_ChipItem>[
      _ChipItem(Recurring.none, l10n.recurringNone),
      _ChipItem(Recurring.monthly, l10n.recurringMonthly),
      _ChipItem(Recurring.yearly, l10n.recurringYearly),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.billFieldRecurring,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.inkMuted,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: items.map((it) {
            final selected = it.value == value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: items.indexOf(it) == items.length - 1 ? 0 : 8,
                ),
                child: GestureDetector(
                  onTap: () => onChanged(it.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppColors.brandGreen
                            : const Color(0xFFE2E8F0),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      it.label,
                      style: TextStyle(
                        color: selected ? AppColors.brandGreenDark : AppColors.ink,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
    );
  }
}

class _ChipItem {
  const _ChipItem(this.value, this.label);
  final Recurring value;
  final String label;
}

class _SeveritySelector extends StatelessWidget {
  const _SeveritySelector({required this.value, required this.onChanged});
  final Severity value;
  final ValueChanged<Severity> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <(Severity, String, Color)>[
      (Severity.normal, l10n.severityNormal, const Color(0xFF059669)),
      (Severity.important, l10n.severityImportant, const Color(0xFFD97706)),
      (Severity.critical, l10n.severityCritical, const Color(0xFFDC2626)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.billFieldSeverity,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.inkMuted,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: items.map((it) {
            final selected = it.$1 == value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: items.indexOf(it) == items.length - 1 ? 0 : 8,
                ),
                child: GestureDetector(
                  onTap: () => onChanged(it.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? it.$3.withValues(alpha: 0.12)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? it.$3 : const Color(0xFFE2E8F0),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      it.$2,
                      style: TextStyle(
                        color: selected ? it.$3 : AppColors.ink,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
    );
  }
}

class _AutoPaySwitch extends StatelessWidget {
  const _AutoPaySwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value ? const Color(0xFFF59E0B) : const Color(0xFFE8EEF2),
          width: value ? 1.4 : 1,
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: value
                  ? const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    )
                  : null,
              color: value ? null : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: value ? Colors.white : const Color(0xFF94A3B8),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.billFieldAutoPay,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'ব্যাংক বা বিকাশ থেকে স্বয়ংক্রিয় পরিশোধ',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }
}