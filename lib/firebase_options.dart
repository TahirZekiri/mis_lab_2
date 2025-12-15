import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError('This platform is not configured');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB7_2itncK4izlrXT-47Se-ktI9ofUMKYI',
    appId: '1:597133353332:android:eb38fcf4baba4738c6cc21',
    messagingSenderId: '597133353332',
    projectId: 'mislabs-ce2c2',
    storageBucket: 'mislabs-ce2c2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCSvusoo29-zsi6yzfrMXf4Owzfd3a8AlI',
    appId: '1:597133353332:ios:13fd7f71a376b3b0c6cc21',
    messagingSenderId: '597133353332',
    projectId: 'mislabs-ce2c2',
    storageBucket: 'mislabs-ce2c2.firebasestorage.app',
    iosBundleId: 'com.example.mislab2',
  );
}


