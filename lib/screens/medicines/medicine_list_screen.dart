import 'package:flutter/material.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/medicine.dart';
import '../../services/medicine_service.dart';
import '../../widgets/empty_state.dart';
import 'medicine_edit_screen.dart';

enum _MedFilter { all, lowStock, healthy }

/// Full Medicine Bondhu module: family medicine stock grouped with
/// executive health hero card, interactive filters, modern medical cards,
/// slot chips, and urgency badges.
class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key, required this.medicineService});

  final MedicineService medicineService;

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  _MedFilter _filter = _MedFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          l10n.medListTitle,
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
              color: const Color(0xFFE11D48).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _openEditor(context, null),
          backgroundColor: const Color(0xFFE11D48),
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          icon: const Icon(Icons.add_rounded, size: 22),
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
      body: AnimatedBuilder(
        animation: widget.medicineService.repository as Listenable,
        builder: (context, _) {
          final all = widget.medicineService.getAll();
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.medical_services_outlined,
              title: l10n.medListEmptyTitle,
              message: l10n.medListEmptyBody,
            );
          }
          final lowStock = all
              .where((m) => m.estimatedDaysRemaining <= 5)
              .toList();
          final healthy = all
              .where((m) => m.estimatedDaysRemaining > 5)
              .toList();
          final totalUnits = all.fold<int>(0, (s, m) => s + m.remainingUnits);

          List<Medicine> displayed;
          switch (_filter) {
            case _MedFilter.all:
              displayed = all;
              break;
            case _MedFilter.lowStock:
              displayed = lowStock;
              break;
            case _MedFilter.healthy:
              displayed = healthy;
              break;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              _SummaryCard(
                totalUnits: totalUnits,
                lowCount: lowStock.length,
                totalCount: all.length,
              ),
              const SizedBox(height: 16),
              _buildFilterBar(
                allCount: all.length,
                lowCount: lowStock.length,
                healthyCount: healthy.length,
              ),
              const SizedBox(height: 16),
              if (_filter == _MedFilter.all) ...[
                if (lowStock.isNotEmpty) ...[
                  _SectionLabel(
                    label: l10n.medSectionLowStock,
                    accent: const Color(0xFFE11D48),
                    count: lowStock.length,
                  ),
                  const SizedBox(height: 10),
                  ...lowStock.map((m) => _MedicineCard(
                        medicine: m,
                        onTap: () => _openEditor(context, m),
                        onDelete: () => _confirmDelete(context, m),
                      )),
                  const SizedBox(height: 16),
                ],
                if (healthy.isNotEmpty) ...[
                  _SectionLabel(
                    label: l10n.medSectionActive,
                    accent: AppColors.brandGreen,
                    count: healthy.length,
                  ),
                  const SizedBox(height: 10),
                  ...healthy.map((m) => _MedicineCard(
                        medicine: m,
                        onTap: () => _openEditor(context, m),
                        onDelete: () => _confirmDelete(context, m),
                      )),
                ],
              ] else ...[
                if (displayed.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Text(
                      'এই ফিল্টারে কোনো ওষুধ নেই',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  ...displayed.map((m) => _MedicineCard(
                        medicine: m,
                        onTap: () => _openEditor(context, m),
                        onDelete: () => _confirmDelete(context, m),
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
    required int lowCount,
    required int healthyCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _filterPill(_MedFilter.all, 'সকল ($allCount)'),
          _filterPill(_MedFilter.lowStock, 'স্টক কম ($lowCount)'),
          _filterPill(_MedFilter.healthy, 'পর্যাপ্ত ($healthyCount)'),
        ],
      ),
    );
  }

  Widget _filterPill(_MedFilter filter, String label) {
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

  void _openEditor(BuildContext context, Medicine? med) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineEditScreen(
          medicineService: widget.medicineService,
          existing: med,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Medicine m) async {
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
      await widget.medicineService.delete(m.id);
    }
  }
}

/// Header summary card: total units in stock + low-stock mini-stat.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalUnits,
    required this.lowCount,
    required this.totalCount,
  });

  final int totalUnits;
  final int lowCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF881337), Color(0xFFBE123C)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20BE123C),
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
                    Text(
                      l10n.medListTotalLabel,
                      style: const TextStyle(
                        color: Color(0xFFFDA4AF),
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
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.medication_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'মোট ওষুধ: $totalCountটি',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$totalUnits',
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
                        'ইউনিট ওষুধ স্টকে রয়েছে',
                        style: TextStyle(
                          color: Color(0xFFFECDD3),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        lowCount > 0
                            ? Icons.warning_amber_rounded
                            : Icons.health_and_safety_rounded,
                        size: 16,
                        color: lowCount > 0
                            ? const Color(0xFFFDE047)
                            : const Color(0xFF86EFAC),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.medListLowStockCount(lowCount, totalCount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (lowCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFDA4AF).withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text(
                      'রিফিল প্রয়োজন',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
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
    required this.accent,
    this.count,
  });
  final String label;
  final Color accent;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: accent,
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
        if (count != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: accent,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({
    required this.medicine,
    required this.onTap,
    required this.onDelete,
  });

  final Medicine medicine;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLow = medicine.estimatedDaysRemaining <= 5;
    final badgeColor = isLow ? const Color(0xFFDC2626) : AppColors.brandGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLow
              ? const Color(0xFFFECACA)
              : const Color(0xFFE8EEF2),
          width: isLow ? 1.4 : 1,
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
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLow
                          ? [const Color(0xFFF43F5E), const Color(0xFFBE123C)]
                          : [const Color(0xFF10B981), const Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.medication_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              medicine.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              medicine.dose,
                              style: const TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            medicine.forMember,
                            style: const TextStyle(
                              color: AppColors.inkMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 10)),
                          ),
                          Text(
                            l10n.medUnitsLeft(medicine.remainingUnits),
                            style: const TextStyle(
                              color: AppColors.inkMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (medicine.slots.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: medicine.slots
                              .map((s) => _SlotChip(slot: s))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          l10n.medStockBadge(medicine.estimatedDaysRemaining),
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({required this.slot});
  final MedicineSlot slot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        _slotLabel(slot),
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _slotLabel(MedicineSlot s) {
    switch (s) {
      case MedicineSlot.morning:
        return 'সকাল';
      case MedicineSlot.afternoon:
        return 'দুপুর';
      case MedicineSlot.evening:
        return 'সন্ধ্যা';
      case MedicineSlot.night:
        return 'রাত';
    }
  }
}
