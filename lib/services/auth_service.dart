import 'package:shared_preferences/shared_preferences.dart';
import 'bdapps/bdapps_service.dart';

/// Authentication and bdapps subscription session service.
///
/// Handles persistence of `isLoggedIn` and `userPhone` in [SharedPreferences],
/// and connects with bdapps subscription lifecycle.
class AuthService {
  AuthService({this.bdapps = const BdappsService()});

  final BdappsService bdapps;

  bool _signedIn = false;
  String? _userPhone;
  String? _displayName;

  bool get isSignedIn => _signedIn;
  String? get userPhone => _userPhone;
  String? get displayName =>
      _displayName ?? (_userPhone != null ? 'ব্যবহারকারী (${_userPhone!})' : 'ব্যবহারকারী');

  /// Initializes auth state from SharedPreferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _signedIn = prefs.getBool(BdappsService.keyIsLoggedIn) ?? false;
    _userPhone = prefs.getString(BdappsService.keyUserPhone);
    if (_userPhone != null && _userPhone!.isNotEmpty) {
      _displayName = _userPhone;
    }
  }

  /// Sets logged in state
  Future<void> onLoginSuccess(String phone) async {
    _signedIn = true;
    _userPhone = phone;
    _displayName = phone;
    await bdapps.saveSession(phone);
  }

  /// Backward compatible demo helper
  Future<bool> verifyOtp(String otp) async {
    if (otp == '123456') {
      _signedIn = true;
      _displayName = 'ব্যবহারকারী';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(BdappsService.keyIsLoggedIn, true);
      return true;
    }
    return false;
  }

  /// Signs out locally
  Future<void> signOut() async {
    _signedIn = false;
    _userPhone = null;
    _displayName = null;
    await bdapps.clearSession();
  }

  /// Unsubscribes from bdapps server and clears local session
  Future<bool> unsubscribe() async {
    final phone = _userPhone;
    bool serverOk = true;
    if (phone != null && phone.isNotEmpty) {
      serverOk = await bdapps.unsubscribe(phone);
    }
    await signOut();
    return serverOk;
  }
}