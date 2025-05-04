import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_services.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriTayo Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                AuthService authService = AuthService();
                UserCredential? userCredential =
                    await authService.signInWithGoogle();
                if (userCredential != null) {
                  print(
                      "User signed in: ${userCredential.user!.displayName}");
                } else {
                  print("Google Sign-In failed.");
                }
              },
              child: const Text("Sign In with Google"),
            ),
          ],
        ),
      ),
    );
  }
}