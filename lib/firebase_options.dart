// File generated for Firebase project: arisan-antigravity
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
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
    apiKey: 'AIzaSyAXq3FSwg_pZd0khb2zTKWiFp8BHtCCJ-k',
    authDomain: 'arisan-antigravity.firebaseapp.com',
    projectId: 'arisan-antigravity',
    storageBucket: 'arisan-antigravity.firebasestorage.app',
    messagingSenderId: '100428312423',
    appId: '1:100428312423:web:0b5b1a2f5e10dc58a949c2',
    measurementId: 'G-6FJQVS7BJM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAXq3FSwg_pZd0khb2zTKWiFp8BHtCCJ-k',
    appId: '1:100428312423:android:0b5b1a2f5e10dc58a949c2',
    messagingSenderId: '100428312423',
    projectId: 'arisan-antigravity',
    storageBucket: 'arisan-antigravity.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAXq3FSwg_pZd0khb2zTKWiFp8BHtCCJ-k',
    appId: '1:100428312423:ios:0b5b1a2f5e10dc58a949c2',
    messagingSenderId: '100428312423',
    projectId: 'arisan-antigravity',
    storageBucket: 'arisan-antigravity.firebasestorage.app',
    iosBundleId: 'com.example.appArisanAntigravity',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAXq3FSwg_pZd0khb2zTKWiFp8BHtCCJ-k',
    appId: '1:100428312423:ios:0b5b1a2f5e10dc58a949c2',
    messagingSenderId: '100428312423',
    projectId: 'arisan-antigravity',
    storageBucket: 'arisan-antigravity.firebasestorage.app',
    iosBundleId: 'com.example.appArisanAntigravity',
  );
}
