// lib/screens/login.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _loginWithGoogle() async {
    try {
      setState(() => _loading = true);

      // 1) Inicializar Google Sign-In 
      await GoogleSignIn.instance.initialize();

      // 2) Abrir selector de cuenta
      final googleUser = await GoogleSignIn.instance.authenticate();

      // Si el usuario cancela, googleUser viene falso o null
      if (googleUser == null || googleUser == false) {
        setState(() => _loading = false);
        return;
      }

      // 3) Obtener el token de Google
      final googleAuth = await googleUser.authentication;

      // En esta versión solo usamos idToken
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 4) Iniciar sesión en Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      // 5) Ir a Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión con Google: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _loading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // logo de Reina Salud
                      Image.asset(
                        'assets/logo.jpg',
                        height: 80,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Reina Salud',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tu remedio, más cerca que nunca',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        icon: Image.asset(
                          'assets/google.png', // iconito de Google
                          height: 24,
                          width: 24,
                        ),
                        label: const Text('Iniciar sesión con Google'),
                        onPressed: _loginWithGoogle,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
