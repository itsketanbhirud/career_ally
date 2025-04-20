import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart'; // Adjust import path if needed
import '../models/tpo_update_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Get current user if needed

  // --- User Role ---
  Future<String?> getUserRole(String userId) async {
    // (Keep existing implementation)
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.get('role') as String?;
      }
      print("User document not found for role check: $userId");
      return null;
    } catch (e) {
      print("Error getting user role: $e");
      return null;
    }
  }

  // --- Student/Alumni Profile ---
  Future<Profile?> getProfile(String userId) async {
    // (Keep existing implementation, ensure Profile.fromJson handles errors)
    try {
      DocumentSnapshot profileDoc = await _db.collection('profiles').doc(userId).get();
      if (profileDoc.exists && profileDoc.data() != null) {
        return Profile.fromJson(userId, profileDoc.data() as Map<String, dynamic>);
      }
      print("Profile document not found for user: $userId");
      return null;
    } catch (e) {
      print("Error getting profile: $e");
      return null;
    }
  }

  Future<void> createOrUpdateProfile(String userId, Profile profileData) async {
    // (Keep existing implementation)
    try {
      await _db.collection('profiles').doc(userId).set(
        profileData.toJson(),
        SetOptions(merge: true),
      );
      print("Profile created/updated for user: $userId");
    } catch (e) {
      print("Error creating/updating profile: $e");
      throw FirebaseException(plugin: 'FirestoreService', message: e.toString());
    }
  }
// --- NEW METHOD: Get TPO Updates Stream ---
//   Stream<List<TpoUpdate>> getTpoUpdatesStream() {
//     return _db
//         .collection('tpo_updates')
//     // Order by timestamp, newest first
//         .orderBy('postedAt', descending: true)
//         .snapshots() // Listen for real-time changes
//         .map((snapshot) => snapshot.docs
//         .map((doc) => TpoUpdate.fromFirestore(doc))
//         .toList());
//   }
//
//   // --- Method for TPO to add an update (Needs TPO Role Check) ---
//   Future<void> addTpoUpdate({
//     required String title,
//     required String description,
//     required String tpoUid, // Pass the UID of the logged-in TPO
//     required String tpoName // Pass the name of the logged-in TPO
//   }) async {
//     // Optional: Add server-side validation or Cloud Function for added security
//     // Check if user role is TPO before allowing post (can be done via security rules too)
//     try {
//       await _db.collection('tpo_updates').add({
//         'title': title,
//         'description': description,
//         'postedAt': FieldValue.serverTimestamp(), // Use server time
//         'postedByUid': tpoUid,
//         'postedByName': tpoName,
//       });
//       print("TPO Update added successfully.");
//     } catch (e) {
//       print("Error adding TPO update: $e");
//       throw FirebaseException(plugin: 'FirestoreService', message: e.toString());
//     }
//   }
// --- TPO Profile (Placeholder - Add later) ---
// Future<TpoProfile?> getTpoProfile(String userId) async { ... }
// Future<void> createOrUpdateTpoProfile(String userId, TpoProfile tpoProfileData) async { ... }
}