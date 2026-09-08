import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/sim_card.dart';
import '../../services/sim_service.dart';
import '../../widgets/forms/amount_field.dart';
import '../../widgets/forms/bangla_text_field.dart';
import '../../widgets/forms/date_field_bn.dart';

/// Form to create or edit a family SIM card: carrier selector, member & number
/// input cards, package validity presets, recharge amount & data balance.
class SimEditScreen extends StatefulWidget {
  const SimEditScreen({
    super.key,
    required this.simService,
    this.existing,
  });

  final SimService simService;
  final SimCard? existing;

  @override
  State<SimEditScreen> createState() => _SimEditScreenState();
}

class _SimEditScreenState extends State<SimEditScreen> {
  late final TextEditingController _memberC;
  late final TextEditingController _numberC;
  late final TextEditingController _validityC;
  late final TextEditingController _amountC;
  late final TextEditingController _dataC;
  late final TextEditingController _noteC;

  SimCarrier _carrier = SimCarrier.grameenphone;
  DateTime? _lastRecharge;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _memberC = TextEditingController(text: e?.memberName ?? '');
    _numberC = TextEditingController(text: e?.number ?? '');
    _validityC = TextEditingController(
      text: e != null ? e.validityDays.toString() : '30',
    );
    _amountC = TextEditingController(
      text: e != null && e.rechargeAmount > 0
          ? e.rechargeAmount.toStringAsFixed(0)
          : '',
    );
    _dataC = TextEditingController(
      text: e != null && e.dataBalanceGb != null
          ? e.dataBalanceGb.toString()
          : '',
    );
    _noteC = TextEditingController(text: e?.note ?? '');
    _carrier = e?.carrier ?? SimCarrier.grameenphone;
    _lastRecharge = e?.lastRechargeDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _memberC.dispose();
    _numberC.dispose();
    _validityC.dispose();
    _amountC.dispose();
    _dataC.dispose();
    _noteC.dispose();
    super.dispose();
  }

  bool get _isEditing =>
      widget.existing != null && widget.existing!.id.isNotEmpty;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final validity = int.tryParse(_validityC.text.trim()) ?? 30;
    final amount = double.tryParse(_amountC.text.trim()) ?? 0;
    final data = double.tryParse(_dataC.text.trim());

    final card = SimCard(
      id: _isEditing
          ? widget.existing!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      memberName: _memberC.text.trim(),
      carrier: _carrier,
      number: _numberC.text.trim(),
      lastRechargeDate: _lastRecharge,
      rechargeAmount: amount,
      validityDays: validity,
      dataBalanceGb: data,
      note: _noteC.text.trim().isEmpty ? null : _noteC.text.trim(),
      status: widget.existing?.status ?? SimStatus.active,
    );

    if (_isEditing) {
      await widget.simService.update(card);
    } else {
      await widget.simService.add(card);
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
          _isEditing ? l10n.simEditTitle : l10n.simAddTitle,
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
                  await widget.simService.delete(existing.id);
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
                  color: Color(0xFF0D9488),
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
                  color: const Color(0xFF0D9488).withValues(alpha: 0.3),
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
                backgroundColor: const Color(0xFF0D9488),
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
            // Carrier Selector Card
            _buildCarrierCard(l10n),
            const SizedBox(height: 20),

            // Member & Phone Number Card
            _buildMemberCard(l10n),
            const SizedBox(height: 20),

            // Recharge & Validity Card
            _buildRechargeCard(l10n),
            const SizedBox(height: 20),

            // Notes Card
            _buildNotesCard(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildCarrierCard(AppLocalizations l10n) {
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
            'অপারেটর নির্বাচন করুন',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SimCarrier.values.map((c) {
              final selected = _carrier == c;
              final color = c.color;
              return GestureDetector(
                onTap: () => setState(() => _carrier = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _carrierLabel(l10n, c),
                        style: TextStyle(
                          color: selected ? color : AppColors.ink,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(AppLocalizations l10n) {
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
            'সিম ব্যবহারকারীর তথ্য',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          BanglaTextField(
            controller: _memberC,
            label: l10n.simFieldMember,
            hint: l10n.simFieldMemberHint,
            required: true,
            prefixIcon: Icons.person_rounded,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          BanglaTextField(
            controller: _numberC,
            label: l10n.simFieldNumber,
            hint: l10n.simFieldNumberHint,
            required: true,
            prefixIcon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-]')),
            ],
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }

  Widget _buildRechargeCard(AppLocalizations l10n) {
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
            'প্যাকেজ ও মেয়াদের তথ্য',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: BanglaTextField(
                  controller: _validityC,
                  label: l10n.simFieldValidityDays,
                  hint: '30',
                  required: true,
                  prefixIcon: Icons.access_time_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BanglaTextField(
                  controller: _dataC,
                  label: l10n.simFieldDataBalance,
                  prefixIcon: Icons.wifi_rounded,
                  hint: '0.0 GB',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
                  ],
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _validityPreset('৭ দিন', 7),
                _validityPreset('১৫ দিন', 15),
                _validityPreset('৩০ দিন', 30),
                _validityPreset('৬০ দিন', 60),
                _validityPreset('৯০ দিন', 90),
              ],
            ),
          ),
          const SizedBox(height: 14),
          DateFieldBn(
            label: l10n.simFieldLastRecharge,
            value: _lastRecharge,
            onChanged: (d) => setState(() => _lastRecharge = d),
          ),
          const SizedBox(height: 14),
          AmountField(
            controller: _amountC,
            label: l10n.simFieldRechargeAmount,
            currencyPrefix: '\u09F3',
            hint: '199',
            onChanged: (_) {},
            validator: (_) => null,
          ),
        ],
      ),
    );
  }

  Widget _validityPreset(String text, int days) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _validityC.text = days.toString()),
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
            'অতিরিক্ত নোট (ঐচ্ছিক)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          BanglaTextField(
            controller: _noteC,
            label: l10n.simFieldNote,
            hint: l10n.simFieldNoteHint,
            prefixIcon: Icons.notes_rounded,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
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
