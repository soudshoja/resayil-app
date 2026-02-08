import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'FirebaseOptions not configured for web. '
        'Please add firebase_options.dart',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'YOUR_API_KEY',
          appId: 'YOUR_APP_ID',
          projectId: 'YOUR_PROJECT_ID',
          messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
          storageBucket: 'YOUR_STORAGE_BUCKET',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: 'YOUR_API_KEY',
          appId: 'YOUR_APP_ID',
          projectId: 'YOUR_PROJECT_ID',
          messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
          iosBundleId: 'com.resayil.app',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'FirebaseOptions not configured for windows. '
          'Please add firebase_options.dart',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'FirebaseOptions not configured for linux. '
          'Please add firebase_options.dart',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'FirebaseOptions not configured for macOS. '
          'Please add firebase_options.dart',
        );
      default:
        throw UnsupportedError(
          'FirebaseOptions not configured for this platform.',
        );
    }
  }
}