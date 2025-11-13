import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/splashscreen.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDArlETk-weXMlB6Hdzb1ElzVLWmxvoggY",
        authDomain: "reinasalud1.firebaseapp.com",
        projectId: "reinasalud1",
        storageBucket: "reinasalud1.firebasestorage.app",
        messagingSenderId: "1098682891073",
        appId: "1:1098682891073:web:248e7a025599edf731bfc0",
      ),
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
