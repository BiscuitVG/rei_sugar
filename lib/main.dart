import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; //welcome screen of the app

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDJal__ewnNenxAFujf-ad-7hCDNWjfOtM",
            authDomain: "fir-auth-flutter-biscuit.firebaseapp.com",
            projectId: "fir-auth-flutter-biscuit",
            storageBucket: "fir-auth-flutter-biscuit.firebasestorage.app",
            messagingSenderId: "934244117174",
            appId: "1:934244117174:web:e14b15828b66284ef3d417",
            measurementId: "G-D24D19379W"));
  }else{
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      /*title: 'rei_sugar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),*/
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
 }