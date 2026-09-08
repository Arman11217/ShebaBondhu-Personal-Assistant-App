import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/ai/parsed_intent.dart';
import '../../models/bill.dart';
import '../../models/identity_document.dart';
import '../../models/medicine.dart';
import '../../models/money_entry.dart';
import '../../models/recurring.dart';
import '../../models/severity.dart';
import '../../models/sim_card.dart';
import '../../models/task.dart';

/// Routes a [ParsedIntent] to the right module's edit screen and prefills
/// all recognized fields so the user can review and edit before saving.
class QuickAddRoutes {
  QuickAddRoutes._();

  static void dispatch({
    required BuildContext context,
    required ParsedIntent intent,
  }) {
    final now = DateTime.now();

    switch (intent.module) {
      case QuickAddModule.money:
        final amount = intent.getDouble('amount') ?? 0;
        final person = intent.getString('person') ?? '';
        final dirStr = intent.getString('direction')?.toLowerCase() ?? 'receive';
        final direction = dirStr == 'give' || dirStr == 'pay'
            ? MoneyDirection.pay
            : MoneyDirection.receive;
        final dueDate = intent.getDate('dueDate') ?? now;
        final phone = intent.getString('phoneNumber') ?? intent.getString('phone');
        final prefilled = MoneyEntry(
          id: '',
          person: person,
          phoneNumber: phone,
          amount: amount,
          dueDate: dueDate,
          direction: direction,
          recurring: Recurring.none,
          severity: Severity.important,
          note: intent.originalText,
        );
        context.push('/money/edit', extra: prefilled);
        break;

      case QuickAddModule.bill:
        final typeStr = intent.getString('type')?.toLowerCase() ?? 'other';
        final billType = _toBillType(typeStr);
        final amount = intent.getDouble('amount') ?? 0;
        final dueDay = intent.getInt('dueDay');
        DateTime dueDate;
        if (intent.getDate('dueDate') != null) {
          dueDate = intent.getDate('dueDate')!;
        } else if (dueDay != null && dueDay >= 1 && dueDay <= 28) {
          dueDate = DateTime(now.year, now.month, dueDay);
          if (dueDate.isBefore(now)) {
            dueDate = DateTime(now.year, now.month + 1, dueDay);
          }
        } else {
          dueDate = now.add(const Duration(days: 7));
        }
        final prefilled = Bill(
          id: '',
          type: billType,
          label: '${_billTypeName(billType)} বিল',
          provider: 'সাধারণ',
          amount: amount,
          nextDueDate: dueDate,
          recurring: Recurring.monthly,
          severity: Severity.important,
          note: intent.originalText,
        );
        context.push('/bills/edit', extra: prefilled);
        break;

      case QuickAddModule.medicine:
        final name = intent.getString('name') ?? '';
        final dose = intent.getString('dose') ?? '১ টি';
        final prefilled = Medicine(
          id: '',
          name: name.isEmpty ? 'নতুন ওষুধ' : name,
          forMember: 'আমি',
          dose: dose,
          frequency: MedicineFrequency.twiceDaily,
          slots: const [MedicineSlot.morning, MedicineSlot.night],
          remainingUnits: 30,
          estimatedDaysRemaining: 15,
          note: intent.originalText,
        );
        context.push('/medicines/edit', extra: prefilled);
        break;

      case QuickAddModule.sim:
        final carrierStr = intent.getString('carrier')?.toLowerCase() ?? 'other';
        final carrier = _toSimCarrier(carrierStr);
        final amount = intent.getDouble('amount') ?? 0;
        final dataGb = intent.getDouble('dataGb');
        final prefilled = SimCard(
          id: '',
          memberName: 'আমি',
          carrier: carrier,
          number: '',
          rechargeAmount: amount,
          dataBalanceGb: dataGb,
          lastRechargeDate: now,
          validityDays: intent.getInt('validityDays') ?? 30,
          note: intent.originalText,
        );
        context.push('/sims/edit', extra: prefilled);
        break;

      case QuickAddModule.task:
        final title = intent.getString('title') ??
            (intent.originalText.isNotEmpty ? intent.originalText : 'নতুন কাজ');
        final dueDate =
            intent.getDate('dueDate') ?? now.add(const Duration(days: 1));
        final prefilled = Task(
          id: '',
          title: title,
          dueDate: dueDate,
          priority: TaskPriority.normal,
          status: TaskStatus.pending,
          createdAt: now,
          note: intent.originalText,
        );
        context.push('/tasks/edit', extra: prefilled);
        break;

      case QuickAddModule.document:
        final name = intent.getString('name') ?? 'জাতীয় পরিচয়পত্র';
        final expiry =
            intent.getDate('expiresAt') ?? now.add(const Duration(days: 365));
        final prefilled = IdentityDocument(
          id: '',
          type: DocumentType.nid,
          label: name,
          expiryDate: expiry,
          note: intent.originalText,
        );
        context.push('/documents/edit', extra: prefilled);
        break;

      case QuickAddModule.unknown:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('তথ্যটি বুঝতে পারিনি — পুনরায় চেষ্টা করুন।'),
          ),
        );
        break;
    }
  }

  static BillType _toBillType(String type) {
    if (type.contains('elec') || type.contains('বিদ্যুৎ')) {
      return BillType.electricity;
    }
    if (type.contains('gas') || type.contains('গ্যাস')) return BillType.gas;
    if (type.contains('water') || type.contains('পানি')) return BillType.water;
    if (type.contains('inter') ||
        type.contains('wifi') ||
        type.contains('ইন্টারনেট')) {
      return BillType.internet;
    }
    if (type.contains('tv') || type.contains('টিভি')) return BillType.tv;
    return BillType.other;
  }

  static String _billTypeName(BillType t) {
    switch (t) {
      case BillType.electricity:
        return 'বিদ্যুৎ';
      case BillType.gas:
        return 'গ্যাস';
      case BillType.water:
        return 'পানি';
      case BillType.internet:
        return 'ইন্টারনেট';
      case BillType.tv:
        return 'টিভি';
      case BillType.mobile:
        return 'মোবাইল';
      case BillType.other:
        return 'অন্যান্য';
    }
  }

  static SimCarrier _toSimCarrier(String c) {
    if (c.contains('gp') || c.contains('grameen')) {
      return SimCarrier.grameenphone;
    }
    if (c.contains('robi')) return SimCarrier.robi;
    if (c.contains('cirkle') || c.contains('circle') || c.contains('airtel')) {
      return SimCarrier.airtel;
    }
    if (c.contains('bangla')) return SimCarrier.banglalink;
    if (c.contains('tele')) return SimCarrier.teletalk;
    return SimCarrier.other;
  }
}