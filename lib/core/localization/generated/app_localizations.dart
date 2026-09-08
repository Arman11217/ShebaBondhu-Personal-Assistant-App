import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sheba Bondhu'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Your personal memory assistant.'**
  String get tagline;

  /// No description provided for @taglineBn.
  ///
  /// In en, this message translates to:
  /// **'à¦†à¦ªà¦¨à¦¿ à¦­à§à¦²à¦¬à§‡à¦¨, Sheba Bondhu à¦®à¦¨à§‡ à¦°à¦¾à¦–à¦¬à§‡à¥¤'**
  String get taglineBn;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @severityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get severityCritical;

  /// No description provided for @severityImportant.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get severityImportant;

  /// No description provided for @severityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get severityNormal;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get dueTomorrow;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Today} =1{1 day remaining} other{{count} days remaining}}'**
  String daysRemaining(int count);

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Never forget again'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Money, bills, documents, warranties â€” Sheba Bondhu remembers everything so you don\'t have to.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Just say it'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Speak, type or scan. Our AI understands Bangla and turns your words into smart reminders.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Always one step ahead'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Bondhu learns your habits and warns you before you forget â€” bills, recharges, medicines and more.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your phone number to continue'**
  String get loginSubtitle;

  /// No description provided for @loginPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get loginPhoneHint;

  /// No description provided for @loginSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get loginSendOtp;

  /// No description provided for @loginOtpHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get loginOtpHint;

  /// No description provided for @loginVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get loginVerify;

  /// No description provided for @loginResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get loginResendOtp;

  /// No description provided for @loginChangeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get loginChangeNumber;

  /// No description provided for @loginTermsNotice.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our Terms & Privacy Policy.'**
  String get loginTermsNotice;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeGreetingNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get homeGreetingNight;

  /// No description provided for @homeUserFallback.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get homeUserFallback;

  /// No description provided for @homeSummaryImportant.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 important item today} other{{count} important items today}}'**
  String homeSummaryImportant(int count);

  /// No description provided for @homeSectionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeSectionToday;

  /// No description provided for @homeSectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get homeSectionUpcoming;

  /// No description provided for @homeSectionInsight.
  ///
  /// In en, this message translates to:
  /// **'Bondhu insight'**
  String get homeSectionInsight;

  /// No description provided for @homeEmptyTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing due today'**
  String get homeEmptyTodayTitle;

  /// No description provided for @homeEmptyTodayBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re clear for today â€” enjoy it.'**
  String get homeEmptyTodayBody;

  /// No description provided for @homeEmptyUpcomingTitle.
  ///
  /// In en, this message translates to:
  /// **'No upcoming items'**
  String get homeEmptyUpcomingTitle;

  /// No description provided for @homeEmptyUpcomingBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re ahead of schedule.'**
  String get homeEmptyUpcomingBody;

  /// No description provided for @homeInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'I noticed a pattern'**
  String get homeInsightTitle;

  /// No description provided for @homeInsightBody.
  ///
  /// In en, this message translates to:
  /// **'You usually pay your Electricity Bill around the {day} of each month. Tomorrow might be the day.'**
  String homeInsightBody(String day);

  /// No description provided for @homeInsightActionRemind.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get homeInsightActionRemind;

  /// No description provided for @homeInsightActionDismiss.
  ///
  /// In en, this message translates to:
  /// **'Not this month'**
  String get homeInsightActionDismiss;

  /// No description provided for @homeQuickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'What should I remember?'**
  String get homeQuickAddTitle;

  /// No description provided for @homeQuickAddSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speak, type or scan â€” I\'ll handle the rest.'**
  String get homeQuickAddSubtitle;

  /// No description provided for @homeQuickAddSpeak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get homeQuickAddSpeak;

  /// No description provided for @homeQuickAddType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get homeQuickAddType;

  /// No description provided for @homeQuickAddScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get homeQuickAddScan;

  /// No description provided for @homeQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActionsTitle;

  /// No description provided for @homeQuickMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get homeQuickMoneyTitle;

  /// No description provided for @homeQuickMoneySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track debts & dues'**
  String get homeQuickMoneySubtitle;

  /// No description provided for @homeQuickAddMoneyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add money entry'**
  String get homeQuickAddMoneyTooltip;

  /// No description provided for @homeNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNavHome;

  /// No description provided for @homeNavAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get homeNavAdd;

  /// No description provided for @homeNavMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get homeNavMoney;

  /// No description provided for @homeNavMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get homeNavMore;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @moreSectionModules.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get moreSectionModules;

  /// No description provided for @moreMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Money manager'**
  String get moreMoneyTitle;

  /// No description provided for @moreMoneySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track what you owe and what you\'re owed'**
  String get moreMoneySubtitle;

  /// No description provided for @moreBillsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bill Bondhu'**
  String get moreBillsTitle;

  /// No description provided for @moreBillsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Electricity, gas, internet and more'**
  String get moreBillsSubtitle;

  /// No description provided for @moreDocsTitle.
  ///
  /// In en, this message translates to:
  /// **'Kagoj Bondhu'**
  String get moreDocsTitle;

  /// No description provided for @moreDocsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Document expiry alerts'**
  String get moreDocsSubtitle;

  /// No description provided for @moreWarrantyTitle.
  ///
  /// In en, this message translates to:
  /// **'Warranty Bondhu'**
  String get moreWarrantyTitle;

  /// No description provided for @moreWarrantySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track invoices and warranties'**
  String get moreWarrantySubtitle;

  /// No description provided for @moreMedicineTitle.
  ///
  /// In en, this message translates to:
  /// **'Medicine Bondhu'**
  String get moreMedicineTitle;

  /// No description provided for @moreMedicineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Family medicine inventory'**
  String get moreMedicineSubtitle;

  /// No description provided for @moreRechargeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recharge Bondhu'**
  String get moreRechargeTitle;

  /// No description provided for @moreRechargeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Family SIMs and packages'**
  String get moreRechargeSubtitle;

  /// No description provided for @moreFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Bondhu'**
  String get moreFamilyTitle;

  /// No description provided for @moreFamilySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shared tasks and reminders'**
  String get moreFamilySubtitle;

  /// No description provided for @moreCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get moreCalendarTitle;

  /// No description provided for @moreCalendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All your events in one view'**
  String get moreCalendarSubtitle;

  /// No description provided for @moreTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get moreTasksTitle;

  /// No description provided for @moreTasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assignments and todos'**
  String get moreTasksSubtitle;

  /// No description provided for @moreAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get moreAnalyticsTitle;

  /// No description provided for @moreAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly insights'**
  String get moreAnalyticsSubtitle;

  /// No description provided for @moreSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get moreSectionAccount;

  /// No description provided for @moreSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get moreSettings;

  /// No description provided for @moreHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & feedback'**
  String get moreHelp;

  /// No description provided for @moreAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get moreAbout;

  /// No description provided for @catMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get catMoney;

  /// No description provided for @catBill.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get catBill;

  /// No description provided for @catDocument.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get catDocument;

  /// No description provided for @catWarranty.
  ///
  /// In en, this message translates to:
  /// **'Warranty'**
  String get catWarranty;

  /// No description provided for @catMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get catMedicine;

  /// No description provided for @catRecharge.
  ///
  /// In en, this message translates to:
  /// **'Recharge'**
  String get catRecharge;

  /// No description provided for @catAppointment.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get catAppointment;

  /// No description provided for @catTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get catTask;

  /// No description provided for @moneyToReceive.
  ///
  /// In en, this message translates to:
  /// **'To receive'**
  String get moneyToReceive;

  /// No description provided for @moneyToPay.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get moneyToPay;

  /// No description provided for @moneyPerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get moneyPerson;

  /// No description provided for @moneyAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get moneyAmount;

  /// No description provided for @moneyDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get moneyDue;

  /// No description provided for @moneyTotalReceive.
  ///
  /// In en, this message translates to:
  /// **'You will receive: {amount}'**
  String moneyTotalReceive(String amount);

  /// No description provided for @moneyTotalPay.
  ///
  /// In en, this message translates to:
  /// **'You need to pay: {amount}'**
  String moneyTotalPay(String amount);

  /// No description provided for @actionSendReminder.
  ///
  /// In en, this message translates to:
  /// **'Send reminder'**
  String get actionSendReminder;

  /// No description provided for @moneyListTitle.
  ///
  /// In en, this message translates to:
  /// **'Money manager'**
  String get moneyListTitle;

  /// No description provided for @moneyListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get moneyListEmptyTitle;

  /// No description provided for @moneyListEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add what you owe or are owed.'**
  String get moneyListEmptyBody;

  /// No description provided for @moneySectionReceive.
  ///
  /// In en, this message translates to:
  /// **'To receive'**
  String get moneySectionReceive;

  /// No description provided for @moneySectionPay.
  ///
  /// In en, this message translates to:
  /// **'To pay'**
  String get moneySectionPay;

  /// No description provided for @moneyAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get moneyAddTitle;

  /// No description provided for @moneyEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get moneyEditTitle;

  /// No description provided for @moneyFieldPerson.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get moneyFieldPerson;

  /// No description provided for @moneyFieldPersonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Rakib'**
  String get moneyFieldPersonHint;

  /// No description provided for @moneyFieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get moneyFieldAmount;

  /// No description provided for @moneyFieldAmountHint.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get moneyFieldAmountHint;

  /// No description provided for @moneyFieldDue.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get moneyFieldDue;

  /// No description provided for @moneyFieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get moneyFieldNote;

  /// No description provided for @moneyFieldNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Anything to rememberâ€¦'**
  String get moneyFieldNoteHint;

  /// No description provided for @moneyFieldRecurring.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get moneyFieldRecurring;

  /// No description provided for @moneyFieldDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get moneyFieldDirection;

  /// No description provided for @dueLabelPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get dueLabelPickDate;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteConfirmBody;

  /// No description provided for @recurringNone.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get recurringNone;

  /// No description provided for @recurringDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurringDaily;

  /// No description provided for @recurringWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurringWeekly;

  /// No description provided for @recurringMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurringMonthly;

  /// No description provided for @recurringYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get recurringYearly;

  /// No description provided for @billListTitle.
  ///
  /// In en, this message translates to:
  /// **'Bill Bondhu'**
  String get billListTitle;

  /// No description provided for @billListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No bills yet'**
  String get billListEmptyTitle;

  /// No description provided for @billListEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your electricity, gas, internet and other monthly bills so Bondhu can remind you before the due date.'**
  String get billListEmptyBody;

  /// No description provided for @billListTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total monthly'**
  String get billListTotalLabel;

  /// No description provided for @billListPaidCount.
  ///
  /// In en, this message translates to:
  /// **'{paid} of {total} scheduled automatically'**
  String billListPaidCount(int paid, int total);

  /// No description provided for @billSectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Due soon'**
  String get billSectionUpcoming;

  /// No description provided for @billSectionLater.
  ///
  /// In en, this message translates to:
  /// **'Later this month'**
  String get billSectionLater;

  /// No description provided for @billAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New bill'**
  String get billAddTitle;

  /// No description provided for @billEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit bill'**
  String get billEditTitle;

  /// No description provided for @billFieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get billFieldType;

  /// No description provided for @billFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get billFieldLabel;

  /// No description provided for @billFieldLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home electricity'**
  String get billFieldLabelHint;

  /// No description provided for @billFieldProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get billFieldProvider;

  /// No description provided for @billFieldProviderHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. DESCO'**
  String get billFieldProviderHint;

  /// No description provided for @billFieldAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get billFieldAmount;

  /// No description provided for @billFieldAmountHint.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get billFieldAmountHint;

  /// No description provided for @billFieldNextDue.
  ///
  /// In en, this message translates to:
  /// **'Next due date'**
  String get billFieldNextDue;

  /// No description provided for @billFieldRecurring.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get billFieldRecurring;

  /// No description provided for @billFieldSeverity.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get billFieldSeverity;

  /// No description provided for @billFieldAutoPay.
  ///
  /// In en, this message translates to:
  /// **'Auto-pay enabled'**
  String get billFieldAutoPay;

  /// No description provided for @billFieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get billFieldNote;

  /// No description provided for @billFieldNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Account no., meter no., etc.'**
  String get billFieldNoteHint;

  /// No description provided for @billTypeElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get billTypeElectricity;

  /// No description provided for @billTypeGas.
  ///
  /// In en, this message translates to:
  /// **'Gas'**
  String get billTypeGas;

  /// No description provided for @billTypeWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get billTypeWater;

  /// No description provided for @billTypeInternet.
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get billTypeInternet;

  /// No description provided for @billTypeTv.
  ///
  /// In en, this message translates to:
  /// **'Cable TV'**
  String get billTypeTv;

  /// No description provided for @billTypeMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get billTypeMobile;

  /// No description provided for @billTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get billTypeOther;

  /// No description provided for @docsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Bondhu'**
  String get docsListTitle;

  /// No description provided for @docsListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get docsListEmptyTitle;

  /// No description provided for @docsListEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add NID, passport, driving license and certificates so Bondhu can remind you before they expire.'**
  String get docsListEmptyBody;

  /// No description provided for @docsListExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get docsListExpiringSoon;

  /// No description provided for @docsListValid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get docsListValid;

  /// No description provided for @docsListExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get docsListExpired;

  /// No description provided for @docsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New document'**
  String get docsAddTitle;

  /// No description provided for @docsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit document'**
  String get docsEditTitle;

  /// No description provided for @docsFieldType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get docsFieldType;

  /// No description provided for @docsFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get docsFieldLabel;

  /// No description provided for @docsFieldLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home NID'**
  String get docsFieldLabelHint;

  /// No description provided for @docsFieldNumber.
  ///
  /// In en, this message translates to:
  /// **'Document number (optional)'**
  String get docsFieldNumber;

  /// No description provided for @docsFieldNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 199012345678'**
  String get docsFieldNumberHint;

  /// No description provided for @docsFieldIssuer.
  ///
  /// In en, this message translates to:
  /// **'Issuer (optional)'**
  String get docsFieldIssuer;

  /// No description provided for @docsFieldIssuerHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. BRTA'**
  String get docsFieldIssuerHint;

  /// No description provided for @docsFieldIssueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue date'**
  String get docsFieldIssueDate;

  /// No description provided for @docsFieldExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get docsFieldExpiryDate;

  /// No description provided for @docsFieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get docsFieldNote;

  /// No description provided for @docsFieldNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Anything to remember'**
  String get docsFieldNoteHint;

  /// No description provided for @docsExpiredBadge.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get docsExpiredBadge;

  /// No description provided for @docsExpiringIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String docsExpiringIn(int days);

  /// No description provided for @docsExpiredOn.
  ///
  /// In en, this message translates to:
  /// **'Expired on {date}'**
  String docsExpiredOn(String date);

  /// No description provided for @docTypeNid.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get docTypeNid;

  /// No description provided for @docTypePassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get docTypePassport;

  /// No description provided for @docTypeDrivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get docTypeDrivingLicense;

  /// No description provided for @docTypeVehicleFitness.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Fitness'**
  String get docTypeVehicleFitness;

  /// No description provided for @docTypeTradeLicense.
  ///
  /// In en, this message translates to:
  /// **'Trade License'**
  String get docTypeTradeLicense;

  /// No description provided for @docTypeBankCard.
  ///
  /// In en, this message translates to:
  /// **'Bank Card'**
  String get docTypeBankCard;

  /// No description provided for @docTypeInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get docTypeInsurance;

  /// No description provided for @docTypeCertificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get docTypeCertificate;

  /// No description provided for @docTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get docTypeOther;

  /// No description provided for @medListTitle.
  ///
  /// In en, this message translates to:
  /// **'Medicine Bondhu'**
  String get medListTitle;

  /// No description provided for @medListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No medicines yet'**
  String get medListEmptyTitle;

  /// No description provided for @medListEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the medicines your family uses so Bondhu can remind you before they run out.'**
  String get medListEmptyBody;

  /// No description provided for @medListTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Medicines in stock'**
  String get medListTotalLabel;

  /// No description provided for @medListLowStockCount.
  ///
  /// In en, this message translates to:
  /// **'{low} of {total} running low'**
  String medListLowStockCount(int low, int total);

  /// No description provided for @medSectionLowStock.
  ///
  /// In en, this message translates to:
  /// **'Running low'**
  String get medSectionLowStock;

  /// No description provided for @medSectionActive.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get medSectionActive;

  /// No description provided for @medAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New medicine'**
  String get medAddTitle;

  /// No description provided for @medEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit medicine'**
  String get medEditTitle;

  /// No description provided for @medFieldName.
  ///
  /// In en, this message translates to:
  /// **'Medicine name'**
  String get medFieldName;

  /// No description provided for @medFieldNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Napa 500mg'**
  String get medFieldNameHint;

  /// No description provided for @medFieldMember.
  ///
  /// In en, this message translates to:
  /// **'For'**
  String get medFieldMember;

  /// No description provided for @medFieldMemberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Self, Father, Mother'**
  String get medFieldMemberHint;

  /// No description provided for @medFieldDose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get medFieldDose;

  /// No description provided for @medFieldDoseHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1 tablet, 5 ml'**
  String get medFieldDoseHint;

  /// No description provided for @medFieldFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get medFieldFrequency;

  /// No description provided for @medFieldSlots.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get medFieldSlots;

  /// No description provided for @medFieldStartDate.
  ///
  /// In en, this message translates to:
  /// **'Started on'**
  String get medFieldStartDate;

  /// No description provided for @medFieldEndDate.
  ///
  /// In en, this message translates to:
  /// **'Course ends on (optional)'**
  String get medFieldEndDate;

  /// No description provided for @medFieldRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining units'**
  String get medFieldRemaining;

  /// No description provided for @medFieldRemainingHint.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get medFieldRemainingHint;

  /// No description provided for @medFieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get medFieldNote;

  /// No description provided for @medFieldNoteHint.
  ///
  /// In en, this message translates to:
  /// **'After meal, before bed, etc.'**
  String get medFieldNoteHint;

  /// No description provided for @medFrequencyOnceDaily.
  ///
  /// In en, this message translates to:
  /// **'Once a day'**
  String get medFrequencyOnceDaily;

  /// No description provided for @medFrequencyTwiceDaily.
  ///
  /// In en, this message translates to:
  /// **'Twice a day'**
  String get medFrequencyTwiceDaily;

  /// No description provided for @medFrequencyThriceDaily.
  ///
  /// In en, this message translates to:
  /// **'Three times a day'**
  String get medFrequencyThriceDaily;

  /// No description provided for @medFrequencyFourTimesDaily.
  ///
  /// In en, this message translates to:
  /// **'Four times a day'**
  String get medFrequencyFourTimesDaily;

  /// No description provided for @medFrequencyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get medFrequencyWeekly;

  /// No description provided for @medFrequencyAsNeeded.
  ///
  /// In en, this message translates to:
  /// **'As needed'**
  String get medFrequencyAsNeeded;

  /// No description provided for @medSlotMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get medSlotMorning;

  /// No description provided for @medSlotAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get medSlotAfternoon;

  /// No description provided for @medSlotEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get medSlotEvening;

  /// No description provided for @medSlotNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get medSlotNight;

  /// No description provided for @medStockBadge.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Runs out today} =1{1 day left} other{{days} days left}}'**
  String medStockBadge(int days);

  /// No description provided for @medUnitsLeft.
  ///
  /// In en, this message translates to:
  /// **'{units} units'**
  String medUnitsLeft(int units);

  /// No description provided for @simListTitle.
  ///
  /// In en, this message translates to:
  /// **'Recharge Bondhu'**
  String get simListTitle;

  /// No description provided for @simListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No SIMs yet'**
  String get simListEmptyTitle;

  /// No description provided for @simListEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the SIMs your family uses so Bondhu can warn you when a package is about to expire.'**
  String get simListEmptyBody;

  /// No description provided for @simListTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'SIMs tracked'**
  String get simListTotalLabel;

  /// No description provided for @simListAttentionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 needs attention} other{{count} need attention}}'**
  String simListAttentionCount(int count);

  /// No description provided for @simSectionAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get simSectionAttention;

  /// No description provided for @simSectionActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get simSectionActive;

  /// No description provided for @simAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New SIM'**
  String get simAddTitle;

  /// No description provided for @simEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit SIM'**
  String get simEditTitle;

  /// No description provided for @simFieldCarrier.
  ///
  /// In en, this message translates to:
  /// **'Carrier'**
  String get simFieldCarrier;

  /// No description provided for @simFieldMember.
  ///
  /// In en, this message translates to:
  /// **'For'**
  String get simFieldMember;

  /// No description provided for @simFieldMemberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Self, Father'**
  String get simFieldMemberHint;

  /// No description provided for @simFieldNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get simFieldNumber;

  /// No description provided for @simFieldNumberHint.
  ///
  /// In en, this message translates to:
  /// **'+8801XXXXXXXXX'**
  String get simFieldNumberHint;

  /// No description provided for @simFieldLastRecharge.
  ///
  /// In en, this message translates to:
  /// **'Last recharge date'**
  String get simFieldLastRecharge;

  /// No description provided for @simFieldRechargeAmount.
  ///
  /// In en, this message translates to:
  /// **'Recharge amount'**
  String get simFieldRechargeAmount;

  /// No description provided for @simFieldValidityDays.
  ///
  /// In en, this message translates to:
  /// **'Validity (days)'**
  String get simFieldValidityDays;

  /// No description provided for @simFieldDataBalance.
  ///
  /// In en, this message translates to:
  /// **'Remaining data (GB, optional)'**
  String get simFieldDataBalance;

  /// No description provided for @simFieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get simFieldNote;

  /// No description provided for @simFieldNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Package name, owner, etc.'**
  String get simFieldNoteHint;

  /// No description provided for @simCarrierGrameenphone.
  ///
  /// In en, this message translates to:
  /// **'Grameenphone'**
  String get simCarrierGrameenphone;

  /// No description provided for @simCarrierRobi.
  ///
  /// In en, this message translates to:
  /// **'Robi'**
  String get simCarrierRobi;

  /// No description provided for @simCarrierAirtel.
  ///
  /// In en, this message translates to:
  /// **'Cirkle'**
  String get simCarrierAirtel;

  /// No description provided for @simCarrierBanglalink.
  ///
  /// In en, this message translates to:
  /// **'Banglalink'**
  String get simCarrierBanglalink;

  /// No description provided for @simCarrierTeletalk.
  ///
  /// In en, this message translates to:
  /// **'Teletalk'**
  String get simCarrierTeletalk;

  /// No description provided for @simCarrierOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get simCarrierOther;

  /// No description provided for @simStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get simStatusActive;

  /// No description provided for @simStatusDataLow.
  ///
  /// In en, this message translates to:
  /// **'Data low'**
  String get simStatusDataLow;

  /// No description provided for @simStatusPackageExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Package expiring soon'**
  String get simStatusPackageExpiringSoon;

  /// No description provided for @simStatusNeedsRecharge.
  ///
  /// In en, this message translates to:
  /// **'Recharge recommended'**
  String get simStatusNeedsRecharge;

  /// No description provided for @simDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{recharged today} =1{1 day ago} other{{days} days ago}}'**
  String simDaysAgo(int days);

  /// No description provided for @simValidityDays.
  ///
  /// In en, this message translates to:
  /// **'{days}-day package'**
  String simValidityDays(int days);

  /// No description provided for @simDataBalance.
  ///
  /// In en, this message translates to:
  /// **'{amount} GB left'**
  String simDataBalance(String amount);

  /// No description provided for @simPackageExpires.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Expires today} =1{Expires in 1 day} other{Expires in {days} days}}'**
  String simPackageExpires(int days);

  /// No description provided for @simPackageExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired {days, plural, =0{today} =1{1 day ago} other{{days} days ago}}'**
  String simPackageExpired(int days);

  /// No description provided for @simNoRecharge.
  ///
  /// In en, this message translates to:
  /// **'No recharge recorded'**
  String get simNoRecharge;

  /// No description provided for @simMarkAsRecharged.
  ///
  /// In en, this message translates to:
  /// **'Mark as recharged'**
  String get simMarkAsRecharged;

  /// No description provided for @warrantyListTitle.
  ///
  /// In en, this message translates to:
  /// **'Warranty Bondhu'**
  String get warrantyListTitle;

  /// No description provided for @warrantyListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No warranties yet'**
  String get warrantyListEmptyTitle;

  /// No description provided for @warrantyListEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add products under warranty so Bondhu can remind you before the coverage runs out.'**
  String get warrantyListEmptyBody;

  /// No description provided for @warrantyListTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Warranties tracked'**
  String get warrantyListTotalLabel;

  /// No description provided for @warrantyAttentionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 needs attention} other{{count} need attention}}'**
  String warrantyAttentionCount(int count);

  /// No description provided for @warrantySectionExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get warrantySectionExpired;

  /// No description provided for @warrantySectionExpiring.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get warrantySectionExpiring;

  /// No description provided for @warrantySectionActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get warrantySectionActive;

  /// No description provided for @warrantyAddTitle.
  ///
  /// In en, this message translates to:
  /// **'New warranty'**
  String get warrantyAddTitle;

  /// No description provided for @warrantyEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit warranty'**
  String get warrantyEditTitle;

  /// No description provided for @warrantyFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get warrantyFieldCategory;

  /// No description provided for @warrantyFieldBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get warrantyFieldBrand;

  /// No description provided for @warrantyFieldProductName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get warrantyFieldProductName;

  /// No description provided for @warrantyFieldProductNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Smart TV 43 inch'**
  String get warrantyFieldProductNameHint;

  /// No description provided for @warrantyFieldVendor.
  ///
  /// In en, this message translates to:
  /// **'Shop / vendor (optional)'**
  String get warrantyFieldVendor;

  /// No description provided for @warrantyFieldVendorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. RCY Electronics'**
  String get warrantyFieldVendorHint;

  /// No description provided for @warrantyFieldPrice.
  ///
  /// In en, this message translates to:
  /// **'Price (optional)'**
  String get warrantyFieldPrice;

  /// No description provided for @warrantyFieldPurchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase date'**
  String get warrantyFieldPurchaseDate;

  /// No description provided for @warrantyFieldExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Warranty expires on'**
  String get warrantyFieldExpiryDate;

  /// No description provided for @warrantyFieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get warrantyFieldNote;

  /// No description provided for @warrantyFieldNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Model number, serial, etc.'**
  String get warrantyFieldNoteHint;

  /// No description provided for @warrantyCategoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get warrantyCategoryElectronics;

  /// No description provided for @warrantyCategoryAppliance.
  ///
  /// In en, this message translates to:
  /// **'Appliance'**
  String get warrantyCategoryAppliance;

  /// No description provided for @warrantyCategoryFurniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get warrantyCategoryFurniture;

  /// No description provided for @warrantyCategoryVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get warrantyCategoryVehicle;

  /// No description provided for @warrantyCategoryJewellery.
  ///
  /// In en, this message translates to:
  /// **'Jewellery'**
  String get warrantyCategoryJewellery;

  /// No description provided for @warrantyCategoryClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get warrantyCategoryClothing;

  /// No description provided for @warrantyCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get warrantyCategoryOther;

  /// No description provided for @warrantyStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get warrantyStatusActive;

  /// No description provided for @warrantyStatusExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get warrantyStatusExpiringSoon;

  /// No description provided for @warrantyStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get warrantyStatusExpired;

  /// No description provided for @warrantyDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Expires today} =1{1 day left} other{{days} days left}}'**
  String warrantyDaysLeft(int days);

  /// No description provided for @warrantyExpiredDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Expired {days, plural, =1{1 day ago} other{{days} days ago}}'**
  String warrantyExpiredDaysAgo(int days);

  /// No description provided for @familyListTitle.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get familyListTitle;

  /// No description provided for @familyAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add family member'**
  String get familyAddTitle;

  /// No description provided for @familyEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit family member'**
  String get familyEditTitle;

  /// No description provided for @familyListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No family members yet'**
  String get familyListEmptyTitle;

  /// No description provided for @familyListEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your family to keep track of blood groups, phones and IDs.'**
  String get familyListEmptyBody;

  /// No description provided for @familyListTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Family members'**
  String get familyListTotalLabel;

  /// No description provided for @familySummaryMembers.
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get familySummaryMembers;

  /// No description provided for @familyFieldRelation.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get familyFieldRelation;

  /// No description provided for @familyFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get familyFieldName;

  /// No description provided for @familyFieldNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get familyFieldNameHint;

  /// No description provided for @familyFieldBloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood group'**
  String get familyFieldBloodGroup;

  /// No description provided for @familyFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get familyFieldPhone;

  /// No description provided for @familyFieldPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'01XXXXXXXXX'**
  String get familyFieldPhoneHint;

  /// No description provided for @familyFieldNid.
  ///
  /// In en, this message translates to:
  /// **'National ID (optional)'**
  String get familyFieldNid;

  /// No description provided for @familyFieldNidHint.
  ///
  /// In en, this message translates to:
  /// **'10/13/17 digit NID'**
  String get familyFieldNidHint;

  /// No description provided for @familyFieldBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth (optional)'**
  String get familyFieldBirthDate;

  /// No description provided for @familyFieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get familyFieldNote;

  /// No description provided for @familyFieldNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Occupation, address, anything to remember'**
  String get familyFieldNoteHint;

  /// No description provided for @familyRelationSelf.
  ///
  /// In en, this message translates to:
  /// **'Self'**
  String get familyRelationSelf;

  /// No description provided for @familyRelationSpouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get familyRelationSpouse;

  /// No description provided for @familyRelationFather.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get familyRelationFather;

  /// No description provided for @familyRelationMother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get familyRelationMother;

  /// No description provided for @familyRelationSon.
  ///
  /// In en, this message translates to:
  /// **'Son'**
  String get familyRelationSon;

  /// No description provided for @familyRelationDaughter.
  ///
  /// In en, this message translates to:
  /// **'Daughter'**
  String get familyRelationDaughter;

  /// No description provided for @familyRelationBrother.
  ///
  /// In en, this message translates to:
  /// **'Brother'**
  String get familyRelationBrother;

  /// No description provided for @familyRelationSister.
  ///
  /// In en, this message translates to:
  /// **'Sister'**
  String get familyRelationSister;

  /// No description provided for @familyRelationGrandfather.
  ///
  /// In en, this message translates to:
  /// **'Grandfather'**
  String get familyRelationGrandfather;

  /// No description provided for @familyRelationGrandmother.
  ///
  /// In en, this message translates to:
  /// **'Grandmother'**
  String get familyRelationGrandmother;

  /// No description provided for @familyRelationOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get familyRelationOther;

  /// No description provided for @familyAgeYears.
  ///
  /// In en, this message translates to:
  /// **'{age, plural, =1{1 yr} other{{age} yrs}}'**
  String familyAgeYears(int age);

  /// No description provided for @dueLabelClearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get dueLabelClearDate;

  /// No description provided for @taskListTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get taskListTitle;

  /// No description provided for @taskAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get taskAddTitle;

  /// No description provided for @taskEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get taskEditTitle;

  /// No description provided for @taskListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing on the list'**
  String get taskListEmptyTitle;

  /// No description provided for @taskListEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a task to keep track of errands, calls and deadlines.'**
  String get taskListEmptyBody;

  /// No description provided for @taskSummaryHeadline.
  ///
  /// In en, this message translates to:
  /// **'Open tasks'**
  String get taskSummaryHeadline;

  /// No description provided for @taskSummaryPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'pending'**
  String get taskSummaryPendingLabel;

  /// No description provided for @taskSummaryDoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get taskSummaryDoneLabel;

  /// No description provided for @taskSummaryOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overdue} other{{count} overdue}}'**
  String taskSummaryOverdue(int count);

  /// No description provided for @taskSectionPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get taskSectionPending;

  /// No description provided for @taskSectionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get taskSectionDone;

  /// No description provided for @taskAllDoneBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up. Add a new task to stay ahead.'**
  String get taskAllDoneBanner;

  /// No description provided for @taskFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskFieldTitle;

  /// No description provided for @taskFieldTitleHint.
  ///
  /// In en, this message translates to:
  /// **'What needs to be done?'**
  String get taskFieldTitleHint;

  /// No description provided for @taskFieldPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get taskFieldPriority;

  /// No description provided for @taskFieldDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date (optional)'**
  String get taskFieldDueDate;

  /// No description provided for @taskFieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get taskFieldNote;

  /// No description provided for @taskFieldNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Any extra details'**
  String get taskFieldNoteHint;

  /// No description provided for @taskFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get taskFieldStatus;

  /// No description provided for @taskStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get taskStatusPending;

  /// No description provided for @taskStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get taskStatusDone;

  /// No description provided for @taskStatusPendingHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the switch when you finish it.'**
  String get taskStatusPendingHint;

  /// No description provided for @taskStatusDoneHint.
  ///
  /// In en, this message translates to:
  /// **'Toggle off to bring it back to the pending list.'**
  String get taskStatusDoneHint;

  /// No description provided for @taskPriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get taskPriorityHigh;

  /// No description provided for @taskPriorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get taskPriorityNormal;

  /// No description provided for @taskPriorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get taskPriorityLow;

  /// No description provided for @taskDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get taskDueToday;

  /// No description provided for @taskDueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due tomorrow'**
  String get taskDueTomorrow;

  /// No description provided for @taskDueIn.
  ///
  /// In en, this message translates to:
  /// **'Due in {days, plural, =1{1 day} other{{days} days}}'**
  String taskDueIn(int days);

  /// No description provided for @taskOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue by {days, plural, =1{1 day} other{{days} days}}'**
  String taskOverdue(int days);

  /// No description provided for @taskCompletedOnDate.
  ///
  /// In en, this message translates to:
  /// **'Completed {days}d ago'**
  String taskCompletedOnDate(int days);

  /// No description provided for @quickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAddTitle;

  /// No description provided for @quickAddParseButton.
  ///
  /// In en, this message translates to:
  /// **'Find the right place'**
  String get quickAddParseButton;

  /// No description provided for @quickAddGoButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get quickAddGoButton;

  /// No description provided for @quickAddExamplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Try saying'**
  String get quickAddExamplesTitle;

  /// No description provided for @quickAddHintMoney.
  ///
  /// In en, this message translates to:
  /// **'Rahim owes me 500 taka'**
  String get quickAddHintMoney;

  /// No description provided for @quickAddHintBill.
  ///
  /// In en, this message translates to:
  /// **'Electricity bill 1200 due tomorrow'**
  String get quickAddHintBill;

  /// No description provided for @quickAddHintTask.
  ///
  /// In en, this message translates to:
  /// **'Pick up parcel in 3 days'**
  String get quickAddHintTask;

  /// No description provided for @quickAddHintFamily.
  ///
  /// In en, this message translates to:
  /// **'Mom\'s birthday next week'**
  String get quickAddHintFamily;

  /// No description provided for @quickAddIntentMoney.
  ///
  /// In en, this message translates to:
  /// **'Money manager'**
  String get quickAddIntentMoney;

  /// No description provided for @quickAddIntentBill.
  ///
  /// In en, this message translates to:
  /// **'Bill Bondhu'**
  String get quickAddIntentBill;

  /// No description provided for @quickAddIntentDocument.
  ///
  /// In en, this message translates to:
  /// **'Kagoj Bondhu'**
  String get quickAddIntentDocument;

  /// No description provided for @quickAddIntentWarranty.
  ///
  /// In en, this message translates to:
  /// **'Warranty Bondhu'**
  String get quickAddIntentWarranty;

  /// No description provided for @quickAddIntentMedicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine Bondhu'**
  String get quickAddIntentMedicine;

  /// No description provided for @quickAddIntentSim.
  ///
  /// In en, this message translates to:
  /// **'Recharge Bondhu'**
  String get quickAddIntentSim;

  /// No description provided for @quickAddIntentFamily.
  ///
  /// In en, this message translates to:
  /// **'Family Bondhu'**
  String get quickAddIntentFamily;

  /// No description provided for @quickAddIntentTask.
  ///
  /// In en, this message translates to:
  /// **'Tasks Bondhu'**
  String get quickAddIntentTask;

  /// No description provided for @quickAddPreviewDestination.
  ///
  /// In en, this message translates to:
  /// **'I will add this to'**
  String get quickAddPreviewDestination;

  /// No description provided for @quickAddPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get quickAddPreviewTitle;

  /// No description provided for @quickAddPreviewExtracted.
  ///
  /// In en, this message translates to:
  /// **'What I picked up'**
  String get quickAddPreviewExtracted;

  /// No description provided for @quickAddSpeechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition not available on this device.'**
  String get quickAddSpeechUnavailable;

  /// No description provided for @quickAddVoiceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get quickAddVoiceTooltip;

  /// No description provided for @quickAddVoiceUnavailableTooltip.
  ///
  /// In en, this message translates to:
  /// **'Voice unavailable'**
  String get quickAddVoiceUnavailableTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
