import 'package:flutter/material.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/identity_document.dart';
import '../../services/document_service.dart';
import '../../widgets/forms/bangla_text_field.dart';
import '../../widgets/forms/date_field_bn.dart';

/// Production-grade Add/Edit form for Identity Documents: type selector grid,
/// document title & number inputs, issue & expiry dates with duration presets.
class DocumentEditScreen extends StatefulWidget {
  const DocumentEditScreen({
    super.key,
    required this.documentService,
    this.existing,
    this.documentId,
  });

  final DocumentService documentService;
  final IdentityDocument? existing;
  final String? documentId;

  @override
  State<DocumentEditScreen> createState() => _DocumentEditScreenState();
}

class _DocumentEditScreenState extends State<DocumentEditScreen> {
  late final TextEditingController _label;
  late final TextEditingController _number;
  late final TextEditingController _issuer;
  late final TextEditingController _note;
  late DocumentType _type;
  late DateTime _expiryDate;
  DateTime? _issueDate;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing =>
      (widget.existing != null && widget.existing!.id.isNotEmpty) ||
      widget.documentId != null;

  @override
  void initState() {
    super.initState();
    IdentityDocument? d = widget.existing;
    if (d == null && widget.documentId != null) {
      d = widget.documentService.getById(widget.documentId!);
    }
    _label = TextEditingController(text: d?.label ?? '');
    _number = TextEditingController(text: d?.number ?? '');
    _issuer = TextEditingController(text: d?.issuer ?? '');
    _note = TextEditingController(text: d?.note ?? '');
    _type = d?.type ?? DocumentType.nid;
    _expiryDate = d?.expiryDate ?? _defaultExpiry();
    _issueDate = d?.issueDate;
  }

  static DateTime _defaultExpiry() {
    final today = DateTime.now();
    return DateTime(today.year + 5, today.month, today.day);
  }

  @override
  void dispose() {
    _label.dispose();
    _number.dispose();
    _issuer.dispose();
    _note.dispose();
    super.dispose();
  }

  void _setExpiryFromNow(int years) {
    final now = DateTime.now();
    _expiryDate = DateTime(now.year + years, now.month, now.day);
    setState(() {});
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final id = _isEditing
        ? (widget.existing?.id ?? widget.documentId!)
        : 'doc-${DateTime.now().microsecondsSinceEpoch}';
    final doc = IdentityDocument(
      id: id,
      type: _type,
      label: _label.text.trim(),
      number: _number.text.trim().isEmpty ? null : _number.text.trim(),
      issuer: _issuer.text.trim().isEmpty ? null : _issuer.text.trim(),
      issueDate: _issueDate,
      expiryDate: _expiryDate,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );
    if (_isEditing) {
      await widget.documentService.update(doc);
    } else {
      await widget.documentService.add(doc);
    }
    if (mounted) Navigator.of(context).pop();
  }

  String _labelFor(BuildContext context, DocumentType t) {
    final l10n = AppLocalizations.of(context);
    switch (t) {
      case DocumentType.nid:
        return l10n.docTypeNid;
      case DocumentType.passport:
        return l10n.docTypePassport;
      case DocumentType.drivingLicense:
        return l10n.docTypeDrivingLicense;
      case DocumentType.vehicleFitness:
        return l10n.docTypeVehicleFitness;
      case DocumentType.tradeLicense:
        return l10n.docTypeTradeLicense;
      case DocumentType.bankCard:
        return l10n.docTypeBankCard;
      case DocumentType.insurance:
        return l10n.docTypeInsurance;
      case DocumentType.certificate:
        return l10n.docTypeCertificate;
      case DocumentType.other:
        return l10n.docTypeOther;
    }
  }

