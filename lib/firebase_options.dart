// File generated from google-services.json.
// Do NOT modify manually. Re-generate if Firebase config changes.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platform is not configured. '
        'Add a web app in the Firebase console and re-generate this file.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS is not configured. '
          'Add an iOS app in the Firebase console to enable it.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions is not configured for this platform.',
        );
    }
  }

  /// Android configuration extracted from google-services.json.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALhyJ_Ojmp4FlR6ubSmmIblehzUub6Za4',
    appId: '1:981602010582:android:1068913762135c1c689077',
    messagingSenderId: '981602010582',
    projectId: 'todolist-b81af',
    storageBucket: 'todolist-b81af.firebasestorage.app',
  );
}
