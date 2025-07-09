import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new item (this will trigger notification)
  static Future<void> addItem(String title, String description) async {
    await _firestore.collection('items').add({
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update an item (this will trigger notification)
  static Future<void> updateItem(
      String itemId, String title, String description) async {
    await _firestore.collection('items').doc(itemId).update({
      'title': title,
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete an item (this will trigger notification)
  static Future<void> deleteItem(String itemId) async {
    await _firestore.collection('items').doc(itemId).delete();
  }

  // Get all items
  static Stream<QuerySnapshot> getItems() {
    return _firestore
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Listen to specific document changes
  static Stream<DocumentSnapshot> listenToItem(String itemId) {
    return _firestore.collection('items').doc(itemId).snapshots();
  }
}
