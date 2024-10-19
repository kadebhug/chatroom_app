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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCDpqc2njuU_qcx0h8Elak2K-ci5fJ9H0o',
    appId: '1:475019321394:android:075cb1b99d92f7d2c5dc2b',
    messagingSenderId: '475019321394',
    projectId: 'chatroom-bf15c',
    storageBucket: 'chatroom-bf15c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDNeUFgiA15WlLDBdXSi0Ga_tJpVeXqrPo',
    appId: '1:475019321394:ios:133be15241a7107cc5dc2b',
    messagingSenderId: '475019321394',
    projectId: 'chatroom-bf15c',
    storageBucket: 'chatroom-bf15c.appspot.com',
    iosBundleId: 'com.example.chatroomApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDNeUFgiA15WlLDBdXSi0Ga_tJpVeXqrPo',
    appId: '1:475019321394:ios:6a19e5d2a8535652c5dc2b',
    messagingSenderId: '475019321394',
    projectId: 'chatroom-bf15c',
    storageBucket: 'chatroom-bf15c.appspot.com',
    iosBundleId: 'com.chatroom.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA28y2gkxRkVWUtvBx3keveU9XhSgRvfaw',
    appId: '1:475019321394:web:1f2aebecb5d40966c5dc2b',
    messagingSenderId: '475019321394',
    projectId: 'chatroom-bf15c',
    authDomain: 'chatroom-bf15c.firebaseapp.com',
    storageBucket: 'chatroom-bf15c.appspot.com',
    measurementId: 'G-K6PRZHME93',
  );
}