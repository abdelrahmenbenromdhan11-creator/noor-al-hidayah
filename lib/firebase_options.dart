import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS: return ios;
      default: return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCMvQQ0A00X0in0TsBxveVm-GswaB2u6A0',
    authDomain: 'nooralhidayahapp.firebaseapp.com',
    projectId: 'nooralhidayahapp',
    storageBucket: 'nooralhidayahapp.firebasestorage.app',
    messagingSenderId: '478936869118',
    appId: '1:478936869118:web:ce7059f87b81ec7deeddaf',
  );

  // مؤقتًا: نفس الإعدادات (سنحدّثها لاحقًا لأندرويد/iOS)
  static const FirebaseOptions android = web;
  static const FirebaseOptions ios = web;
}
