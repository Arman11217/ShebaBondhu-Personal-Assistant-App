import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for Sheba Bondhu.
/// Sourced directly from google-services.json (`sheba-bondhu-6a56b`).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for Linux.',
        );
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCQ10mnzFaRBEmYNELW_75nQ0EizvcTPMo',
    appId: '1:851599242283:android:590caf8fd7a4d00c6be66e',
    messagingSenderId: '851599242283',
    projectId: 'sheba-bondhu-6a56b',
    storageBucket: 'sheba-bondhu-6a56b.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCQ10mnzFaRBEmYNELW_75nQ0EizvcTPMo',
    appId: '1:851599242283:web:590caf8fd7a4d00c6be66e',
    messagingSenderId: '851599242283',
    projectId: 'sheba-bondhu-6a56b',
    storageBucket: 'sheba-bondhu-6a56b.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCQ10mnzFaRBEmYNELW_75nQ0EizvcTPMo',
    appId: '1:851599242283:android:590caf8fd7a4d00c6be66e',
    messagingSenderId: '851599242283',
    projectId: 'sheba-bondhu-6a56b',
    storageBucket: 'sheba-bondhu-6a56b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCQ10mnzFaRBEmYNELW_75nQ0EizvcTPMo',
    appId: '1:851599242283:ios:590caf8fd7a4d00c6be66e',
    messagingSenderId: '851599242283',
    projectId: 'sheba-bondhu-6a56b',
    storageBucket: 'sheba-bondhu-6a56b.firebasestorage.app',
    iosBundleId: 'com.sheba_bondhu.sheba_bondhu',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCQ10mnzFaRBEmYNELW_75nQ0EizvcTPMo',
    appId: '1:851599242283:ios:590caf8fd7a4d00c6be66e',
    messagingSenderId: '851599242283',
    projectId: 'sheba-bondhu-6a56b',
    storageBucket: 'sheba-bondhu-6a56b.firebasestorage.app',
    iosBundleId: 'com.sheba_bondhu.sheba_bondhu',
  );
}
