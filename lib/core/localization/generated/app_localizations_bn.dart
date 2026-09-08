// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'সেবা বন্ধু';

  @override
  String get tagline => 'আপনার ব্যক্তিগত স্মৃতি সহকারী।';

  @override
  String get taglineBn => 'সমস্যা বলুন, করণীয় জানুন।';

  @override
  String get commonContinue => 'চালিয়ে যান';

  @override
  String get commonSkip => 'এড়িয়ে যান';

  @override
  String get commonNext => 'পরবর্তী';

  @override
  String get commonBack => 'পেছনে';

  @override
  String get commonDone => 'সম্পন্ন';

  @override
  String get commonCancel => 'বাতিল';

  @override
  String get commonRetry => 'আবার চেষ্টা করুন';

  @override
  String get commonYes => 'হ্যাঁ';

  @override
  String get commonNo => 'না';

  @override
  String get commonSubmit => 'জমা দিন';

  @override
  String get commonSave => 'সংরক্ষণ';

  @override
  String get commonDelete => 'মুছুন';

  @override
  String get commonEdit => 'সম্পাদনা';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonSearch => 'খুঁজুন';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get severityCritical => 'Critical';

  @override
  String get severityImportant => 'Important';

  @override
  String get severityNormal => 'Normal';

  @override
  String get dueToday => 'Due today';

  @override
  String get dueTomorrow => 'Due tomorrow';

  @override
  String daysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days remaining',
      one: '1 day remaining',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String get onboardingTitle1 => 'Never forget again';

  @override
  String get onboardingDesc1 =>
      'Money, bills, documents, warranties — Sheba Bondhu remembers everything so you don\'t have to.';

  @override
  String get onboardingTitle2 => 'Just say it';

  @override
  String get onboardingDesc2 =>
      'Speak, type or scan. Our AI understands Bangla and turns your words into smart reminders.';

  @override
  String get onboardingTitle3 => 'Always one step ahead';

  @override
  String get onboardingDesc3 =>
      'Bondhu learns your habits and warns you before you forget — bills, recharges, medicines and more.';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get loginTitle => 'আপনার মোবাইল নম্বর দিন';

  @override
  String get loginSubtitle => 'আমরা ৬ ডিজিটের একটি যাচাই কোড পাঠাব।';

  @override
  String get loginPhoneHint => 'Phone number';

  @override
  String get loginSendOtp => 'Send OTP';

  @override
  String get loginOtpHint => '6-digit code';

  @override
  String get loginVerify => 'Verify';

  @override
  String get loginResendOtp => 'Resend code';

  @override
  String get loginChangeNumber => 'Change number';

  @override
  String get loginTermsNotice =>
      'By continuing you agree to our Terms & Privacy Policy.';

  @override
  String get homeGreetingMorning => 'সুপ্রভাত';

  @override
  String get homeGreetingAfternoon => 'শুভ দুপুর';

  @override
  String get homeGreetingEvening => 'শুভ সন্ধ্যা';

  @override
  String get homeGreetingNight => 'শুভ রাত্রি';

  @override
  String get homeUserFallback => 'বন্ধু';

  @override
  String homeSummaryImportant(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'আজ $countটি জরুরি কাজ',
      one: 'আজ ১টি জরুরি কাজ',
    );
    return '$_temp0';
  }

  @override
  String get homeSectionToday => 'আজ';

  @override
  String get homeSectionUpcoming => 'আসছে';

  @override
  String get homeSectionInsight => 'বন্ধুর পরামর্শ';

  @override
  String get homeEmptyTodayTitle => 'আজ কিছু নেই';

  @override
  String get homeEmptyTodayBody => 'আজ আপনি ফ্রি — উপভোগ করুন।';

  @override
  String get homeEmptyUpcomingTitle => 'কোনো আসন্ন কাজ নেই';

  @override
  String get homeEmptyUpcomingBody => 'সব এগিয়ে আছে।';

  @override
  String get homeInsightTitle => 'আমি একটা প্যাটার্ন দেখলাম';

  @override
  String homeInsightBody(String day) {
    return 'আপনি সাধারণত প্রতি মাসের $day তারিখে বিদ্যুৎ বিল দেন।';
  }

  @override
  String get homeInsightActionRemind => 'মনে করিয়ে দিন';

  @override
  String get homeInsightActionDismiss => 'এই মাসে না';

  @override
  String get homeQuickAddTitle => 'কী মনে রাখব?';

  @override
  String get homeQuickAddSubtitle =>
      'বলুন, লিখুন বা স্ক্যান করুন — বাকিটা আমি করব।';

  @override
  String get homeQuickAddSpeak => 'বলুন';

  @override
  String get homeQuickAddType => 'লিখুন';

  @override
  String get homeQuickAddScan => 'স্ক্যান';

  @override
  String get homeQuickActionsTitle => 'দ্রুত কাজ';

  @override
  String get homeQuickMoneyTitle => 'টাকা';

  @override
  String get homeQuickMoneySubtitle => 'ধার-দেনার হিসাব';

  @override
  String get homeQuickAddMoneyTooltip => 'টাকার হিসাব যোগ করুন';

  @override
  String get homeNavHome => 'হোম';

  @override
  String get homeNavAdd => 'যোগ করুন';

  @override
  String get homeNavMoney => 'টাকা';

  @override
  String get homeNavMore => 'আরও';

  @override
  String get moreTitle => 'আরও';

  @override
  String get moreSectionModules => 'মডিউলসমূহ';

  @override
  String get moreMoneyTitle => 'টাকা ম্যানেজার';

  @override
  String get moreMoneySubtitle => 'আপনি কাকে ধার দিলেন/পেলেন তার হিসাব';

  @override
  String get moreBillsTitle => 'বিল বন্ধু';

  @override
  String get moreBillsSubtitle => 'বিদ্যুৎ, গ্যাস, ইন্টারনেটসহ সব মাসিক বিল';

  @override
  String get moreDocsTitle => 'কাগজ বন্ধু';

  @override
  String get moreDocsSubtitle => 'কাগজের মেয়াদ শেষ হওয়ার আগে সতর্কতা';

  @override
  String get moreWarrantyTitle => 'ওয়ারেন্টি বন্ধু';

  @override
  String get moreWarrantySubtitle => 'বিল ও ওয়ারেন্টির হিসাব';

  @override
  String get moreMedicineTitle => 'ওষুধ বন্ধু';

  @override
  String get moreMedicineSubtitle => 'পরিবারের ওষুধের তালিকা';

  @override
  String get moreRechargeTitle => 'রিচার্জ বন্ধু';

  @override
  String get moreRechargeSubtitle => 'পরিবারের সিম ও প্যাকেজ';

  @override
  String get moreFamilyTitle => 'পরিবার বন্ধু';

  @override
  String get moreFamilySubtitle => 'একসাথে কাজ ও স্মরণীয় দিনগুলো';

  @override
  String get moreCalendarTitle => 'ক্যালেন্ডার';

  @override
  String get moreCalendarSubtitle => 'সব ইভেন্ট এক জায়গায়';

  @override
  String get moreTasksTitle => 'কাজ বন্ধু';

  @override
  String get moreTasksSubtitle => 'দৈনন্দিন কাজের তালিকা';

  @override
  String get moreAnalyticsTitle => 'ড্যাশবোর্ড';

  @override
  String get moreAnalyticsSubtitle => 'মাসিক সারাংশ';

  @override
  String get moreSectionAccount => 'অ্যাকাউন্ট';

  @override
  String get moreSettings => 'সেটিংস';

  @override
  String get moreHelp => 'সাহায্য ও মতামত';

  @override
  String get moreAbout => 'সম্পর্কে';

  @override
  String get catMoney => 'Money';

  @override
  String get catBill => 'Bill';

  @override
  String get catDocument => 'Document';

  @override
  String get catWarranty => 'Warranty';

  @override
  String get catMedicine => 'Medicine';

  @override
  String get catRecharge => 'Recharge';

  @override
  String get catAppointment => 'Appointment';

  @override
  String get catTask => 'Task';

  @override
  String get moneyToReceive => 'To receive';

  @override
  String get moneyToPay => 'To pay';

  @override
  String get moneyPerson => 'Person';

  @override
  String get moneyAmount => 'Amount';

  @override
  String get moneyDue => 'Due';

  @override
  String moneyTotalReceive(String amount) {
    return 'You will receive: $amount';
  }

  @override
  String moneyTotalPay(String amount) {
    return 'You need to pay: $amount';
  }

  @override
  String get actionSendReminder => 'মনে করিয়ে দিন';

  @override
  String get moneyListTitle => 'Money manager';

  @override
  String get moneyListEmptyTitle => 'No entries yet';

  @override
  String get moneyListEmptyBody =>
      'Tap the + button to add what you owe or are owed.';

  @override
  String get moneySectionReceive => 'To receive';

  @override
  String get moneySectionPay => 'To pay';

  @override
  String get moneyAddTitle => 'New entry';

  @override
  String get moneyEditTitle => 'Edit entry';

  @override
  String get moneyFieldPerson => 'Person';

  @override
  String get moneyFieldPersonHint => 'e.g. Rakib';

  @override
  String get moneyFieldAmount => 'Amount';

  @override
  String get moneyFieldAmountHint => '0';

  @override
  String get moneyFieldDue => 'Due date';

  @override
  String get moneyFieldNote => 'Note (optional)';

  @override
  String get moneyFieldNoteHint => 'Anything to remember…';

  @override
  String get moneyFieldRecurring => 'Repeats';

  @override
  String get moneyFieldDirection => 'Direction';

  @override
  String get dueLabelPickDate => 'Pick a date';

  @override
  String get deleteConfirmTitle => 'Delete this entry?';

  @override
  String get deleteConfirmBody => 'This cannot be undone.';

  @override
  String get recurringNone => 'One-time';

  @override
  String get recurringDaily => 'Daily';

  @override
  String get recurringWeekly => 'Weekly';

  @override
  String get recurringMonthly => 'Monthly';

  @override
  String get recurringYearly => 'Yearly';

  @override
  String get billListTitle => 'Bill Bondhu';

  @override
  String get billListEmptyTitle => 'No bills yet';

  @override
  String get billListEmptyBody =>
      'Add your electricity, gas, internet and other monthly bills so Bondhu can remind you before the due date.';

  @override
  String get billListTotalLabel => 'Total monthly';

  @override
  String billListPaidCount(int paid, int total) {
    return '$paid of $total scheduled automatically';
  }

  @override
  String get billSectionUpcoming => 'Due soon';

  @override
  String get billSectionLater => 'Later this month';

  @override
  String get billAddTitle => 'New bill';

  @override
  String get billEditTitle => 'Edit bill';

  @override
  String get billFieldType => 'Type';

  @override
  String get billFieldLabel => 'Nickname';

  @override
  String get billFieldLabelHint => 'e.g. Home electricity';

  @override
  String get billFieldProvider => 'Provider';

  @override
  String get billFieldProviderHint => 'e.g. DESCO';

  @override
  String get billFieldAmount => 'Amount';

  @override
  String get billFieldAmountHint => '0';

  @override
  String get billFieldNextDue => 'Next due date';

  @override
  String get billFieldRecurring => 'Repeats';

  @override
  String get billFieldSeverity => 'Priority';

  @override
  String get billFieldAutoPay => 'Auto-pay enabled';

  @override
  String get billFieldNote => 'Note (optional)';

  @override
  String get billFieldNoteHint => 'Account no., meter no., etc.';

  @override
  String get billTypeElectricity => 'Electricity';

  @override
  String get billTypeGas => 'Gas';

  @override
  String get billTypeWater => 'Water';

  @override
  String get billTypeInternet => 'Internet';

  @override
  String get billTypeTv => 'Cable TV';

  @override
  String get billTypeMobile => 'Mobile';

  @override
  String get billTypeOther => 'Other';

  @override
  String get docsListTitle => 'Document Bondhu';

  @override
  String get docsListEmptyTitle => 'No documents yet';

  @override
  String get docsListEmptyBody =>
      'Add NID, passport, driving license and certificates so Bondhu can remind you before they expire.';

  @override
  String get docsListExpiringSoon => 'Expiring soon';

  @override
  String get docsListValid => 'Valid';

  @override
  String get docsListExpired => 'Expired';

  @override
  String get docsAddTitle => 'New document';

  @override
  String get docsEditTitle => 'Edit document';

  @override
  String get docsFieldType => 'Type';

  @override
  String get docsFieldLabel => 'Nickname';

  @override
  String get docsFieldLabelHint => 'e.g. Home NID';

  @override
  String get docsFieldNumber => 'Document number (optional)';

  @override
  String get docsFieldNumberHint => 'e.g. 199012345678';

  @override
  String get docsFieldIssuer => 'Issuer (optional)';

  @override
  String get docsFieldIssuerHint => 'e.g. BRTA';

  @override
  String get docsFieldIssueDate => 'Issue date';

  @override
  String get docsFieldExpiryDate => 'Expiry date';

  @override
  String get docsFieldNote => 'Note (optional)';

  @override
  String get docsFieldNoteHint => 'Anything to remember';

  @override
  String get docsExpiredBadge => 'Expired';

  @override
  String docsExpiringIn(int days) {
    return 'Expires in $days days';
  }

  @override
  String docsExpiredOn(String date) {
    return 'Expired on $date';
  }

  @override
  String get docTypeNid => 'National ID';

  @override
  String get docTypePassport => 'Passport';

  @override
  String get docTypeDrivingLicense => 'Driving License';

  @override
  String get docTypeVehicleFitness => 'Vehicle Fitness';

  @override
  String get docTypeTradeLicense => 'Trade License';

  @override
  String get docTypeBankCard => 'Bank Card';

  @override
  String get docTypeInsurance => 'Insurance';

  @override
  String get docTypeCertificate => 'Certificate';

  @override
  String get docTypeOther => 'Other';

  @override
  String get medListTitle => 'Medicine Bondhu';

  @override
  String get medListEmptyTitle => 'No medicines yet';

  @override
  String get medListEmptyBody =>
      'Add the medicines your family uses so Bondhu can remind you before they run out.';

  @override
  String get medListTotalLabel => 'Medicines in stock';

  @override
  String medListLowStockCount(int low, int total) {
    return '$low of $total running low';
  }

  @override
  String get medSectionLowStock => 'Running low';

  @override
  String get medSectionActive => 'In stock';

  @override
  String get medAddTitle => 'New medicine';

  @override
  String get medEditTitle => 'Edit medicine';

  @override
  String get medFieldName => 'Medicine name';

  @override
  String get medFieldNameHint => 'e.g. Napa 500mg';

  @override
  String get medFieldMember => 'For';

  @override
  String get medFieldMemberHint => 'e.g. Self, Father, Mother';

  @override
  String get medFieldDose => 'Dose';

  @override
  String get medFieldDoseHint => 'e.g. 1 tablet, 5 ml';

  @override
  String get medFieldFrequency => 'Frequency';

  @override
  String get medFieldSlots => 'When';

  @override
  String get medFieldStartDate => 'Started on';

  @override
  String get medFieldEndDate => 'Course ends on (optional)';

  @override
  String get medFieldRemaining => 'Remaining units';

  @override
  String get medFieldRemainingHint => '0';

  @override
  String get medFieldNote => 'Note (optional)';

  @override
  String get medFieldNoteHint => 'After meal, before bed, etc.';

  @override
  String get medFrequencyOnceDaily => 'Once a day';

  @override
  String get medFrequencyTwiceDaily => 'Twice a day';

  @override
  String get medFrequencyThriceDaily => 'Three times a day';

  @override
  String get medFrequencyFourTimesDaily => 'Four times a day';

  @override
  String get medFrequencyWeekly => 'Weekly';

  @override
  String get medFrequencyAsNeeded => 'As needed';

  @override
  String get medSlotMorning => 'Morning';

  @override
  String get medSlotAfternoon => 'Afternoon';

  @override
  String get medSlotEvening => 'Evening';

  @override
  String get medSlotNight => 'Night';

  @override
  String medStockBadge(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
      zero: 'Runs out today',
    );
    return '$_temp0';
  }

  @override
  String medUnitsLeft(int units) {
    return '$units units';
  }

  @override
  String get simListTitle => 'Recharge Bondhu';

  @override
  String get simListEmptyTitle => 'No SIMs yet';

  @override
  String get simListEmptyBody =>
      'Add the SIMs your family uses so Bondhu can warn you when a package is about to expire.';

  @override
  String get simListTotalLabel => 'SIMs tracked';

  @override
  String simListAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count need attention',
      one: '1 needs attention',
    );
    return '$_temp0';
  }

  @override
  String get simSectionAttention => 'Needs attention';

  @override
  String get simSectionActive => 'Active';

  @override
  String get simAddTitle => 'New SIM';

  @override
  String get simEditTitle => 'Edit SIM';

  @override
  String get simFieldCarrier => 'Carrier';

  @override
  String get simFieldMember => 'For';

  @override
  String get simFieldMemberHint => 'e.g. Self, Father';

  @override
  String get simFieldNumber => 'Phone number';

  @override
  String get simFieldNumberHint => '+8801XXXXXXXXX';

  @override
  String get simFieldLastRecharge => 'Last recharge date';

  @override
  String get simFieldRechargeAmount => 'Recharge amount';

  @override
  String get simFieldValidityDays => 'Validity (days)';

  @override
  String get simFieldDataBalance => 'Remaining data (GB, optional)';

  @override
  String get simFieldNote => 'Note (optional)';

  @override
  String get simFieldNoteHint => 'Package name, owner, etc.';

  @override
  String get simCarrierGrameenphone => 'Grameenphone';

  @override
  String get simCarrierRobi => 'Robi';

  @override
  String get simCarrierAirtel => 'Cirkle';

  @override
  String get simCarrierBanglalink => 'Banglalink';

  @override
  String get simCarrierTeletalk => 'Teletalk';

  @override
  String get simCarrierOther => 'Other';

  @override
  String get simStatusActive => 'Active';

  @override
  String get simStatusDataLow => 'Data low';

  @override
  String get simStatusPackageExpiringSoon => 'Package expiring soon';

  @override
  String get simStatusNeedsRecharge => 'Recharge recommended';

  @override
  String simDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '1 day ago',
      zero: 'recharged today',
    );
    return '$_temp0';
  }

  @override
  String simValidityDays(int days) {
    return '$days-day package';
  }

  @override
  String simDataBalance(String amount) {
    return '$amount GB left';
  }

  @override
  String simPackageExpires(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expires in $days days',
      one: 'Expires in 1 day',
      zero: 'Expires today',
    );
    return '$_temp0';
  }

  @override
  String simPackageExpired(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '1 day ago',
      zero: 'today',
    );
    return 'Expired $_temp0';
  }

  @override
  String get simNoRecharge => 'No recharge recorded';

  @override
  String get simMarkAsRecharged => 'Mark as recharged';

  @override
  String get warrantyListTitle => 'Warranty Bondhu';

  @override
  String get warrantyListEmptyTitle => 'No warranties yet';

  @override
  String get warrantyListEmptyBody =>
      'Add products under warranty so Bondhu can remind you before the coverage runs out.';

  @override
  String get warrantyListTotalLabel => 'Warranties tracked';

  @override
  String warrantyAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count need attention',
      one: '1 needs attention',
    );
    return '$_temp0';
  }

  @override
  String get warrantySectionExpired => 'Expired';

  @override
  String get warrantySectionExpiring => 'Expiring soon';

  @override
  String get warrantySectionActive => 'Active';

  @override
  String get warrantyAddTitle => 'New warranty';

  @override
  String get warrantyEditTitle => 'Edit warranty';

  @override
  String get warrantyFieldCategory => 'Category';

  @override
  String get warrantyFieldBrand => 'Brand';

  @override
  String get warrantyFieldProductName => 'Product name';

  @override
  String get warrantyFieldProductNameHint => 'e.g. Smart TV 43 inch';

  @override
  String get warrantyFieldVendor => 'Shop / vendor (optional)';

  @override
  String get warrantyFieldVendorHint => 'e.g. RCY Electronics';

  @override
  String get warrantyFieldPrice => 'Price (optional)';

  @override
  String get warrantyFieldPurchaseDate => 'Purchase date';

  @override
  String get warrantyFieldExpiryDate => 'Warranty expires on';

  @override
  String get warrantyFieldNote => 'Note (optional)';

  @override
  String get warrantyFieldNoteHint => 'Model number, serial, etc.';

  @override
  String get warrantyCategoryElectronics => 'Electronics';

  @override
  String get warrantyCategoryAppliance => 'Appliance';

  @override
  String get warrantyCategoryFurniture => 'Furniture';

  @override
  String get warrantyCategoryVehicle => 'Vehicle';

  @override
  String get warrantyCategoryJewellery => 'Jewellery';

  @override
  String get warrantyCategoryClothing => 'Clothing';

  @override
  String get warrantyCategoryOther => 'Other';

  @override
  String get warrantyStatusActive => 'Active';

  @override
  String get warrantyStatusExpiringSoon => 'Expiring soon';

  @override
  String get warrantyStatusExpired => 'Expired';

  @override
  String warrantyDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
      zero: 'Expires today',
    );
    return '$_temp0';
  }

  @override
  String warrantyExpiredDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '1 day ago',
    );
    return 'Expired $_temp0';
  }

  @override
  String get familyListTitle => 'Family';

  @override
  String get familyAddTitle => 'Add family member';

  @override
  String get familyEditTitle => 'Edit family member';

  @override
  String get familyListEmptyTitle => 'No family members yet';

  @override
  String get familyListEmptyBody =>
      'Add your family to keep track of blood groups, phones and IDs.';

  @override
  String get familyListTotalLabel => 'Family members';

  @override
  String get familySummaryMembers => 'members';

  @override
  String get familyFieldRelation => 'Relation';

  @override
  String get familyFieldName => 'Name';

  @override
  String get familyFieldNameHint => 'Full name';

  @override
  String get familyFieldBloodGroup => 'Blood group';

  @override
  String get familyFieldPhone => 'Phone (optional)';

  @override
  String get familyFieldPhoneHint => '01XXXXXXXXX';

  @override
  String get familyFieldNid => 'National ID (optional)';

  @override
  String get familyFieldNidHint => '10/13/17 digit NID';

  @override
  String get familyFieldBirthDate => 'Date of birth (optional)';

  @override
  String get familyFieldNote => 'Note (optional)';

  @override
  String get familyFieldNoteHint => 'Occupation, address, anything to remember';

  @override
  String get familyRelationSelf => 'নিজ';

  @override
  String get familyRelationSpouse => 'স্বামী/স্ত্রী';

  @override
  String get familyRelationFather => 'পিতা';

  @override
  String get familyRelationMother => 'মাতা';

  @override
  String get familyRelationSon => 'Son';

  @override
  String get familyRelationDaughter => 'Daughter';

  @override
  String get familyRelationBrother => 'Brother';

  @override
  String get familyRelationSister => 'Sister';

  @override
  String get familyRelationGrandfather => 'Grandfather';

  @override
  String get familyRelationGrandmother => 'Grandmother';

  @override
  String get familyRelationOther => 'অন্যান্য';

  @override
  String familyAgeYears(int age) {
    String _temp0 = intl.Intl.pluralLogic(
      age,
      locale: localeName,
      other: '$age yrs',
      one: '1 yr',
    );
    return '$_temp0';
  }

  @override
  String get dueLabelClearDate => 'Clear date';

  @override
  String get taskListTitle => 'Tasks';

  @override
  String get taskAddTitle => 'Add task';

  @override
  String get taskEditTitle => 'Edit task';

  @override
  String get taskListEmptyTitle => 'Nothing on the list';

  @override
  String get taskListEmptyBody =>
      'Add a task to keep track of errands, calls and deadlines.';

  @override
  String get taskSummaryHeadline => 'Open tasks';

  @override
  String get taskSummaryPendingLabel => 'pending';

  @override
  String get taskSummaryDoneLabel => 'Done';

  @override
  String taskSummaryOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue',
      one: '1 overdue',
    );
    return '$_temp0';
  }

  @override
  String get taskSectionPending => 'Pending';

  @override
  String get taskSectionDone => 'Done';

  @override
  String get taskAllDoneBanner =>
      'You\'re all caught up. Add a new task to stay ahead.';

  @override
  String get taskFieldTitle => 'Title';

  @override
  String get taskFieldTitleHint => 'What needs to be done?';

  @override
  String get taskFieldPriority => 'Priority';

  @override
  String get taskFieldDueDate => 'Due date (optional)';

  @override
  String get taskFieldNote => 'Note (optional)';

  @override
  String get taskFieldNoteHint => 'Any extra details';

  @override
  String get taskFieldStatus => 'Status';

  @override
  String get taskStatusPending => 'Pending';

  @override
  String get taskStatusDone => 'Done';

  @override
  String get taskStatusPendingHint => 'Tap the switch when you finish it.';

  @override
  String get taskStatusDoneHint =>
      'Toggle off to bring it back to the pending list.';

  @override
  String get taskPriorityHigh => 'High';

  @override
  String get taskPriorityNormal => 'Normal';

  @override
  String get taskPriorityLow => 'Low';

  @override
  String get taskDueToday => 'Due today';

  @override
  String get taskDueTomorrow => 'Due tomorrow';

  @override
  String taskDueIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Due in $_temp0';
  }

  @override
  String taskOverdue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Overdue by $_temp0';
  }

  @override
  String taskCompletedOnDate(int days) {
    return 'Completed ${days}d ago';
  }

  @override
  String get quickAddTitle => 'à¦¦à§à¦°à§à¦¤ à¦¯à§‹à¦— à¦•à¦°à§à¦¨';

  @override
  String get quickAddParseButton =>
      'à¦¸à¦ à¦¿à¦• à¦œà¦¾à¦¯à¦¼à¦—à¦¾à¦¯à¦¼ à¦ªà¦¾à¦ à¦¾à¦¨';

  @override
  String get quickAddGoButton => 'à¦šà¦¾à¦²à¦¿à¦¯à¦¼à§‡ à¦¯à¦¾à¦¨';

  @override
  String get quickAddExamplesTitle => 'à¦à¦­à¦¾à¦¬à§‡ à¦¬à¦²à§à¦¨...';

  @override
  String get quickAddHintMoney =>
      'à¦°à¦¹à¦¿à¦®à§‡à¦° à¦•à¦¾à¦› à¦¥à§‡à¦•à§‡ à§«à§¦à§¦ à¦Ÿà¦¾à¦•à¦¾ à¦ªà¦¾à¦¬';

  @override
  String get quickAddHintBill =>
      'à¦¬à¦¿à¦¦à§à¦¯à§à§Ž à¦¬à¦¿à¦² à§§à§¨à§¦à§¦ à¦Ÿà¦¾à¦•à¦¾ à¦†à¦—à¦¾à¦®à§€à¦•à¦¾à¦²';

  @override
  String get quickAddHintTask =>
      'à§© à¦¦à¦¿à¦¨à§‡à¦° à¦®à¦§à§à¦¯à§‡ à¦ªà¦¾à¦°à§à¦¸à§‡à¦² à¦¤à§à¦²à¦¤à§‡ à¦¹à¦¬à§‡';

  @override
  String get quickAddHintFamily =>
      'à¦®à¦¾à¦¯à¦¼à§‡à¦° à¦œà¦¨à§à¦®à¦¦à¦¿à¦¨ à¦ªà¦°à§‡à¦° à¦¸à¦ªà§à¦¤à¦¾à¦¹à§‡';

  @override
  String get quickAddIntentMoney => 'à¦Ÿà¦¾à¦•à¦¾ à¦¬à¦¨à§à¦§à§';

  @override
  String get quickAddIntentBill => 'à¦¬à¦¿à¦² à¦¬à¦¨à§à¦§à§';

  @override
  String get quickAddIntentDocument => 'à¦•à¦¾à¦—à¦œ à¦¬à¦¨à§à¦§à§';

  @override
  String get quickAddIntentWarranty =>
      'à¦“à¦¯à¦¼à¦¾à¦°à§‡à¦¨à§à¦Ÿà¦¿ à¦¬à¦¨à§à¦§à§';

  @override
  String get quickAddIntentMedicine => 'à¦“à¦·à§à¦§ à¦¬à¦¨à§à¦§à§';

  @override
  String get quickAddIntentSim => 'à¦°à¦¿à¦šà¦¾à¦°à§à¦œ à¦¬à¦¨à§à¦§à§';

  @override
  String get quickAddIntentFamily => 'à¦ªà¦°à¦¿à¦¬à¦¾à¦° à¦¬à¦¨à§à¦§à§';

  @override
  String get quickAddIntentTask => 'à¦•à¦¾à¦œ à¦¬à¦¨à§à¦§à§';

  @override
  String get quickAddPreviewDestination =>
      'à¦†à¦®à¦¿ à¦à¦Ÿà¦¾ à¦¯à§‹à¦— à¦•à¦°à¦¬';

  @override
  String get quickAddPreviewTitle => 'à¦¶à¦¿à¦°à§‹à¦¨à¦¾à¦®';

  @override
  String get quickAddPreviewExtracted => 'à¦†à¦®à¦¿ à¦¯à¦¾ à¦¬à§à¦à§‡à¦›à¦¿';

  @override
  String get quickAddSpeechUnavailable =>
      'à¦à¦‡ à¦¡à¦¿à¦­à¦¾à¦‡à¦¸à§‡ à¦­à¦¯à¦¼à§‡à¦¸ à¦‡à¦¨à¦ªà§à¦Ÿ à¦•à¦¾à¦œ à¦•à¦°à¦›à§‡ à¦¨à¦¾à¥¤';

  @override
  String get quickAddVoiceTooltip => 'à¦­à¦¯à¦¼à§‡à¦¸';

  @override
  String get quickAddVoiceUnavailableTooltip =>
      'à¦­à¦¯à¦¼à§‡à¦¸ à¦ªà¦¾à¦“à¦¯à¦¼à¦¾ à¦¯à¦¾à¦šà§à¦›à§‡ à¦¨à¦¾';
}
