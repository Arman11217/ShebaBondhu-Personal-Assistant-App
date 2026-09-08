import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/warranty_product.dart';
import '../../services/warranty_service.dart';
import '../../widgets/forms/bangla_text_field.dart';
import '../../widgets/forms/date_field_bn.dart';

/// Form to create a warranty product or edit an existing one.
/// Upgraded with card-based luxury fintech aesthetics and duration presets.
class WarrantyEditScreen extends StatefulWidget {
  const WarrantyEditScreen({
    super.key,
    required this.warrantyService,
    this.existing,
  });

  final WarrantyService warrantyService;
  final WarrantyProduct? existing;

  @override
  State<WarrantyEditScreen> createState() => _WarrantyEditScreenState();
}

class _WarrantyEditScreenState extends State<WarrantyEditScreen> {
  late final TextEditingController _nameC;
  late final TextEditingController _brandC;
  late final TextEditingController _vendorC;
  late final TextEditingController _priceC;
  late final TextEditingController _noteC;

  WarrantyCategory _category = WarrantyCategory.electronics;
  DateTime? _purchaseDate;
  DateTime? _expiryDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameC = TextEditingController(text: e?.productName ?? '');
    _brandC = TextEditingController(text: e?.brand ?? '');
    _vendorC = TextEditingController(text: e?.vendor ?? '');
    _priceC = TextEditingController(
      text: e != null && e.price > 0 ? e.price.toStringAsFixed(0) : '',
    );
    _noteC = TextEditingController(text: e?.note ?? '');
    _category = e?.category ?? WarrantyCategory.electronics;
    _purchaseDate = e?.purchaseDate ?? DateTime.now();
    _expiryDate = e?.expiryDate;
  }

  @override
  void dispose() {
    _nameC.dispose();
    _brandC.dispose();
    _vendorC.dispose();
    _priceC.dispose();
    _noteC.dispose();
    super.dispose();
  }

  void _addWarrantyMonths(int months) {
    final base = _purchaseDate ?? DateTime.now();
    setState(() {
      _expiryDate = DateTime(base.year, base.month + months, base.day);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_purchaseDate == null || _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অনুগ্রহ করে ওয়ারেন্টির মেয়াদ শেষ হওয়ার তারিখ নির্বাচন করুন'),
          backgroundColor: AppColors.critical,
        ),
      );
      return;
    }

    final price = double.tryParse(_priceC.text.trim()) ?? 0;

    final product = WarrantyProduct(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      productName: _nameC.text.trim(),
      brand: _brandC.text.trim(),
      category: _category,
      purchaseDate: _purchaseDate!,
      expiryDate: _expiryDate!,
      price: price,
      vendor: _vendorC.text.trim().isEmpty ? null : _vendorC.text.trim(),
      note: _noteC.text.trim().isEmpty ? null : _noteC.text.trim(),
      status: widget.existing?.status ?? WarrantyStatus.active,
    );

    if (widget.existing == null) {
      await widget.warrantyService.add(product);
    } else {
      await widget.warrantyService.update(product);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(
          widget.existing == null
              ? l10n.warrantyAddTitle
              : l10n.warrantyEditTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.ink,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E9EB)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.ink),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          if (widget.existing != null)
            IconButton(
              tooltip: l10n.commonDelete,
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.critical.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.critical),
              ),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final existing = widget.existing;
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: Text(l10n.deleteConfirmTitle),
                    content: Text(l10n.deleteConfirmBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(l10n.commonCancel),
                      ),
                      FilledButton.tonal(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              AppColors.critical.withValues(alpha: 0.12),
                          foregroundColor: AppColors.critical,
                        ),
                        child: Text(l10n.commonDelete),
                      ),
                    ],
                  ),
                );
                if (ok == true && existing != null) {
                  await widget.warrantyService.delete(existing.id);
                  if (!mounted) return;
                  navigator.pop();
                }
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _save,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.commonSave,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
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
            // Category Section Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8EEF2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.category_rounded,
                            size: 16, color: Color(0xFF0284C7)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.warrantyFieldCategory,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: WarrantyCategory.values.map((c) {
                      final selected = _category == c;
                      final color = categoryColor(c);
                      return _CategoryChip(
                        label: _categoryLabel(l10n, c),
                        icon: _categoryIcon(c),
                        color: color,
                        selected: selected,
                        onTap: () => setState(() => _category = c),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Product Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8EEF2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.inventory_2_rounded,
                            size: 16, color: Color(0xFF059669)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'পণ্যের তথ্য',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  BanglaTextField(
                    controller: _brandC,
                    label: l10n.warrantyFieldBrand,
                    hint: 'যেমন: Samsung, Walton, LG',
                    required: true,
                    prefixIcon: Icons.business_outlined,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  BanglaTextField(
                    controller: _nameC,
                    label: l10n.warrantyFieldProductName,
                    hint: l10n.warrantyFieldProductNameHint,
                    required: true,
                    prefixIcon: Icons.devices_other_outlined,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  BanglaTextField(
                    controller: _vendorC,
                    label: l10n.warrantyFieldVendor,
                    hint: l10n.warrantyFieldVendorHint,
                    prefixIcon: Icons.storefront_outlined,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  BanglaTextField(
                    controller: _priceC,
                    label: l10n.warrantyFieldPrice,
                    prefixIcon: Icons.payments_outlined,
                    hint: '০',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
                    ],
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Warranty Dates & Presets Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8EEF2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.date_range_rounded,
                            size: 16, color: Color(0xFFD97706)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'মেয়াদ ও তারিখ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DateFieldBn(
                    label: l10n.warrantyFieldPurchaseDate,
                    value: _purchaseDate,
                    onChanged: (d) => setState(() => _purchaseDate = d),
                  ),
                  const SizedBox(height: 12),
                  DateFieldBn(
                    label: l10n.warrantyFieldExpiryDate,
                    value: _expiryDate,
                    onChanged: (d) => setState(() => _expiryDate = d),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ওয়ারেন্টির মেয়াদ দ্রুত নির্বাচন:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _QuickPeriodChip(
                          label: '+৬ মাস',
                          onTap: () => _addWarrantyMonths(6),
                        ),
                        const SizedBox(width: 8),
                        _QuickPeriodChip(
                          label: '+১ বছর',
                          onTap: () => _addWarrantyMonths(12),
                        ),
                        const SizedBox(width: 8),
                        _QuickPeriodChip(
                          label: '+২ বছর',
                          onTap: () => _addWarrantyMonths(24),
                        ),
                        const SizedBox(width: 8),
                        _QuickPeriodChip(
                          label: '+৩ বছর',
                          onTap: () => _addWarrantyMonths(36),
                        ),
                        const SizedBox(width: 8),
                        _QuickPeriodChip(
                          label: '+৫ বছর',
                          onTap: () => _addWarrantyMonths(60),
                        ),
                        const SizedBox(width: 8),
                        _QuickPeriodChip(
                          label: '+১০ বছর',
                          onTap: () => _addWarrantyMonths(120),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Additional Notes Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8EEF2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.note_alt_rounded,
                            size: 16, color: Color(0xFF8B5CF6)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.warrantyFieldNote,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  BanglaTextField(
                    controller: _noteC,
                    label: l10n.warrantyFieldNote,
                    hint: l10n.warrantyFieldNoteHint,
                    prefixIcon: Icons.description_outlined,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  static IconData _categoryIcon(WarrantyCategory c) {
    switch (c) {
      case WarrantyCategory.electronics:
        return Icons.devices_rounded;
      case WarrantyCategory.appliance:
        return Icons.kitchen_rounded;
      case WarrantyCategory.furniture:
        return Icons.chair_rounded;
      case WarrantyCategory.vehicle:
        return Icons.directions_car_rounded;
      case WarrantyCategory.jewellery:
        return Icons.diamond_rounded;
      case WarrantyCategory.clothing:
        return Icons.checkroom_rounded;
      case WarrantyCategory.other:
        return Icons.category_rounded;
    }
  }

  static String _categoryLabel(AppLocalizations l10n, WarrantyCategory c) {
    switch (c) {
      case WarrantyCategory.electronics:
        return l10n.warrantyCategoryElectronics;
      case WarrantyCategory.appliance:
        return l10n.warrantyCategoryAppliance;
      case WarrantyCategory.furniture:
        return l10n.warrantyCategoryFurniture;
      case WarrantyCategory.vehicle:
        return l10n.warrantyCategoryVehicle;
      case WarrantyCategory.jewellery:
        return l10n.warrantyCategoryJewellery;
      case WarrantyCategory.clothing:
        return l10n.warrantyCategoryClothing;
      case WarrantyCategory.other:
        return l10n.warrantyCategoryOther;
    }
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.22),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickPeriodChip extends StatelessWidget {
  const _QuickPeriodChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF0284C7).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF0284C7).withValues(alpha: 0.20),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0284C7),
            ),
          ),
        ),
      ),
    );
  }
}
