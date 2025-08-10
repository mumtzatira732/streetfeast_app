import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool isLoading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: _currentPassword.text.trim(),
      );

      // Reauthenticate first
      await user.reauthenticateWithCredential(cred);

      // Then update password
      await user.updatePassword(_newPassword.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );

      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentPassword,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current Password'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter current password' : null,
              ),
              TextFormField(
                controller: _newPassword,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                validator: (value) => value != null && value.length >= 6
                    ? null
                    : 'Min 6 characters required',
              ),
              TextFormField(
                controller: _confirmPassword,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
                validator: (value) =>
                    value != _newPassword.text ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Update Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
