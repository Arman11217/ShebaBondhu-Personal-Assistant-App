import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/medicine.dart';
import '../../services/medicine_service.dart';
import '../../widgets/forms/bangla_text_field.dart';
import '../../widgets/forms/date_field_bn.dart';

/// Production-grade Add/Edit screen for Medicine: hero medicine card,
/// family member selector, dosage, frequency & time slot chips, stock presets.
class MedicineEditScreen extends StatefulWidget {
  const MedicineEditScreen({
    super.key,
    required this.medicineService,
    this.existing,
    this.medicineId,
  });

  final MedicineService medicineService;
  final Medicine? existing;
  final String? medicineId;

  @override
  State<MedicineEditScreen> createState() => _MedicineEditScreenState();
}

class _MedicineEditScreenState extends State<MedicineEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _member;
  late final TextEditingController _dose;
  late final TextEditingController _remaining;
  late final TextEditingController _note;
  late MedicineFrequency _frequency;
  late Set<MedicineSlot> _slots;
  DateTime? _startDate;
  DateTime? _endDate;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing =>
      (widget.existing != null && widget.existing!.id.isNotEmpty) ||
      widget.medicineId != null;

  @override
  void initState() {
    super.initState();
    Medicine? m = widget.existing;
    if (m == null && widget.medicineId != null) {
      m = widget.medicineService.getById(widget.medicineId!);
    }
    _name = TextEditingController(text: m?.name ?? '');
    _member = TextEditingController(text: m?.forMember ?? '');
    _dose = TextEditingController(text: m?.dose ?? '');
    _remaining = TextEditingController(
      text: m == null ? '' : m.remainingUnits.toString(),
    );
    _note = TextEditingController(text: m?.note ?? '');
    _frequency = m?.frequency ?? MedicineFrequency.twiceDaily;
    _slots = m == null
        ? _frequency.defaultSlots.toSet()
        : m.slots.toSet();
    _startDate = m?.startDate ?? DateTime.now();
    _endDate = m?.endDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _member.dispose();
    _dose.dispose();
    _remaining.dispose();
    _note.dispose();
    super.dispose();
  }

  void _addStock(int delta) {
    final current = int.tryParse(_remaining.text.trim()) ?? 0;
    _remaining.text = (current + delta).toString();
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final remaining = int.tryParse(_remaining.text.trim()) ?? 0;
    if (remaining < 0) return;
    final daysPerDose = _frequency == MedicineFrequency.asNeeded
        ? 0
        : _frequency.defaultSlots.length.clamp(1, 99);
    final estimatedDays = daysPerDose == 0
        ? remaining
        : (remaining / daysPerDose).ceil();
    final id = _isEditing
        ? (widget.existing?.id ?? widget.medicineId!)
        : 'med${DateTime.now().millisecondsSinceEpoch}';
    final med = Medicine(
      id: id,
      name: _name.text.trim(),
      forMember: _member.text.trim(),
      dose: _dose.text.trim(),
      frequency: _frequency,
      slots: _frequency == MedicineFrequency.asNeeded
          ? const []
          : _slots.toList(),
      startDate: _startDate,
      endDate: _endDate,
      remainingUnits: remaining,
      estimatedDaysRemaining: estimatedDays,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );
    if (_isEditing) {
      await widget.medicineService.update(med);
    } else {
      await widget.medicineService.add(med);
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
          _isEditing ? l10n.medEditTitle : l10n.medAddTitle,
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
              child: const Text(
                'সংরক্ষণ',
                style: TextStyle(
                  color: Color(0xFFE11D48),
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
                  color: const Color(0xFFE11D48).withValues(alpha: 0.3),
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
                backgroundColor: const Color(0xFFE11D48),
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
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // Medicine Basic Info Card
              _buildBasicCard(l10n),
              const SizedBox(height: 20),

              // Frequency & Timing Slots
              _buildTimingCard(l10n),
              const SizedBox(height: 20),

              // Stock & Units Card
              _buildStockCard(l10n),
              const SizedBox(height: 20),

              // Additional Note Card
              _buildNotesCard(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicCard(AppLocalizations l10n) {
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
            'ওষুধ ও সেবনকারীর তথ্য',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          BanglaTextField(
            controller: _name,
            label: l10n.medFieldName,
            hint: l10n.medFieldNameHint,
            required: true,
            prefixIcon: Icons.medication_rounded,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          BanglaTextField(
            controller: _member,
            label: l10n.medFieldMember,
            hint: l10n.medFieldMemberHint,
            required: true,
            prefixIcon: Icons.person_rounded,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _memberPreset('নিজে'),
                _memberPreset('বাবা'),
                _memberPreset('মা'),
                _memberPreset('স্ত্রী'),
                _memberPreset('স্বামী'),
                _memberPreset('সন্তান'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          BanglaTextField(
            controller: _dose,
            label: l10n.medFieldDose,
            hint: l10n.medFieldDoseHint,
            required: true,
            prefixIcon: Icons.colorize_rounded,
          ),
        ],
      ),
    );
  }

  Widget _memberPreset(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _member.text = text),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimingCard(AppLocalizations l10n) {
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
            'সেবনের সময়সূচি ও নিয়ম',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          _FrequencySelector(
            value: _frequency,
            onChanged: (f) => setState(() {
              _frequency = f;
              if (_frequency == MedicineFrequency.asNeeded) {
                _slots = {};
              } else {
                _slots = f.defaultSlots.toSet();
              }
            }),
          ),
          if (_frequency != MedicineFrequency.asNeeded) ...[
            const SizedBox(height: 16),
            _SlotMultiSelector(
              selected: _slots,
              onToggle: (slot) => setState(() {
                if (_slots.contains(slot)) {
                  _slots.remove(slot);
                } else {
                  _slots.add(slot);
                }
              }),
            ),
          ],
          const SizedBox(height: 16),
          DateFieldBn(
            label: l10n.medFieldStartDate,
            value: _startDate,
            onChanged: (d) => setState(() => _startDate = d),
          ),
          const SizedBox(height: 12),
          DateFieldBn(
            label: l10n.medFieldEndDate,
            value: _endDate,
            onChanged: (d) => setState(() => _endDate = d),
            onCleared: () => setState(() => _endDate = null),
            allowClear: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(AppLocalizations l10n) {
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
            'স্টকে থাকা ওষুধের পরিমাণ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          BanglaTextField(
            controller: _remaining,
            label: l10n.medFieldRemaining,
            hint: l10n.medFieldRemainingHint,
            required: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icons.inventory_2_rounded,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _stockPreset('+৫', 5),
              _stockPreset('+১০', 10),
              _stockPreset('+১৫', 15),
              _stockPreset('+২০', 20),
              _stockPreset('+৩০', 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stockPreset(String label, int delta) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _addStock(delta),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
        ),
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
            'ডাক্তারের পরামর্শ বা নোট (ঐচ্ছিক)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          BanglaTextField(
            controller: _note,
            label: l10n.medFieldNote,
            hint: l10n.medFieldNoteHint,
            prefixIcon: Icons.notes_rounded,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class _FrequencySelector extends StatelessWidget {
  const _FrequencySelector({required this.value, required this.onChanged});
  final MedicineFrequency value;
  final ValueChanged<MedicineFrequency> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <(MedicineFrequency, String)>[
      (MedicineFrequency.onceDaily, l10n.medFrequencyOnceDaily),
      (MedicineFrequency.twiceDaily, l10n.medFrequencyTwiceDaily),
      (MedicineFrequency.thriceDaily, l10n.medFrequencyThriceDaily),
      (MedicineFrequency.fourTimesDaily, l10n.medFrequencyFourTimesDaily),
      (MedicineFrequency.weekly, l10n.medFrequencyWeekly),
      (MedicineFrequency.asNeeded, l10n.medFrequencyAsNeeded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medFieldFrequency,
          style: const TextStyle(
            color: AppColors.inkMuted,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((it) => _ChoiceChip(
                    label: it.$2,
                    selected: it.$1 == value,
                    onTap: () => onChanged(it.$1),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _SlotMultiSelector extends StatelessWidget {
  const _SlotMultiSelector({
    required this.selected,
    required this.onToggle,
  });

  final Set<MedicineSlot> selected;
  final ValueChanged<MedicineSlot> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <(MedicineSlot, String, IconData)>[
      (MedicineSlot.morning, l10n.medSlotMorning, Icons.wb_sunny_rounded),
      (MedicineSlot.afternoon, l10n.medSlotAfternoon, Icons.light_mode_rounded),
      (MedicineSlot.evening, l10n.medSlotEvening, Icons.wb_twilight_rounded),
      (MedicineSlot.night, l10n.medSlotNight, Icons.nightlight_round),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medFieldSlots,
          style: const TextStyle(
            color: AppColors.inkMuted,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((it) => _SlotChip(
                    label: it.$2,
                    icon: it.$3,
                    selected: selected.contains(it.$1),
                    onTap: () => onToggle(it.$1),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFFF1F2)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFFE11D48)
                : const Color(0xFFE2E8F0),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFFBE123C) : AppColors.ink,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFECFDF5)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? const Color(0xFF10B981)
                : const Color(0xFFE2E8F0),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected
                  ? const Color(0xFF059669)
                  : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF065F46)
                    : AppColors.ink,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}