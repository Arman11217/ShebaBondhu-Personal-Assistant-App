/// Centralized configuration constants for bdapps integration.
/// Contains all official endpoints, application credentials, and shortcodes.
class BdappsConfig {
  BdappsConfig._();

  // App Identity
  static const String appName = 'ShebaBondhu';
  static const String appNameBangla = 'সেবা বন্ধু';
  static const String appId = 'APP_139868';
  static const String apiKey = 'd70bde968bb373c54707c0d279ede783';

  // Server Info
  static const String sharedIp = '176.9.54.45';
  static const String baseUrl =
      'https://www.bdappsdigitalapps.com/NADB26105_FinalProject/';

  // Endpoints
  static const String sendOtpUrl = '${baseUrl}send_otp.php';
  static const String verifyOtpUrl = '${baseUrl}verify_otp.php';
  static const String unsubscribeUrl = '${baseUrl}unsubscribe.php';
  static const String checkSubscriptionUrl = '${baseUrl}check_subscription.php';
  static const String subscriptionListenerUrl =
      '${baseUrl}subscription_listener.php';
  static const String smsUrl = '${baseUrl}sms.php';
  static const String ussdUrl = '${baseUrl}ussd.php';
  static const String landingPageUrl = '${baseUrl}sheba_bondhu';

  // bdapps Keywords & Shortcodes
  static const String shortCode = '21213';
  static const String smsKeyword = '11217';
  static const String ussdKeyword = '10757';

  // User instructions
  static const String smsInstruction = 'START $smsKeyword to $shortCode';
  static const String ussdInstruction = '*$shortCode*$ussdKeyword#';

  // bdapps Mandatory Charging Disclosure
  static const String chargingNotice =
      'Daily charge is 2.78 BDT (including VAT, SD & SC). For Robi and Cirkle users only.';
  static const String chargingNoticeBangla =
      'দৈনিক চার্জ ২.৭৮ টাকা (ভ্যাট, এসডি ও এসসি সহ)। শুধুমাত্র রবি ও Cirkle গ্রাহকদের জন্য প্রযোজ্য।';
}
