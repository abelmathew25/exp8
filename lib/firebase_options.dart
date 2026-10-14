import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Generated / configured for Experiment 8 (Data Persistence using Firebase).
/// You can replace these placeholder values with credentials from your Firebase Console project.
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoExp8ApiKeyWeb1234567890abcdef',
    appId: '1:123456789012:web:abcdef1234567890',
    messagingSenderId: '123456789012',
    projectId: 'exp8-sqlite-firebase-demo',
    authDomain: 'exp8-sqlite-firebase-demo.firebaseapp.com',
    storageBucket: 'exp8-sqlite-firebase-demo.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoExp8ApiKeyAndroid123456789abcdef',
    appId: '1:123456789012:android:abcdef1234567890',
    messagingSenderId: '123456789012',
    projectId: 'exp8-sqlite-firebase-demo',
    storageBucket: 'exp8-sqlite-firebase-demo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoExp8ApiKeyIos1234567890abcdef',
    appId: '1:123456789012:ios:abcdef1234567890',
    messagingSenderId: '123456789012',
    projectId: 'exp8-sqlite-firebase-demo',
    storageBucket: 'exp8-sqlite-firebase-demo.appspot.com',
    iosBundleId: 'com.example.sqliteApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoExp8ApiKeyMacos1234567890abcdef',
    appId: '1:123456789012:ios:abcdef1234567890',
    messagingSenderId: '123456789012',
    projectId: 'exp8-sqlite-firebase-demo',
    storageBucket: 'exp8-sqlite-firebase-demo.appspot.com',
    iosBundleId: 'com.example.sqliteApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoExp8ApiKeyWin1234567890abcdef',
    appId: '1:123456789012:web:abcdef1234567890win',
    messagingSenderId: '123456789012',
    projectId: 'exp8-sqlite-firebase-demo',
    authDomain: 'exp8-sqlite-firebase-demo.firebaseapp.com',
    storageBucket: 'exp8-sqlite-firebase-demo.appspot.com',
  );
}
