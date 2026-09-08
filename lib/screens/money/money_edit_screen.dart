import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/money_entry.dart';
import '../../models/recurring.dart';
import '../../models/severity.dart';
import '../../services/money_service.dart';
import '../../services/reminder/reminder_message_service.dart';

/// Production-grade modern fintech add/edit form for Money entries.
/// Styled with interactive visual feedback, quick-chips, smart reminders,
/// and responsive layout.
class MoneyEditScreen extends StatefulWidget {
  const MoneyEditScreen({
    super.key,
    required this.moneyService,
    this.existing,
    this.entryId,
  }) : assert(existing == null || entryId == null,
            'Pass either existing or entryId, not both.');

  final MoneyService moneyService;
  final MoneyEntry? existing;
  final String? entryId;

  @override
  State<MoneyEditScreen> createState() => _MoneyEditScreenState();
}

class _MoneyEditScreenState extends State<MoneyEditScreen> {
  late final TextEditingController _person;
  late final TextEditingController _phone;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late MoneyDirection _direction;
  late DateTime _dueDate;
  late Recurring _recurring;
  late Severity _severity;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing =>
      (widget.existing != null && widget.existing!.id.isNotEmpty) ||
      widget.entryId != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing ??
        (widget.entryId != null ? _resolveById(widget.entryId!) : null);
    _person = TextEditingController(text: e?.person ?? '');
    _phone = TextEditingController(text: e?.phoneNumber ?? '');
    _amount = TextEditingController(
      text: e == null ? '' : _formatForEdit(e.amount),
    );
    _note = TextEditingController(text: e?.note ?? '');
    _direction = e?.direction ?? MoneyDirection.receive;
    _dueDate = e?.dueDate ?? DateTime.now();
    _recurring = e?.recurring ?? Recurring.none;
    _severity = e?.severity ?? Severity.normal;
  }

  MoneyEntry? _resolveById(String id) {
    final all = widget.moneyService.getAll();
    for (final entry in all) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  @override
  void dispose() {
    _person.dispose();
    _phone.dispose();
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

  void _addQuickAmount(int value) {
    final raw = _amount.text.replaceAll(',', '').replaceAll(' ', '');
    final current = int.tryParse(raw) ?? 0;
    final updated = current + value;
    final formatted = updated.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    _amount.text = formatted;
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final rawAmount = _amount.text.replaceAll(',', '').replaceAll(' ', '');
    final amount = double.tryParse(rawAmount) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).moneyFieldAmount),
          backgroundColor: AppColors.critical,
        ),
      );
      return;
    }

    final phone = _phone.text.trim().isEmpty ? null : _phone.text.trim();

    if (_isEditing) {
      final base = widget.existing ?? _resolveById(widget.entryId!);
      final updated = base!.copyWith(
        person: _person.text.trim(),
        phoneNumber: phone,
        amount: amount,
        dueDate: _dueDate,
        direction: _direction,
        recurring: _recurring,
        severity: _severity,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      await widget.moneyService.update(updated);
      if (mounted) Navigator.of(context).pop();
    } else {
      final newEntry = MoneyEntry(
        id: 'money-${DateTime.now().microsecondsSinceEpoch}',
        person: _person.text.trim(),
        phoneNumber: phone,
        amount: amount,
        dueDate: _dueDate,
        direction: _direction,
        recurring: _recurring,
        severity: _severity,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      await widget.moneyService.add(newEntry);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final base = widget.existing ?? _resolveById(widget.entryId!);
    if (base == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteConfirmTitle),
        content: Text('${base.person} · ৳${base.amount.toStringAsFixed(0)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.criticalSoft,
              foregroundColor: AppColors.critical,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await widget.moneyService.delete(base.id);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReceive = _direction == MoneyDirection.receive;
    final activeColor = isReceive ? AppColors.brandGreen : AppColors.critical;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.close_rounded,
                    size: 18, color: AppColors.ink),
              ),
            ),
          ),
        ),
        title: Text(
          _isEditing ? 'লেনদেন সম্পাদনা' : 'নতুন লেনদেন',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        actions: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: InkWell(
                  onTap: _confirmDelete,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.criticalSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        size: 20, color: AppColors.critical),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: activeColor,
              foregroundColor: AppColors.white,
              elevation: 4,
              shadowColor: activeColor.withValues(alpha: 0.4),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  _isEditing ? 'পরিবর্তন সংরক্ষণ করুন' : 'লেনদেন যুক্ত করুন',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
            children: [
              // Direction Switcher (Hero toggle)
              _buildDirectionToggle(isReceive),
              const SizedBox(height: 18),

              // Hero Amount Card
              _buildHeroAmountCard(isReceive, activeColor),
              const SizedBox(height: 20),

              // Card 1: Person & Contact
              _buildPersonCard(isReceive),
              const SizedBox(height: 18),

              // Card 2: Due Date & Schedule
              _buildScheduleCard(),
              const SizedBox(height: 18),

              // Card 3: Priority & Notes
              _buildDetailsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionToggle(bool isReceive) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEF2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _direction = MoneyDirection.receive),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isReceive
                      ? const LinearGradient(
                          colors: [
                            AppColors.brandGreen,
                            AppColors.brandGreenDark
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isReceive ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isReceive
                      ? [
                          BoxShadow(
                            color:
                                AppColors.brandGreen.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 18,
                      color: isReceive ? AppColors.white : AppColors.inkMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'পাবো (To receive)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isReceive ? AppColors.white : AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _direction = MoneyDirection.pay),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: !isReceive
                      ? const LinearGradient(
                          colors: [
                            AppColors.critical,
                            Color(0xFFB91C1C),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: !isReceive ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: !isReceive
                      ? [
                          BoxShadow(
                            color: AppColors.critical.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 18,
                      color: !isReceive ? AppColors.white : AppColors.inkMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'দেব (To pay)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: !isReceive ? AppColors.white : AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAmountCard(bool isReceive, Color activeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: activeColor.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'টাকার পরিমাণ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isReceive ? 'পাওনা টাকা' : 'দেনার টাকা',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: activeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '৳',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: activeColor,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextFormField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                    letterSpacing: 0.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: '০',
                    hintStyle: TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'পরিমাণ লিখুন';
                    final raw = v.replaceAll(',', '').replaceAll(' ', '');
                    final n = double.tryParse(raw);
                    if (n == null || n <= 0) return 'সঠিক পরিমাণ দিন';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          // Quick amount preset chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildQuickChip('+১০০', 100, activeColor),
              _buildQuickChip('+৫০০', 500, activeColor),
              _buildQuickChip('+১,০০০', 1000, activeColor),
              _buildQuickChip('+২,০০০', 2000, activeColor),
              _buildQuickChip('+৫,০০০', 5000, activeColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, int value, Color activeColor) {
    return InkWell(
      onTap: () => _addQuickAmount(value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            color: Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonCard(bool isReceive) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(Icons.person_rounded, 'ব্যক্তি ও যোগাযোগের বিবরণ'),
          const SizedBox(height: 14),
          // Person Name
          TextFormField(
            controller: _person,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              label: 'ব্যক্তির নাম *',
              hint: 'যেমন: রাকিব হাসান / শফিক ভাই',
              icon: Icons.person_outline_rounded,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'ব্যক্তির নাম প্রদান করুন';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          // Phone number
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              label: 'ফোন নম্বর (ঐচ্ছিক)',
              hint: '০১৮১২-৩৪৫৬৭৮',
              icon: Icons.phone_outlined,
              suffix: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.mark_chat_unread_rounded,
                    size: 18, color: Color(0xFF25D366)),
              ),
            ),
          ),
          if (isReceive) ...[
            const SizedBox(height: 14),
            // Smart Taagada Preview Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded,
                            size: 14, color: Color(0xFF16A34A)),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'স্মার্ট তাগাদা বার্তা সুবিধা',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'ফোন নম্বর থাকলে সেভ করার পর এক ক্লিকেই ভদ্র ভাষায় হোয়াটসঅ্যাপ বা এসএমএস তাগাদা পাঠানো যাবে।',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF166534),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      final rawAmount = _amount.text
                          .replaceAll(',', '')
                          .replaceAll(' ', '');
                      final tempAmount = double.tryParse(rawAmount) ?? 0;
                      final dummy = MoneyEntry(
                        id: '',
                        person: _person.text.trim().isEmpty
                            ? 'সম্মানিত গ্রাহক'
                            : _person.text.trim(),
                        amount: tempAmount,
                        dueDate: _dueDate,
                        direction: MoneyDirection.receive,
                        phoneNumber: _phone.text.trim().isEmpty
                            ? null
                            : _phone.text.trim(),
                      );
                      ReminderMessageService.showReminderBottomSheet(
                        context: context,
                        entry: dummy,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 14, color: Color(0xFF16A34A)),
                          SizedBox(width: 6),
                          Text(
                            'মেসেজ প্রিভিউ ও শেয়ার',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    final localeTag = Localizations.localeOf(context).languageCode == 'bn'
        ? 'bn_BD'
        : 'en_US';
    final dateStr = DateFormat.yMMMMEEEEd(localeTag).format(_dueDate);
    final days = _dueDate
        .difference(DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day))
        .inDays;

    String dayBadge;
    if (days == 0) {
      dayBadge = 'আজই নির্ধারিত';
    } else if (days == 1) {
      dayBadge = 'আগামীকাল';
    } else if (days > 1) {
      dayBadge = '$days দিন পর';
    } else {
      dayBadge = '${days.abs()} দিন পার হয়েছে';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(Icons.calendar_month_rounded, 'পরিশোধের সময়সীমা'),
          const SizedBox(height: 14),
          // Interactive Date Box
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _dueDate,
                firstDate: DateTime(DateTime.now().year - 2),
                lastDate: DateTime(DateTime.now().year + 5),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.brandGreen,
                      onPrimary: AppColors.white,
                      surface: AppColors.white,
                      onSurface: AppColors.ink,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                setState(() => _dueDate = picked);
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_today_rounded,
                        size: 18, color: AppColors.brandGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'পরিশোধের তারিখ',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.inkMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: days <= 1
                          ? AppColors.criticalSoft
                          : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dayBadge,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: days <= 1
                            ? AppColors.critical
                            : const Color(0xFF0369A1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Quick date chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDatePresetChip('আজ', 0),
              _buildDatePresetChip('আগামীকাল', 1),
              _buildDatePresetChip('৭ দিন পর', 7),
              _buildDatePresetChip('১৫ দিন পর', 15),
              _buildDatePresetChip('৩০ দিন পর', 30),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'পুনরাবৃত্তি (Repeats)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 8),
          _buildRecurringSelector(),
        ],
      ),
    );
  }

  Widget _buildDatePresetChip(String label, int addDays) {
    final target = DateTime.now().add(Duration(days: addDays));
    final isSelected = _dueDate.year == target.year &&
        _dueDate.month == target.month &&
        _dueDate.day == target.day;

    return InkWell(
      onTap: () => setState(() => _dueDate = target),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brandGreen.withValues(alpha: 0.12)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.brandGreen : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.brandGreenDark : AppColors.ink,
          ),
        ),
      ),
    );
  }

  Widget _buildRecurringSelector() {
    final items = [
      (Recurring.none, 'একবার'),
      (Recurring.daily, 'দৈনিক'),
      (Recurring.weekly, 'সাপ্তাহিক'),
      (Recurring.monthly, 'মাসিক'),
      (Recurring.yearly, 'বার্ষিক'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (rec, label) in items)
          InkWell(
            onTap: () => setState(() => _recurring = rec),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _recurring == rec
                    ? AppColors.brandGreenLight
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _recurring == rec
                      ? AppColors.brandGreen
                      : const Color(0xFFE2E8F0),
                  width: _recurring == rec ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      _recurring == rec ? FontWeight.w700 : FontWeight.w500,
                  color: _recurring == rec
                      ? AppColors.brandGreenDark
                      : AppColors.ink,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(Icons.bolt_rounded, 'অগ্রাধিকার ও বিবরণ'),
          const SizedBox(height: 14),
          const Text(
            'জরুরিতা মাত্রা (Priority)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSeverityOption(
                  Severity.normal,
                  'সাধারণ',
                  Icons.check_circle_outline,
                  AppColors.brandGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSeverityOption(
                  Severity.important,
                  'জরুরি',
                  Icons.watch_later_outlined,
                  AppColors.important,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSeverityOption(
                  Severity.critical,
                  'অতি জরুরি',
                  Icons.warning_amber_rounded,
                  AppColors.critical,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Note
          TextFormField(
            controller: _note,
            maxLines: 3,
            decoration: _inputDecoration(
              label: 'নোট বা মন্তব্য (ঐচ্ছিক)',
              hint: 'কোনো বিশেষ শর্ত বা বিবরণ...',
              icon: Icons.notes_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityOption(
      Severity sev, String title, IconData icon, Color color) {
    final selected = _severity == sev;
    return InkWell(
      onTap: () => setState(() => _severity = sev),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : const Color(0xFFE2E8F0),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: selected ? color : AppColors.inkMuted),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.brandGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
      hintText: hint,
      hintStyle:
          const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, size: 19, color: AppColors.inkMuted),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: AppColors.brandGreen, width: 1.5),
      ),
    );
  }
}