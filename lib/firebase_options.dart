// File generated or configured for Firebase Project: cstu-connect (Project ID: cstu-connect1)
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
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB7l1NSyPbeTv_EYHvlpHvnzKFzjK4_K0w',
    appId: '1:565858225068:web:cstuconnect1',
    messagingSenderId: '565858225068',
    projectId: 'cstu-connect1',
    authDomain: 'cstu-connect1.firebaseapp.com',
    storageBucket: 'cstu-connect1.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB7l1NSyPbeTv_EYHvlpHvnzKFzjK4_K0w',
    appId: '1:565858225068:android:fcd687ff5fdf5d72558809',
    messagingSenderId: '565858225068',
    projectId: 'cstu-connect1',
    storageBucket: 'cstu-connect1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSy_YOUR_IOS_API_KEY_HERE',
    appId: '1:1234567890:ios:cstuconnect1',
    messagingSenderId: '1234567890',
    projectId: 'cstu-connect1',
    storageBucket: 'cstu-connect1.firebasestorage.app',
    iosBundleId: 'com.cstuconnect.cstuConnect',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSy_YOUR_MACOS_API_KEY_HERE',
    appId: '1:1234567890:ios:cstuconnect1',
    messagingSenderId: '1234567890',
    projectId: 'cstu-connect1',
    storageBucket: 'cstu-connect1.firebasestorage.app',
    iosBundleId: 'com.cstuconnect.cstuConnect',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSy_YOUR_WINDOWS_API_KEY_HERE',
    appId: '1:1234567890:web:cstuconnect1',
    messagingSenderId: '1234567890',
    projectId: 'cstu-connect1',
    authDomain: 'cstu-connect1.firebaseapp.com',
    storageBucket: 'cstu-connect1.firebasestorage.app',
  );
}
