import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'login_screen.dart';
import 'signup_screen.dart';
import 'mainscreen.dart';
import 'edit_profile.dart';     
import 'change_password.dart';
import 'account_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StreetFeast Melaka',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),         
        '/signup': (context) => const SignUpScreen(),  
        '/main': (context) => const MainScreen(),      
        '/edit-profile': (context) => const EditProfilePage(),  
        '/change-password': (context) => const ChangePasswordPage(),
        '/account-settings': (context) => const AccountSettingsPage(),

      },
    );
  }
}
