import 'package:admin_app/utils/app_style.dart';
import 'package:admin_app/views/splash/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'constants/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    //run for web
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAI7lQ_u23NgEXT30VfBqBnTsQFfogCFZI",
        authDomain: "groceryapp-july.firebaseapp.com",
        projectId: "groceryapp-july",
        storageBucket: "groceryapp-july.appspot.com",
        messagingSenderId: "219661912834",
        appId: "1:219661912834:web:768a4a05c878f958c9101b",
        measurementId: "G-EK14NGELQK",
      ),
    );
  } else {
    //run for android
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Grocery Admin App',
      theme: ThemeData(
        useMaterial3: true,
        iconTheme: const IconThemeData(color: kWhite),
        appBarTheme: AppBarTheme(
          backgroundColor: kDark,
          iconTheme: IconThemeData(color: kWhite),
          titleTextStyle: appStyle(20, kWhite, FontWeight.w500),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
