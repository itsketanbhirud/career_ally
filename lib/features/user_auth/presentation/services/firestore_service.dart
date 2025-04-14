import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart'; // Adjust import path if needed

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Get current user if needed

  // --- User Role ---
  Future<String?> getUserRole(String userId) async {
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
    try {
      DocumentSnapshot profileDoc = await _db.collection('profiles').doc(userId).get();
      if (profileDoc.exists && profileDoc.data() != null) {
        // Pass the userId (document ID) to the fromJson factory
        return Profile.fromJson(userId, profileDoc.data() as Map<String, dynamic>);
      }
      print("Profile document not found for user: $userId");
      return null; // Return null if profile doesn't exist
    } catch (e) {
      print("Error getting profile: $e");
      return null;
    }
  }

  Future<void> createOrUpdateProfile(String userId, Profile profileData) async {
    try {
      await _db.collection('profiles').doc(userId).set(
        profileData.toJson(),
        SetOptions(merge: true), // merge: true updates existing fields without overwriting the whole doc
      );
      print("Profile created/updated for user: $userId");
    } catch (e) {
      print("Error creating/updating profile: $e");
      // Re-throw the error if you want the UI layer to handle it
      throw FirebaseException(plugin: 'FirestoreService', message: e.toString());
    }
  }

// --- TPO Profile (Placeholder - Add later) ---
// Future<TpoProfile?> getTpoProfile(String userId) async { ... }
// Future<void> createOrUpdateTpoProfile(String userId, TpoProfile tpoProfileData) async { ... }

// --- Other Potential Methods ---
// Future<List<Profile>> getAlumniByBatch(int graduationYear) async { ... }
}