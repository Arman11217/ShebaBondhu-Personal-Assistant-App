import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheba_bondhu/services/bdapps/bdapps_config.dart';
import 'package:sheba_bondhu/services/bdapps/bdapps_service.dart';
import 'package:sheba_bondhu/services/auth_service.dart';

void main() {
  group('BdappsConfig Verification', () {
    test('Verify user specific bdapps credentials and endpoints', () {
      expect(BdappsConfig.sharedIp, equals('176.9.54.45'));
      expect(
        BdappsConfig.baseUrl,
        equals('https://www.bdappsdigitalapps.com/NADB26105_FinalProject/'),
      );
      expect(
        BdappsConfig.sendOtpUrl,
        equals('https://www.bdappsdigitalapps.com/NADB26105_FinalProject/send_otp.php'),
      );
      expect(
        BdappsConfig.verifyOtpUrl,
        equals('https://www.bdappsdigitalapps.com/NADB26105_FinalProject/verify_otp.php'),
      );
      expect(
        BdappsConfig.unsubscribeUrl,
        equals('https://www.bdappsdigitalapps.com/NADB26105_FinalProject/unsubscribe.php'),
      );
      expect(
        BdappsConfig.checkSubscriptionUrl,
        equals('https://www.bdappsdigitalapps.com/NADB26105_FinalProject/check_subscription.php'),
      );
      expect(
        BdappsConfig.subscriptionListenerUrl,
        equals('https://www.bdappsdigitalapps.com/NADB26105_FinalProject/subscription_listener.php'),
      );
      expect(
        BdappsConfig.smsUrl,
        equals('https://www.bdappsdigitalapps.com/NADB26105_FinalProject/sms.php'),
      );
      expect(
        BdappsConfig.ussdUrl,
        equals('https://www.bdappsdigitalapps.com/NADB26105_FinalProject/ussd.php'),
      );
      expect(
        BdappsConfig.landingPageUrl,
        equals('https://www.bdappsdigitalapps.com/NADB26105_FinalProject/sheba_bondhu'),
      );
      expect(BdappsConfig.appName, equals('ShebaBondhu'));
      expect(BdappsConfig.appId, equals('APP_139868'));
      expect(BdappsConfig.apiKey, equals('d70bde968bb373c54707c0d279ede783'));
      expect(BdappsConfig.smsKeyword, equals('11217'));
      expect(BdappsConfig.ussdKeyword, equals('10757'));
    });
  });

  group('BdappsService Validation', () {
    const service = BdappsService();

    test('Validates Robi and Cirkle (Airtel) phone numbers correctly', () {
      // Robi
      expect(service.isSupportedRobiAirtelNumber('01812345678'), isTrue);
      expect(service.isSupportedRobiAirtelNumber('01800000000'), isTrue);

      // Cirkle (016)
      expect(service.isSupportedRobiAirtelNumber('01612345678'), isTrue);
      expect(service.isSupportedRobiAirtelNumber('01699999999'), isTrue);

      // Other operators (GP, BL, Teletalk)
      expect(service.isSupportedRobiAirtelNumber('01712345678'), isFalse);
      expect(service.isSupportedRobiAirtelNumber('01312345678'), isFalse);
      expect(service.isSupportedRobiAirtelNumber('01912345678'), isFalse);
      expect(service.isSupportedRobiAirtelNumber('01412345678'), isFalse);
      expect(service.isSupportedRobiAirtelNumber('01512345678'), isFalse);

      // Malformed / invalid
      expect(service.isSupportedRobiAirtelNumber('0181234567'), isFalse); // 10 digits
      expect(service.isSupportedRobiAirtelNumber('018123456789'), isFalse); // 12 digits
      expect(service.isSupportedRobiAirtelNumber('abcd'), isFalse);
      expect(service.isSupportedRobiAirtelNumber(''), isFalse);
    });

    test('Persists and clears session using SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      const phone = '01812345678';

      final authService = AuthService(bdapps: service);
      await authService.init();
      expect(authService.isSignedIn, isFalse);

      await authService.onLoginSuccess(phone);
      expect(authService.isSignedIn, isTrue);
      expect(authService.userPhone, equals(phone));

      // Check SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(BdappsService.keyIsLoggedIn), isTrue);
      expect(prefs.getString(BdappsService.keyUserPhone), equals(phone));

      // Sign out
      await authService.signOut();
      expect(authService.isSignedIn, isFalse);
      expect(authService.userPhone, isNull);
      expect(prefs.getBool(BdappsService.keyIsLoggedIn), isFalse);
    });
  });
}
