import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'favorites.dart';
import 'login_screen.dart';
import 'account_settings.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? name;
  String? email;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    } else {
      loadUserData();
    }
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          name = data['name'];
          email = data['email'];
          isLoading = false;
        });
      } else {
        setState(() {
          name = 'Unknown';
          email = 'Unknown';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        name = 'Error';
        email = 'Error';
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    color: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Text(
                            (name != null && name!.isNotEmpty)
                                ? name![0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name ?? 'No Name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email ?? 'No Email',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, bottom: 10),
                          child: Text(
                            'CONTENT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontSize: 17,
                            ),
                          ),
                        ),

                        ListTile(
                          leading: const Icon(Icons.favorite),
                          title: const Text('Favorites'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FavoritesPage()),
                            );
                          },
                        ),
                        const Divider(height: 1),

                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Edit Profile'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final updatedData = await Navigator.pushNamed(
                              context,
                              '/edit-profile',
                              arguments: {'name': name, 'email': email},
                            );
                            if (updatedData != null && updatedData is Map) {
                              setState(() {
                                name = updatedData['name'];
                                email = updatedData['email'];
                              });
                            }
                          },
                        ),
                        const Divider(height: 1),

                        ListTile(
                          leading: const Icon(Icons.account_circle),
                          title: const Text('Account'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AccountSettingsPage()),
                            );
                          },
                        ),
                        const Divider(height: 1),

                        const SizedBox(height: 30),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          onPressed: logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
