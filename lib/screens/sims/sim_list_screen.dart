import 'package:flutter/material.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/sim_card.dart';
import '../../services/sim_service.dart';
import '../../widgets/empty_state.dart';
import 'sim_edit_screen.dart';

enum _SimFilter { all, attention, active }

/// Full Recharge Bondhu module: family SIM cards with
/// executive telecom hero card, segmented filter tabs, carrier branding,
/// balance & expiry indicators, and quick recharge action.
class SimListScreen extends StatefulWidget {
  const SimListScreen({super.key, required this.simService});

  final SimService simService;

  @override
  State<SimListScreen> createState() => _SimListScreenState();
}

class _SimListScreenState extends State<SimListScreen> {
  _SimFilter _filter = _SimFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          l10n.simListTitle,
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
              color: const Color(0xFF0D9488).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _openEditor(context, null),
          backgroundColor: const Color(0xFF0D9488),
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
        animation: widget.simService.repository as Listenable,
        builder: (context, _) {
          final all = widget.simService.getAll();
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.sim_card_outlined,
              title: l10n.simListEmptyTitle,
              message: l10n.simListEmptyBody,
            );
          }
          final attention = all
              .where((s) =>
                  s.status == SimStatus.needsRecharge ||
                  s.status == SimStatus.packageExpiringSoon ||
                  s.status == SimStatus.dataLow)
              .toList();
          final active = all.where((s) => s.status == SimStatus.active).toList();

          List<SimCard> displayed;
          switch (_filter) {
            case _SimFilter.all:
              displayed = all;
              break;
            case _SimFilter.attention:
              displayed = attention;
              break;
            case _SimFilter.active:
              displayed = active;
              break;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              _SummaryCard(
                totalCount: all.length,
                attentionCount: attention.length,
              ),
              const SizedBox(height: 16),
              _buildFilterBar(
                allCount: all.length,
                attentionCount: attention.length,
                activeCount: active.length,
              ),
              const SizedBox(height: 16),
              if (_filter == _SimFilter.all) ...[
                if (attention.isNotEmpty) ...[
                  _SectionLabel(
                    label: l10n.simSectionAttention,
                    accent: const Color(0xFFEF4444),
                    count: attention.length,
                  ),
                  const SizedBox(height: 10),
                  ...attention.map((s) => _SimCard(
                        sim: s,
                        onTap: () => _openEditor(context, s),
                        onRecharged: () => _markRecharged(context, s),
                        onDelete: () => _confirmDelete(context, s),
                      )),
                  const SizedBox(height: 16),
                ],
                if (active.isNotEmpty) ...[
                  _SectionLabel(
                    label: l10n.simSectionActive,
                    accent: const Color(0xFF0D9488),
                    count: active.length,
                  ),
                  const SizedBox(height: 10),
                  ...active.map((s) => _SimCard(
                        sim: s,
                        onTap: () => _openEditor(context, s),
                        onRecharged: () => _markRecharged(context, s),
                        onDelete: () => _confirmDelete(context, s),
                      )),
                ],
              ] else ...[
                if (displayed.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Text(
                      'এই ফিল্টারে কোনো সিম কার্ড নেই',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  ...displayed.map((s) => _SimCard(
                        sim: s,
                        onTap: () => _openEditor(context, s),
                        onRecharged: () => _markRecharged(context, s),
                        onDelete: () => _confirmDelete(context, s),
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
    required int attentionCount,
    required int activeCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _filterPill(_SimFilter.all, 'সকল ($allCount)'),
          _filterPill(_SimFilter.attention, 'জরুরি ($attentionCount)'),
          _filterPill(_SimFilter.active, 'সক্রিয় ($activeCount)'),
        ],
      ),
    );
  }

  Widget _filterPill(_SimFilter filter, String label) {
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

  void _openEditor(BuildContext context, SimCard? sim) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SimEditScreen(
          simService: widget.simService,
          existing: sim,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _markRecharged(BuildContext context, SimCard sim) async {
    final today = DateTime.now();
    final updated = sim.copyWith(lastRechargeDate: today);
    await widget.simService.update(updated);
  }

  Future<void> _confirmDelete(BuildContext context, SimCard sim) async {
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
      await widget.simService.delete(sim.id);
    }
  }
}

/// Executive telecom hero summary card.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalCount,
    required this.attentionCount,
  });

  final int totalCount;
  final int attentionCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasAttention = attentionCount > 0;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF134E4A), Color(0xFF0F766E)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x200F766E),
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
                      l10n.simListTotalLabel,
                      style: const TextStyle(
                        color: Color(0xFF99F6E4),
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.signal_cellular_alt_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'টেলিকম সহকারী',
                            style: TextStyle(
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
                      '$totalCount',
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
                        'টি পরিবারের সিম কার্ড সক্রিয়',
                        style: TextStyle(
                          color: Color(0xFFCCFBF1),
                          fontSize: 13.5,
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
                        hasAttention
                            ? Icons.warning_amber_rounded
                            : Icons.verified_rounded,
                        size: 16,
                        color: hasAttention
                            ? const Color(0xFFFDE047)
                            : const Color(0xFF86EFAC),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasAttention
                            ? l10n.simListAttentionCount(attentionCount)
                            : 'সকল সিম কার্ডের মেয়াদ সঠিক আছে',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasAttention)
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
                      'রিচার্জ প্রয়োজন',
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

class _SimCard extends StatelessWidget {
  const _SimCard({
    required this.sim,
    required this.onTap,
    required this.onRecharged,
    required this.onDelete,
  });

  final SimCard sim;
  final VoidCallback onTap;
  final VoidCallback onRecharged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final carrierColor = sim.carrier.color;
    final statusColor = _statusColor(sim.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: sim.status == SimStatus.active
              ? const Color(0xFFE8EEF2)
              : const Color(0xFFFECACA),
          width: sim.status == SimStatus.active ? 1 : 1.4,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: carrierColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.sim_card_rounded,
                        color: carrierColor,
                        size: 24,
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
                                  sim.memberName,
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
                                  color: carrierColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _carrierLabel(l10n, sim.carrier),
                                  style: TextStyle(
                                    color: carrierColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sim.number,
                            style: const TextStyle(
                              color: AppColors.inkMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusLabel(l10n, sim.status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _chips(context, l10n),
                ),
                if (sim.note != null && sim.note!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    sim.note!,
                    style: const TextStyle(
                      color: AppColors.inkMuted,
                      fontSize: 11.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onRecharged,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFA7F3D0),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 16,
                                color: Color(0xFF059669),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'রিচার্জ সম্পন্ন হয়েছে',
                                style: TextStyle(
                                  color: Color(0xFF065F46),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _chips(BuildContext context, AppLocalizations l10n) {
    final out = <Widget>[];
    final now = DateTime.now();

    if (sim.lastRechargeDate != null) {
      final daysSince = now.difference(sim.lastRechargeDate!).inDays;
      final daysLeft = sim.validityDays - daysSince;
      final isExpiring = daysLeft <= 3;
      out.add(_chip(
        label: daysLeft > 0 ? '$daysLeft দিন মেয়াদ বাকি' : 'মেয়াদ শেষ!',
        icon: Icons.access_time_rounded,
        color: isExpiring ? const Color(0xFFDC2626) : const Color(0xFF475569),
        bgColor: isExpiring ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
      ));
    }

    if (sim.rechargeAmount > 0) {
      out.add(_chip(
        label: '৳${sim.rechargeAmount.toStringAsFixed(0)}',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF0F766E),
        bgColor: const Color(0xFFF0FDFA),
      ));
    }

    if (sim.dataBalanceGb != null) {
      out.add(_chip(
        label: '${sim.dataBalanceGb} GB ডেটা',
        icon: Icons.wifi_rounded,
        color: const Color(0xFF4338CA),
        bgColor: const Color(0xFFEEF2FF),
      ));
    }

    return out;
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static Color _statusColor(SimStatus s) {
    switch (s) {
      case SimStatus.active:
        return const Color(0xFF059669);
      case SimStatus.packageExpiringSoon:
        return const Color(0xFFD97706);
      case SimStatus.needsRecharge:
        return const Color(0xFFDC2626);
      case SimStatus.dataLow:
        return const Color(0xFF7C3AED);
    }
  }

  static String _statusLabel(AppLocalizations l10n, SimStatus s) {
    switch (s) {
      case SimStatus.active:
        return l10n.simStatusActive;
      case SimStatus.packageExpiringSoon:
        return l10n.simStatusPackageExpiringSoon;
      case SimStatus.needsRecharge:
        return l10n.simStatusNeedsRecharge;
      case SimStatus.dataLow:
        return l10n.simStatusDataLow;
    }
  }

  static String _carrierLabel(AppLocalizations l10n, SimCarrier c) {
    switch (c) {
      case SimCarrier.grameenphone:
        return l10n.simCarrierGrameenphone;
      case SimCarrier.robi:
        return l10n.simCarrierRobi;
      case SimCarrier.banglalink:
        return l10n.simCarrierBanglalink;
      case SimCarrier.teletalk:
        return l10n.simCarrierTeletalk;
      case SimCarrier.airtel:
        return l10n.simCarrierAirtel;
      case SimCarrier.other:
        return l10n.simCarrierOther;
    }
  }
}