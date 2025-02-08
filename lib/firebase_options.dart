// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDu68PuMD726-s4wYKRQ5loeOOp0-08Dro',
    appId: '1:545463263826:web:4a8a1a556a470b7da2b58b',
    messagingSenderId: '545463263826',
    projectId: 'fitnessapp-da79c',
    authDomain: 'fitnessapp-da79c.firebaseapp.com',
    storageBucket: 'fitnessapp-da79c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBRcxOpAvQafeJa7Nupc_kkS9JBnjdTBrQ',
    appId: '1:545463263826:android:9192eab93d187f33a2b58b',
    messagingSenderId: '545463263826',
    projectId: 'fitnessapp-da79c',
    storageBucket: 'fitnessapp-da79c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA8hkSz_jOzujpGJuVjIEm1XGr6y0Ci6Tk',
    appId: '1:545463263826:ios:31ded9ee9ba56769a2b58b',
    messagingSenderId: '545463263826',
    projectId: 'fitnessapp-da79c',
    storageBucket: 'fitnessapp-da79c.firebasestorage.app',
    iosBundleId: 'com.example.fitnessApplication',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA8hkSz_jOzujpGJuVjIEm1XGr6y0Ci6Tk',
    appId: '1:545463263826:ios:31ded9ee9ba56769a2b58b',
    messagingSenderId: '545463263826',
    projectId: 'fitnessapp-da79c',
    storageBucket: 'fitnessapp-da79c.firebasestorage.app',
    iosBundleId: 'com.example.fitnessApplication',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDu68PuMD726-s4wYKRQ5loeOOp0-08Dro',
    appId: '1:545463263826:web:3e3ab61c3083191ea2b58b',
    messagingSenderId: '545463263826',
    projectId: 'fitnessapp-da79c',
    authDomain: 'fitnessapp-da79c.firebaseapp.com',
    storageBucket: 'fitnessapp-da79c.firebasestorage.app',
  );
}
