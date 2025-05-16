import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_services.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    // Optional: Navigate back to the login screen after signing out
    // if (mounted) {
    //   Navigator.pushAndRemoveUntil(
    //     context,
    //     MaterialPageRoute(builder: (context) => const LoginScreen()),
    //     (Route<dynamic> route) => false,
    //   );
    // }
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (!mounted) return;
    setState(() => _isEmailLoading = true);
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome back, ${userCredential.user?.email}!"), duration: const Duration(seconds: 2)),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else {
        message = 'Login failed. ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("An unexpected error occurred: $e"), backgroundColor: Colors.red),
          );
       }
    }
    finally {
      if (mounted) setState(() => _isEmailLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!mounted) return;
    setState(() => _isGoogleLoading = true);
    try {
      UserCredential? userCredential = await _authService.signInWithGoogle();

      if (userCredential != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signed in as ${userCredential.user?.displayName}"), duration: const Duration(seconds: 2)),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Sign-In failed or was canceled"), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      print("Google Sign-In Error: $e"); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error signing in with Google: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Authetication Screen.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch, 
                  children: [
                    const SizedBox(height: 80),

                    Center( 
                      child: Column(
                        children: [
                           Text(
                            "AgriTayo",
                            style: TextStyle(
                              fontFamily: 'Futehodo-MaruGothic_1.00',
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [ 
                                Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: Offset(2.0, 2.0),
                                ),
                              ]
                            ),
                          ),
                          Text(
                            "Authentication",
                            style: TextStyle(
                              fontFamily: 'Futehodo-MaruGothic_1.00',
                              fontSize: 28, 
                              color: Colors.white,
                               shadows: [ 
                                Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: Offset(2.0, 2.0),
                                ),
                              ]
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48), 

                    _buildInputField("Email", _emailController),
                    const SizedBox(height: 16),
                    _buildInputField("Password", _passwordController, obscure: true),
                    const SizedBox(height: 24),
                    _buildEmailSignInButton(),
                    const SizedBox(height: 16),
                    _buildGoogleSignInButton(),
                    const SizedBox(height: 32), 

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), 
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextButton(
                        onPressed: (_isEmailLoading || _isGoogleLoading) ? null : () { 
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPage()),
                          );
                        },
                        style: TextButton.styleFrom(
                           padding: EdgeInsets.zero, 
                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Don't have an account? Sign up",
                          style: TextStyle(
                            fontFamily: 'Futehodo-MaruGothic_1.00',
                            fontWeight: FontWeight.bold,
                            color: Colors.black87, 
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, TextEditingController controller, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, 
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: Colors.black54),
      ),
    );
  }

  Widget _buildEmailSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isEmailLoading || _isGoogleLoading) ? null : _signInWithEmailAndPassword,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: const Color(0xFF00A814), 
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: _isEmailLoading
            ? const SizedBox( 
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white, 
                  strokeWidth: 2,
                ),
              )
            : const Text( // Use const
                "Sign in",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_isEmailLoading || _isGoogleLoading) ? null : _signInWithGoogle,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), 
            side: const BorderSide(color: Colors.black12),
          ),
          elevation: 5, 
        ),
        child: _isGoogleLoading
            ? const SizedBox( 
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.black54,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Sign in with Google",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
      ),
    );
  }
}


/*
authentication.dart

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
*/