import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../models/family_member.dart';
import '../../services/family_service.dart';
import '../../widgets/forms/bangla_text_field.dart';
import '../../widgets/forms/date_field_bn.dart';

/// Form to add a family member or edit an existing one.
/// Upgraded with luxury card styling, blood group grid, and relation chips.
class FamilyEditScreen extends StatefulWidget {
  const FamilyEditScreen({
    super.key,
    required this.familyService,
    this.existing,
  });

  final FamilyService familyService;
  final FamilyMember? existing;

  @override
  State<FamilyEditScreen> createState() => _FamilyEditScreenState();
}

class _FamilyEditScreenState extends State<FamilyEditScreen> {
  late final TextEditingController _nameC;
  late final TextEditingController _phoneC;
  late final TextEditingController _nidC;
  late final TextEditingController _noteC;

  FamilyRelation _relation = FamilyRelation.self;
  BloodGroup _blood = BloodGroup.unknown;
  DateTime? _birthDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameC = TextEditingController(text: e?.name ?? '');
    _phoneC = TextEditingController(text: e?.phone ?? '');
    _nidC = TextEditingController(text: e?.nid ?? '');
    _noteC = TextEditingController(text: e?.note ?? '');
    _relation = e?.relation ?? FamilyRelation.self;
    _blood = e?.bloodGroup ?? BloodGroup.unknown;
    _birthDate = e?.birthDate;
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _nidC.dispose();
    _noteC.dispose();
    super.dispose();
  }

  int? get _computedAge {
    final bd = _birthDate;
    if (bd == null) return null;
    final now = DateTime.now();
    var years = now.year - bd.year;
    final hadBirthday =
        now.month > bd.month || (now.month == bd.month && now.day >= bd.day);
    if (!hadBirthday) years--;
    return years >= 0 ? years : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final member = FamilyMember(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameC.text.trim(),
      relation: _relation,
      bloodGroup: _blood,
      phone: _phoneC.text.trim().isEmpty ? null : _phoneC.text.trim(),
      nid: _nidC.text.trim().isEmpty ? null : _nidC.text.trim(),
      birthDate: _birthDate,
      note: _noteC.text.trim().isEmpty ? null : _noteC.text.trim(),
    );

    if (widget.existing == null) {
      await widget.familyService.add(member);
    } else {
      await widget.familyService.update(member);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final age = _computedAge;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(
          widget.existing == null
              ? l10n.familyAddTitle
              : l10n.familyEditTitle,
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
                  await widget.familyService.delete(existing.id);
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
              colors: [Color(0xFF0F766E), Color(0xFF115E59)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F766E).withValues(alpha: 0.35),
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
                    const Icon(Icons.check_circle_rounded,
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
            // Relation Selection Card
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
                          color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.people_alt_rounded,
                            size: 16, color: Color(0xFF0F766E)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.familyFieldRelation,
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
                    children: FamilyRelation.values.map((r) {
                      final selected = _relation == r;
                      final color = relationColor(r);
                      return _RelationChip(
                        label: _relationLabel(l10n, r),
                        color: color,
                        selected: selected,
                        onTap: () => setState(() => _relation = r),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Personal Information Card
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
                        child: const Icon(Icons.badge_rounded,
                            size: 16, color: Color(0xFF0284C7)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ব্যক্তিগত তথ্য',
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
                    controller: _nameC,
                    label: l10n.familyFieldName,
                    hint: l10n.familyFieldNameHint,
                    required: true,
                    prefixIcon: Icons.person_outline_rounded,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  DateFieldBn(
                    label: l10n.familyFieldBirthDate,
                    value: _birthDate,
                    onChanged: (d) => setState(() => _birthDate = d),
                  ),
                  if (age != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cake_rounded,
                              size: 14, color: Color(0xFF0F766E)),
                          const SizedBox(width: 6),
                          Text(
                            'বর্তমান বয়স: ${l10n.familyAgeYears(age)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Blood Group Card
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
                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.water_drop_rounded,
                            size: 16, color: Color(0xFFDC2626)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.familyFieldBloodGroup,
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
                    children: BloodGroup.values.map((bg) {
                      final selected = _blood == bg;
                      return _BloodChip(
                        label: bg.label,
                        selected: selected,
                        onTap: () => setState(() => _blood = bg),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Contact & Identity Card
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
                        child: const Icon(Icons.contact_emergency_rounded,
                            size: 16, color: Color(0xFF059669)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'যোগাযোগ ও জাতীয় পরিচয়',
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
                    controller: _phoneC,
                    label: l10n.familyFieldPhone,
                    hint: l10n.familyFieldPhoneHint,
                    prefixIcon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-]')),
                    ],
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  BanglaTextField(
                    controller: _nidC,
                    label: l10n.familyFieldNid,
                    hint: l10n.familyFieldNidHint,
                    prefixIcon: Icons.fingerprint_rounded,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes Card
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
                        l10n.familyFieldNote,
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
                    label: l10n.familyFieldNote,
                    hint: l10n.familyFieldNoteHint,
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

  static String _relationLabel(AppLocalizations l10n, FamilyRelation r) {
    switch (r) {
      case FamilyRelation.self:
        return l10n.familyRelationSelf;
      case FamilyRelation.spouse:
        return l10n.familyRelationSpouse;
      case FamilyRelation.father:
        return l10n.familyRelationFather;
      case FamilyRelation.mother:
        return l10n.familyRelationMother;
      case FamilyRelation.son:
        return l10n.familyRelationSon;
      case FamilyRelation.daughter:
        return l10n.familyRelationDaughter;
      case FamilyRelation.brother:
        return l10n.familyRelationBrother;
      case FamilyRelation.sister:
        return l10n.familyRelationSister;
      case FamilyRelation.grandfather:
        return l10n.familyRelationGrandfather;
      case FamilyRelation.grandmother:
        return l10n.familyRelationGrandmother;
      case FamilyRelation.other:
        return l10n.familyRelationOther;
    }
  }
}

class _RelationChip extends StatelessWidget {
  const _RelationChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.08),
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
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _BloodChip extends StatelessWidget {
  const _BloodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFDC2626);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor : activeColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? activeColor : activeColor.withValues(alpha: 0.22),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
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
              Icons.water_drop_rounded,
              size: 14,
              color: selected ? Colors.white : activeColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : activeColor,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
