import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'restaurant_detail_page.dart';
import 'restaurant.dart'; 
import 'dummy_data.dart'; 

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final user = FirebaseAuth.instance.currentUser;

  void _editNote(String docId, String currentNote) {
    final controller = TextEditingController(text: currentNote);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: const InputDecoration(hintText: 'Enter your note'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedNote = controller.text.trim();
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .collection('favorites')
                  .doc(docId)
                  .update({'note': updatedNote});
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFavorite(String docId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites & Notes'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No favorites saved.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;
              final name = data['name'] ?? 'Unnamed';
              final note = data['note'] ?? '';

              return ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: Text(name),
                subtitle: note.isNotEmpty
                    ? Text(note, style: const TextStyle(fontStyle: FontStyle.italic))
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(note.isEmpty ? Icons.note_add : Icons.edit_note),
                      onPressed: () => _editNote(docId, note),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _removeFavorite(docId),
                    ),
                  ],
                ),
                onTap: () {
                  final restaurant = dummyRestaurants.firstWhere(
                    (r) => r.name == name,
                    orElse: () => Restaurant(
                      id: '',
                      name: name,
                      address: '',
                      description: 'Details not available.',
                      operationHour: '',
                      cuisines: [],
                      imageUrl: '',
                      latitude: 0,
                      longitude: 0,
                      googleMapsLink: '',
                    ),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantDetailPage(restaurant: restaurant),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