  IconData _iconFor(DocumentType t) {
    switch (t) {
      case DocumentType.nid:
        return Icons.badge_rounded;
      case DocumentType.passport:
        return Icons.menu_book_rounded;
      case DocumentType.drivingLicense:
        return Icons.directions_car_rounded;
      case DocumentType.vehicleFitness:
        return Icons.local_taxi_rounded;
      case DocumentType.tradeLicense:
        return Icons.storefront_rounded;
      case DocumentType.bankCard:
        return Icons.credit_card_rounded;
      case DocumentType.insurance:
        return Icons.health_and_safety_rounded;
      case DocumentType.certificate:
        return Icons.workspace_premium_rounded;
      case DocumentType.other:
        return Icons.description_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final types = DocumentType.values;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.docsEditTitle : l10n.docsAddTitle,
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
                  color: Color(0xFF7C3AED),
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
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
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
                backgroundColor: const Color(0xFF7C3AED),
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
              // Document Type Selector Grid
              _buildTypeGridCard(types),
              const SizedBox(height: 20),

              // Details Card (Label, Number, Issuer)
              _buildDetailsCard(l10n),
              const SizedBox(height: 20),

              // Expiry & Dates Card
              _buildDatesCard(l10n),
              const SizedBox(height: 20),

              // Notes Card
              _buildNotesCard(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeGridCard(List<DocumentType> types) {
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
            'নথির ধরন নির্বাচন করুন',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          _TypeGrid(
            types: types,
            selected: _type,
            labelFor: (t) => _labelFor(context, t),
            iconFor: _iconFor,
            onChanged: (t) => setState(() => _type = t),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(AppLocalizations l10n) {
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
            'নথির নাম ও নম্বর',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          BanglaTextField(
            controller: _label,
            label: l10n.docsFieldLabel,
            hint: l10n.docsFieldLabelHint,
            required: true,
            prefixIcon: Icons.badge_rounded,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          BanglaTextField(
            controller: _number,
            label: l10n.docsFieldNumber,
            hint: l10n.docsFieldNumberHint,
            prefixIcon: Icons.pin_rounded,
          ),
          const SizedBox(height: 14),
          BanglaTextField(
            controller: _issuer,
            label: l10n.docsFieldIssuer,
            hint: l10n.docsFieldIssuerHint,
            prefixIcon: Icons.account_balance_rounded,
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  Widget _buildDatesCard(AppLocalizations l10n) {
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
            'ইস্যু ও মেয়াদের তারিখ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          DateFieldBn(
            label: l10n.docsFieldIssueDate,
            value: _issueDate,
            onChanged: (d) => setState(() => _issueDate = d),
          ),
          const SizedBox(height: 14),
          DateFieldBn(
            label: l10n.docsFieldExpiryDate,
            value: _expiryDate,
            onChanged: (d) => setState(() => _expiryDate = d),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _durationChip('+১ বছর', 1),
                _durationChip('+২ বছর', 2),
                _durationChip('+৫ বছর', 5),
                _durationChip('+১০ বছর', 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _durationChip(String text, int years) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => _setExpiryFromNow(years),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            text,
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
            'অতিরিক্ত নোট (ঐচ্ছিক)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),
          BanglaTextField(
            controller: _note,
            label: l10n.docsFieldNote,
            hint: l10n.docsFieldNoteHint,
            prefixIcon: Icons.notes_rounded,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class _TypeGrid extends StatelessWidget {
  const _TypeGrid({
    required this.types,
    required this.selected,
    required this.labelFor,
    required this.iconFor,
    required this.onChanged,
  });

  final List<DocumentType> types;
  final DocumentType selected;
  final String Function(DocumentType) labelFor;
  final IconData Function(DocumentType) iconFor;
  final ValueChanged<DocumentType> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 8.0;
        final cols = 3;
        final itemWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: types
              .map((t) => SizedBox(
                    width: itemWidth,
                    child: _TypeChip(
                      label: labelFor(t),
                      icon: iconFor(t),
                      active: t == selected,
                      onTap: () => onChanged(t),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFF5F3FF)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? const Color(0xFF7C3AED)
                : const Color(0xFFE2E8F0),
            width: active ? 1.6 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: active ? const Color(0xFF7C3AED) : const Color(0xFF64748B),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: active ? const Color(0xFF6D28D9) : AppColors.ink,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}