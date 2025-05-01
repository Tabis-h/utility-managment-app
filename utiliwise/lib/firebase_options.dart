import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // Add other platforms if needed
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyBuLwhQTqrUqveL9hyK97u0cap5xTYlNd4",
      authDomain: "utiliwise-9fe6f.firebaseapp.com",
      projectId: "utiliwise-9fe6f",
      messagingSenderId: "987511977342",
      appId: "1:987511977342:web:628d5339a148b6c92e6f2f"
  );
}