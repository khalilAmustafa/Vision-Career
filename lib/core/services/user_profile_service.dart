import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveUserProfile({
    required String uid,
    required String username,
    required int age,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'username': username,
      'age': age,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return null;

    return doc.data();
  }
}