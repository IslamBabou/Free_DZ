import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: _getFirebaseOptions(),
    );
  }

  static FirebaseOptions _getFirebaseOptions() {
    if (kIsWeb) {
      return _webOptions;
    }
    
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidOptions;
      case TargetPlatform.iOS:
        return _iosOptions;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  // TODO: Replace with your actual Firebase config from Firebase Console
  static const FirebaseOptions _androidOptions = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'freedz-project',
    storageBucket: 'freedz-project.appspot.com',
  );

  static const FirebaseOptions _iosOptions = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'freedz-project',
    iosBundleId: 'com.freedz.app',
    storageBucket: 'freedz-project.appspot.com',
  );

  static const FirebaseOptions _webOptions = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'freedz-project',
    storageBucket: 'freedz-project.appspot.com',
    authDomain: 'freedz-project.firebaseapp.com',
  );
}