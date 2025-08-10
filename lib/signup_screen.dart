import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isSendingEmail = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        final name = _nameController.text.trim();

        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        final user = userCredential.user;

        if (user != null && !user.emailVerified) {
          await user.updateDisplayName(name);
          await user.sendEmailVerification();

          setState(() => isSendingEmail = true);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification email sent. Please check your inbox.')),
          );

          await Future.delayed(const Duration(seconds: 5));
          await FirebaseAuth.instance.signOut();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }

        // Save to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
          'name': name,
          'email': email,
        });

      } on FirebaseAuthException catch (e) {
        String message = 'Signup failed';
        if (e.code == 'email-already-in-use') {
          message = 'Email already in use';
        } else if (e.code == 'weak-password') {
          message = 'Password is too weak';
        } else {
          message = e.message ?? 'Signup error';
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFec6f39), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
        
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Image.asset(
              'images/melaka_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

        
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const Text(
                        'STREETFEAST MELAKA',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration('Enter your name'),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 15),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: _inputDecoration('Enter your email address'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: _inputDecoration('Enter your password'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Confirm Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: _inputDecoration('Confirm your password'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),

                      Center(
                        child: ElevatedButton(
                          onPressed: isSendingEmail ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFec6f39),
                            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: isSendingEmail
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 14),
                            children: [
                              const TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: "Log In",
                                style: const TextStyle(
                                  color: Color(0xFFec6f39),
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const LoginScreen()),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
