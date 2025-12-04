import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// 👇 IMPORT CORRECTO
import 'screens/medications_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const MaintainerApp());
}

class MaintainerApp extends StatelessWidget {
  const MaintainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReinaSalud Mantenedor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MedicationsScreen(), // 👈 ESTA CLASE LA CREAMOS ABAJO
    );
  }
}
