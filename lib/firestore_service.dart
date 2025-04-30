import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static String? get uid => _auth.currentUser?.uid;

  // Initialize user document if it doesn't exist
  static Future<void> initializeUserData() async {
    if (uid == null) return;

    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'favorites': [],
        'currentlyReading': [],
        'wantToRead': [],
        'finishedReading': [],
        'ratings': {}, // 🆕 Added to initialize ratings field also
      });
    }
  }

  // Add a book to a list (favorites / mybooks)
  static Future<void> addBookToList(
    String listName,
    Map<String, dynamic> bookData,
  ) async {
    if (uid == null) return;
    final docRef = _firestore.collection('users').doc(uid);

    await docRef.update({
      listName: FieldValue.arrayUnion([bookData]),
    });
  }

  // Get user's books for a list
  static Future<List<Map<String, dynamic>>> getBooksFromList(
    String listName,
  ) async {
    if (uid == null) return [];

    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    final data = docSnapshot.data();
    if (data == null || !data.containsKey(listName)) return [];

    List books = data[listName];
    return List<Map<String, dynamic>>.from(books);
  }

  // 🆕 Save the user's personal rating for a book
  static Future<void> saveBookRating(String bookId, int rating) async {
    if (uid == null) return;
    final docRef = _firestore.collection('users').doc(uid);

    await docRef.set({
      'ratings': {bookId: rating},
    }, SetOptions(merge: true));
  }

  // 🆕 Get the saved personal rating for a book
  static Future<int?> getBookRating(String bookId) async {
    if (uid == null) return null;
    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      final data = docSnapshot.data()!;
      if (data['ratings'] != null && data['ratings'][bookId] != null) {
        return data['ratings'][bookId];
      }
    }
    return null;
  }
}
