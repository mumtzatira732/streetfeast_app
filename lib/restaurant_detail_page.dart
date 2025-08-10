import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'restaurant.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailPage({super.key, required this.restaurant});

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.restaurant.name)
        .get();

    if (doc.exists) {
      setState(() {
        isFavorite = true;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.restaurant.name);

    if (isFavorite) {
      await favRef.delete();
      setState(() => isFavorite = false);
    } else {
      await favRef.set({
        'name': widget.restaurant.name,
        'address': widget.restaurant.address,
        'note': '',
      });
      setState(() => isFavorite = true);
    }
  }

  Future<void> _openInGoogleMaps(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ========== Header ========== //
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 12, bottom: 14),
                  child: const Center(
                    child: Text(
                      'STREETFEAST MELAKA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                Container(
                  color: Colors.deepOrange,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          r.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleFavorite,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ========== Content ========== //
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar restoran
                  Image.asset(
                    r.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 60),
                      );
                    },
                  ),

                  // Info restoran
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Open until ${r.operationHour}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 6),

                        Text(
                          r.address,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 10, 10, 10),
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'About',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Text(
                          r.description,
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 20),

                        // Google Maps button at bottom
                        ElevatedButton.icon(
                          onPressed: () => _openInGoogleMaps(r.googleMapsLink),
                          icon: const Icon(Icons.map),
                          label: const Text('Open in Google Maps'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 220, 125, 104),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
