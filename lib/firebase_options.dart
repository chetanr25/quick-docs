import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAeHphX8okBhLQ9GKnM4WCxUVXe-Srvl6g',
    appId: '1:1761536472:web:a622d43b8732d5da31eaad',
    messagingSenderId: '1761536472',
    projectId: 'quick-doc-freshblood',
    authDomain: 'quick-doc-freshblood.firebaseapp.com',
    storageBucket: 'quick-doc-freshblood.appspot.com',
    measurementId: 'G-6XBFP2F5E4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvgBxEqAYa6RxfsjSEy3trbkhFVhvdiAs',
    appId: '1:1761536472:android:fcb0f7b87a40dad631eaad',
    messagingSenderId: '1761536472',
    projectId: 'quick-doc-freshblood',
    storageBucket: 'quick-doc-freshblood.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDxabrd-YQXohksa_-FXbx5vrQf-4GiYjE',
    appId: '1:1761536472:ios:2eac9859dc0f263431eaad',
    messagingSenderId: '1761536472',
    projectId: 'quick-doc-freshblood',
    storageBucket: 'quick-doc-freshblood.appspot.com',
    iosBundleId: 'com.example.pdfMadeEasy',
  );
}
