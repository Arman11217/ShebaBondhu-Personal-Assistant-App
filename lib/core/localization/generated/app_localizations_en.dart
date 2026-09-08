// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sheba Bondhu';

  @override
  String get tagline => 'Your personal memory assistant.';

  @override
  String get taglineBn =>
      'à¦†à¦ªà¦¨à¦¿ à¦­à§à¦²à¦¬à§‡à¦¨, Sheba Bondhu à¦®à¦¨à§‡ à¦°à¦¾à¦–à¦¬à§‡à¥¤';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDone => 'Done';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonSearch => 'Search';

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
      'Money, bills, documents, warranties â€” Sheba Bondhu remembers everything so you don\'t have to.';

  @override
  String get onboardingTitle2 => 'Just say it';

  @override
  String get onboardingDesc2 =>
      'Speak, type or scan. Our AI understands Bangla and turns your words into smart reminders.';

  @override
  String get onboardingTitle3 => 'Always one step ahead';

  @override
  String get onboardingDesc3 =>
      'Bondhu learns your habits and warns you before you forget â€” bills, recharges, medicines and more.';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in with your phone number to continue';

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
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeGreetingNight => 'Good night';

  @override
  String get homeUserFallback => 'there';

  @override
  String homeSummaryImportant(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count important items today',
      one: '1 important item today',
    );
    return '$_temp0';
  }

  @override
  String get homeSectionToday => 'Today';

  @override
  String get homeSectionUpcoming => 'Upcoming';

  @override
  String get homeSectionInsight => 'Bondhu insight';

  @override
  String get homeEmptyTodayTitle => 'Nothing due today';

  @override
  String get homeEmptyTodayBody => 'You\'re clear for today â€” enjoy it.';

  @override
  String get homeEmptyUpcomingTitle => 'No upcoming items';

  @override
  String get homeEmptyUpcomingBody => 'You\'re ahead of schedule.';

  @override
  String get homeInsightTitle => 'I noticed a pattern';

  @override
  String homeInsightBody(String day) {
    return 'You usually pay your Electricity Bill around the $day of each month. Tomorrow might be the day.';
  }

  @override
  String get homeInsightActionRemind => 'Remind me';

  @override
  String get homeInsightActionDismiss => 'Not this month';

  @override
  String get homeQuickAddTitle => 'What should I remember?';

  @override
  String get homeQuickAddSubtitle =>
      'Speak, type or scan â€” I\'ll handle the rest.';

  @override
  String get homeQuickAddSpeak => 'Speak';

  @override
  String get homeQuickAddType => 'Type';

  @override
  String get homeQuickAddScan => 'Scan';

  @override
  String get homeQuickActionsTitle => 'Quick actions';

  @override
  String get homeQuickMoneyTitle => 'Money';

  @override
  String get homeQuickMoneySubtitle => 'Track debts & dues';

  @override
  String get homeQuickAddMoneyTooltip => 'Add money entry';

  @override
  String get homeNavHome => 'Home';

  @override
  String get homeNavAdd => 'Add';

  @override
  String get homeNavMoney => 'Money';

  @override
  String get homeNavMore => 'More';

  @override
  String get moreTitle => 'More';

  @override
  String get moreSectionModules => 'Modules';

  @override
  String get moreMoneyTitle => 'Money manager';

  @override
  String get moreMoneySubtitle => 'Track what you owe and what you\'re owed';

  @override
  String get moreBillsTitle => 'Bill Bondhu';

  @override
  String get moreBillsSubtitle => 'Electricity, gas, internet and more';

  @override
  String get moreDocsTitle => 'Kagoj Bondhu';

  @override
  String get moreDocsSubtitle => 'Document expiry alerts';

  @override
  String get moreWarrantyTitle => 'Warranty Bondhu';

  @override
  String get moreWarrantySubtitle => 'Track invoices and warranties';

  @override
  String get moreMedicineTitle => 'Medicine Bondhu';

  @override
  String get moreMedicineSubtitle => 'Family medicine inventory';

  @override
  String get moreRechargeTitle => 'Recharge Bondhu';

  @override
  String get moreRechargeSubtitle => 'Family SIMs and packages';

  @override
  String get moreFamilyTitle => 'Family Bondhu';

  @override
  String get moreFamilySubtitle => 'Shared tasks and reminders';

  @override
  String get moreCalendarTitle => 'Calendar';

  @override
  String get moreCalendarSubtitle => 'All your events in one view';

  @override
  String get moreTasksTitle => 'Tasks';

  @override
  String get moreTasksSubtitle => 'Assignments and todos';

  @override
  String get moreAnalyticsTitle => 'Dashboard';

  @override
  String get moreAnalyticsSubtitle => 'Monthly insights';

  @override
  String get moreSectionAccount => 'Account';

  @override
  String get moreSettings => 'Settings';

  @override
  String get moreHelp => 'Help & feedback';

  @override
  String get moreAbout => 'About';

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
  String get actionSendReminder => 'Send reminder';

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
  String get moneyFieldNoteHint => 'Anything to rememberâ€¦';

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
  String get familyRelationSelf => 'Self';

  @override
  String get familyRelationSpouse => 'Spouse';

  @override
  String get familyRelationFather => 'Father';

  @override
  String get familyRelationMother => 'Mother';

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
  String get familyRelationOther => 'Other';

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
  String get quickAddTitle => 'Quick Add';

  @override
  String get quickAddParseButton => 'Find the right place';

  @override
  String get quickAddGoButton => 'Continue';

  @override
  String get quickAddExamplesTitle => 'Try saying';

  @override
  String get quickAddHintMoney => 'Rahim owes me 500 taka';

  @override
  String get quickAddHintBill => 'Electricity bill 1200 due tomorrow';

  @override
  String get quickAddHintTask => 'Pick up parcel in 3 days';

  @override
  String get quickAddHintFamily => 'Mom\'s birthday next week';

  @override
  String get quickAddIntentMoney => 'Money manager';

  @override
  String get quickAddIntentBill => 'Bill Bondhu';

  @override
  String get quickAddIntentDocument => 'Kagoj Bondhu';

  @override
  String get quickAddIntentWarranty => 'Warranty Bondhu';

  @override
  String get quickAddIntentMedicine => 'Medicine Bondhu';

  @override
  String get quickAddIntentSim => 'Recharge Bondhu';

  @override
  String get quickAddIntentFamily => 'Family Bondhu';

  @override
  String get quickAddIntentTask => 'Tasks Bondhu';

  @override
  String get quickAddPreviewDestination => 'I will add this to';

  @override
  String get quickAddPreviewTitle => 'Title';

  @override
  String get quickAddPreviewExtracted => 'What I picked up';

  @override
  String get quickAddSpeechUnavailable =>
      'Speech recognition not available on this device.';

  @override
  String get quickAddVoiceTooltip => 'Voice';

  @override
  String get quickAddVoiceUnavailableTooltip => 'Voice unavailable';
}
