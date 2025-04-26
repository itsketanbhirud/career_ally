import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart'; // Adjust import path if needed
import '../models/tpo_update_model.dart';
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
  Stream<List<TpoUpdate>> getTpoUpdatesStream() {
    return _db
        .collection('tpo_updates')
    // Order by timestamp, newest first
        .orderBy('postedAt', descending: true)
        .snapshots() // Listen for real-time changes
        .map((snapshot) => snapshot.docs
        .map((doc) => TpoUpdate.fromFirestore(doc))
        .toList());
  }

  // --- Method for TPO to add an update (Needs TPO Role Check) ---
  Future<void> addTpoUpdate({
    required String title,
    required String description,
    required String tpoUid, // Pass the UID of the logged-in TPO
    required String tpoName // Pass the name of the logged-in TPO
  }) async {
    // Optional: Add server-side validation or Cloud Function for added security
    // Check if user role is TPO before allowing post (can be done via security rules too)
    try {
      await _db.collection('tpo_updates').add({
        'title': title,
        'description': description,
        'postedAt': FieldValue.serverTimestamp(), // Use server time
        'postedByUid': tpoUid,
        'postedByName': tpoName,
      });
      print("TPO Update added successfully.");
    } catch (e) {
      print("Error adding TPO update: $e");
      throw FirebaseException(plugin: 'FirestoreService', message: e.toString());
    }
  }
  // --- NEW METHOD: Update TPO Update ---
  Future<void> updateTpoUpdate({
    required String updateId, // ID of the document to update
    required String newTitle,
    required String newDescription,
  }) async {
    try {
      await _db.collection('tpo_updates').doc(updateId).update({
        'title': newTitle,
        'description': newDescription,
        // Optionally update a 'lastEditedAt' timestamp if needed
        // 'lastEditedAt': FieldValue.serverTimestamp(),
      });
      print("TPO Update $updateId updated successfully.");
    } catch (e) {
      print("Error updating TPO update $updateId: $e");
      throw FirebaseException(plugin: 'FirestoreService', message: e.toString());
    }
  }

  // --- NEW METHOD: Delete TPO Update ---
  Future<void> deleteTpoUpdate({required String updateId}) async {
    try {
      await _db.collection('tpo_updates').doc(updateId).delete();
      print("TPO Update $updateId deleted successfully.");
    } catch (e) {
      print("Error deleting TPO update $updateId: $e");
      throw FirebaseException(plugin: 'FirestoreService', message: e.toString());
    }
  }

  // --- TPO Profile Methods (Add later if needed) ---
  // ...

  // --- Helper to get TPO name (could be used in ManageUpdatesScreen) ---
  // Assumes you have a tpo_profiles collection or store name in users doc
  Future<String?> getTpoName(String tpoUid) async {
    try {
      // Option 1: From a dedicated tpo_profiles collection
      // DocumentSnapshot tpoProfileDoc = await _db.collection('tpo_profiles').doc(tpoUid).get();
      // if (tpoProfileDoc.exists) {
      //   return tpoProfileDoc.get('name') as String?;
      // }

      // Option 2: From the users collection (if name stored there)
      DocumentSnapshot userDoc = await _db.collection('users').doc(tpoUid).get();
      if (userDoc.exists) {
        // Assuming 'username' field holds the TPO's display name
        return userDoc.get('username') as String?;
      }

      print("TPO name not found for UID: $tpoUid");
      return "Unknown TPO"; // Default fallback
    } catch (e) {
      print("Error getting TPO name: $e");
      return "Error Fetching Name";
    }
  }
// --- TPO Profile (Placeholder - Add later) ---
// Future<TpoProfile?> getTpoProfile(String userId) async { ... }
// Future<void> createOrUpdateTpoProfile(String userId, TpoProfile tpoProfileData) async { ... }
}