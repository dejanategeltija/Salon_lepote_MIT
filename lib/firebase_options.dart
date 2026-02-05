import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
//import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    //if (kIsWeb) return web;
    //return android;
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCcjMQ7Uk9B5ciT_yt17xcMPFlIjji5AFo",
    authDomain: "salon-lepote-dec40.firebaseapp.com",
    projectId: "salon-lepote-dec40",
    storageBucket: "salon-lepote-dec40.firebasestorage.app",
    messagingSenderId: "878399006680",
    appId: "1:878399006680:web:70af4cbfec7dab699874ad",
    measurementId: "G-TJ8CY926VZ"
  );
  
  /*static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'ANDROID_API_KEY_SA_SAJTA',
    appId: 'ANDROID_APP_ID_SA_SAJTA',
    messagingSenderId: 'SENDER_ID',
    projectId: 'salonlepote-mit',
    storageBucket: 'salonlepote-mit.appspot.com',
  );*/
}