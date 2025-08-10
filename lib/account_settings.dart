import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  // ───── Change Password ─────
  void _goToChangePassword(BuildContext context) {
    Navigator.pushNamed(context, '/change-password');
  }

  // ───── Delete Account ─────
  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This action cannot be undone. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Delete from Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

        // Delete auth account
        await user.delete();

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    }
  }

  // ───── UI ─────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _goToChangePassword(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Account'),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _deleteAccount(context),
          ),
        ],
      ),
    );
  }
}
