import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get uid => _auth.currentUser?.uid;
  static String? get username => _auth.currentUser?.email ?? 'Anonymous';

  static Future<void> addReview(String bookId, String reviewText) async {
    if (uid == null) return;
    final docRef = _firestore.collection('reviews').doc(bookId);

    final newReview = {
      'userId': uid,
      'username': username,
      'reviewText': reviewText,
      'timestamp': DateTime.now(), // ✅ Updated here
    };

    await docRef.set({
      'review_list': FieldValue.arrayUnion([newReview]),
    }, SetOptions(merge: true));
  }

  static Future<List<Map<String, dynamic>>> getReviews(String bookId) async {
    final docSnapshot =
        await _firestore.collection('reviews').doc(bookId).get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      final data = docSnapshot.data()!;
      if (data['review_list'] != null) {
        return List<Map<String, dynamic>>.from(data['review_list']);
      }
    }
    return [];
  }
}
