import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser?.uid ?? '';

  // Save favorite with note
  Future<void> saveFavorite(String restaurantId, String note) async {
    if (userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(restaurantId)
        .set({
      'note': note,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Delete favorite
  Future<void> removeFavorite(String restaurantId) async {
    if (userId.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(restaurantId)
        .delete();
  }

  // Get all favorites
  Stream<List<Map<String, dynamic>>> getFavorites() {
    if (userId.isEmpty) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, 'note': doc['note']}).toList());
  }

  // Check if restaurant is favorited
  Future<bool> isFavorite(String restaurantId) async {
    if (userId.isEmpty) return false;

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(restaurantId)
        .get();

    return doc.exists;
  }

  // Get note for a restaurant
  Future<String?> getNote(String restaurantId) async {
    if (userId.isEmpty) return null;

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(restaurantId)
        .get();

    return doc.exists ? doc['note'] as String : null;
  }
}
