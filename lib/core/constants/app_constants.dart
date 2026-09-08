/// App-wide constants.
class AppConstants {
  AppConstants._();

  /// The localized app name is read from ARB files at runtime. This is the
  /// fallback used in places that don't have BuildContext (e.g. Android
  /// application label in AndroidManifest).
  static const String appName = 'Sheba Bondhu';
  static const String appNameBn = 'সেবা বন্ধু';

  /// Supported locales. Order matters — the first one is the default.
  static const List<String> supportedLocales = ['bn', 'en'];

  /// Default display user name when unauthenticated or unnamed.
  static const String defaultUserName = 'ব্যবহারকারী';
}