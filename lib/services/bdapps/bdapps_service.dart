import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'bdapps_config.dart';

class SubscriptionStatusResult {
  const SubscriptionStatusResult({
    required this.isSubscribedOrPending,
    required this.status,
    this.rawResponse,
  });

  final bool isSubscribedOrPending;
  final String status;
  final Map<String, dynamic>? rawResponse;
}

class SendOtpResult {
  const SendOtpResult({
    required this.success,
    required this.referenceNo,
    required this.statusCode,
    required this.message,
    required this.statusDetail,
  });

  final bool success;
  final String referenceNo;
  final String statusCode;
  final String message;
  final String statusDetail;
}

class VerifyOtpResult {
  const VerifyOtpResult({
    required this.success,
    required this.statusCode,
    required this.message,
    this.rawResponse,
  });

  final bool success;
  final String statusCode;
  final String message;
  final Map<String, dynamic>? rawResponse;
}

class BdappsService {
  const BdappsService();

  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserPhone = 'userPhone';
  static const String keySeenOnboarding = 'seenOnboarding';

  /// Validates Robi/Airtel MSISDN format (11 digits starting with 018 or 016)
  bool isSupportedRobiAirtelNumber(String phone) {
    return RegExp(r'^01(?:6|8)\d{8}$').hasMatch(phone.trim());
  }

  /// Calls `check_subscription.php` to query subscriber status.
  /// Status `REGISTERED` or `INITIAL CHARGING PENDING` confirms active access.
  Future<SubscriptionStatusResult> checkSubscription(String phone) async {
    try {
      final response = await http
          .post(
            Uri.parse(BdappsConfig.checkSubscriptionUrl),
            body: {'user_mobile': phone.trim()},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return const SubscriptionStatusResult(
          isSubscribedOrPending: false,
          status: 'HTTP_ERROR',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const SubscriptionStatusResult(
          isSubscribedOrPending: false,
          status: 'INVALID_JSON',
        );
      }

      final status =
          decoded['subscriptionStatus']?.toString().trim().toUpperCase() ?? '';
      final isOk =
          status == 'REGISTERED' || status == 'INITIAL CHARGING PENDING';

      return SubscriptionStatusResult(
        isSubscribedOrPending: isOk,
        status: status,
        rawResponse: decoded,
      );
    } catch (e) {
      debugPrint('bdapps checkSubscription error: $e');
      return SubscriptionStatusResult(
        isSubscribedOrPending: false,
        status: 'EXCEPTION: $e',
      );
    }
  }

  /// Polls `check_subscription.php` until REGISTERED or INITIAL CHARGING PENDING
  /// is reported, or `maxAttempts` is reached.
  Future<bool> waitForSubscriptionSync(
    String phone, {
    int maxAttempts = 5,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(delay);
      final res = await checkSubscription(phone);
      if (res.isSubscribedOrPending) {
        return true;
      }
    }
    return false;
  }

  /// Sends OTP request to `send_otp.php`.
  Future<SendOtpResult> sendOtp(String phone) async {
    final response = await http
        .post(
          Uri.parse(BdappsConfig.sendOtpUrl),
          body: {'user_mobile': phone.trim()},
        )
        .timeout(const Duration(seconds: 15));

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('সার্ভার থেকে ভুল তথ্য এসেছে');
    }

    final success = decoded['success'] == true;
    final referenceNo = decoded['referenceNo']?.toString().trim() ?? '';
    final message = decoded['message']?.toString() ?? '';
    final statusDetail = decoded['statusDetail']?.toString() ?? '';
    final statusCode = decoded['statusCode']?.toString().trim() ?? '';

    return SendOtpResult(
      success: success,
      referenceNo: referenceNo,
      statusCode: statusCode,
      message: message,
      statusDetail: statusDetail,
    );
  }

  /// Verifies OTP via `verify_otp.php`.
  Future<VerifyOtpResult> verifyOtp({
    required String phone,
    required String otp,
    required String referenceNo,
  }) async {
    final response = await http
        .post(
          Uri.parse(BdappsConfig.verifyOtpUrl),
          body: {
            'Otp': otp.trim(),
            'otp': otp.trim(),
            'referenceNo': referenceNo.trim(),
            'reference_no': referenceNo.trim(),
            'user_mobile': phone.trim(),
          },
        )
        .timeout(const Duration(seconds: 15));

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('সার্ভার থেকে ভুল তথ্য এসেছে');
    }

    String readString(List<String> keys) {
      for (final key in keys) {
        final val = decoded[key];
        if (val != null) {
          final t = val.toString().trim();
          if (t.isNotEmpty) return t;
        }
      }
      return '';
    }

    final statusCode = readString([
      'statusCode',
      'StatusCode',
      'status_code',
    ]).toUpperCase();

    final successFlag =
        decoded['success'] == true ||
        readString(['status', 'result']).toLowerCase() == 'success';

    final message = readString([
      'message',
      'statusDetail',
      'error',
      'errorMessage',
    ]);

    return VerifyOtpResult(
      success: statusCode == 'S1000' || successFlag,
      statusCode: statusCode,
      message: message,
      rawResponse: decoded,
    );
  }

  /// Unsubscribes a user from bdapps via `unsubscribe.php`.
  Future<bool> unsubscribe(String phone) async {
    try {
      final response = await http
          .post(
            Uri.parse(BdappsConfig.unsubscribeUrl),
            body: {'user_mobile': phone.trim()},
          )
          .timeout(const Duration(seconds: 15));

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final success = decoded['success'] == true ||
            decoded['statusCode']?.toString().toUpperCase() == 'S1000' ||
            decoded['status']?.toString().toLowerCase() == 'success';
        return success;
      }
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('bdapps unsubscribe error: $e');
      return false;
    }
  }

  /// Saves login state to SharedPreferences
  Future<void> saveSession(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyUserPhone, phone.trim());
  }

  /// Clears login state from SharedPreferences
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, false);
    await prefs.remove(keyUserPhone);
  }

  /// Checks if user is locally logged in
  Future<bool> isLocallyLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  /// Gets stored phone number if any
  Future<String?> getStoredPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserPhone);
  }
}
