import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart'; // Adjust import path if needed
import '../models/tpo_update_model.dart';
import '../models/placement_resource_model.dart';
import '../models/guidance_post_model.dart'; // Import new models
import '../models/guidance_reply_model.dart';
import '../models/upcoming_drive_model.dart';

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
// --- NEW METHODS for Placement Resources ---

  // Get Stream of Placement Resources
  Stream<List<PlacementResource>> getPlacementResourcesStream() {
    return _db
        .collection('placement_resources')
        .orderBy('postedAt', descending: true) // Show newest first
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PlacementResource.fromFirestore(doc))
        .toList());
  }

  // Add a new Placement Resource
  Future<void> addPlacementResource({
    required String title,
    required String description,
    required String url,
    required String postedByUid,
    required String postedByName,
    required String postedByRole,
  }) async {
    // Security rules should primarily handle authorization
    try {
      await _db.collection('placement_resources').add({
        'title': title,
        'description': description,
        'url': url,
        'postedAt': FieldValue.serverTimestamp(),
        'postedByUid': postedByUid,
        'postedByName': postedByName,
        'postedByRole': postedByRole,
      });
      print("Placement Resource added successfully.");
    } catch (e) {
      print("Error adding Placement Resource: $e");
      throw FirebaseException(plugin: 'FirestoreService', message: e.toString());
    }
  }

  // Delete a Placement Resource
  Future<void> deletePlacementResource({required String resourceId}) async {
    // Authorization (who can delete) should be primarily enforced by Security Rules
    try {
      await _db.collection('placement_resources').doc(resourceId).delete();
      print("Placement Resource $resourceId deleted successfully.");
    } catch (e) {
      print("Error deleting Placement Resource $resourceId: $e");
      throw FirebaseException(plugin: 'FirestoreService', message: e.toString());
    }
  }

  // --- Helper to get User name (reuse or adapt from TPO name fetch) ---
  // It's often better to fetch the name once when the screen loads
  Future<String?> getUserDisplayName(String userId) async {
    try {
      // Check profile first? Or just users collection?
      DocumentSnapshot userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        // Assuming 'username' field holds the display name
        return userDoc.get('username') as String?;
      }
      print("User name not found for UID: $userId");
      return "Unknown User";
    } catch (e) {
      print("Error getting user name: $e");
      return "Error Fetching Name";
    }
  }

  // Get Stream of Guidance Posts
  Stream<List<GuidancePost>> getGuidancePostsStream() {
    return _db
        .collection('guidance_forum')
        .orderBy('postedAt', descending: true) // Show newest first
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GuidancePost.fromFirestore(doc))
        .toList());
  }

  // Add a new Guidance Post (Question/Topic)
  Future<DocumentReference> addGuidancePost({ // Return DocumentReference to get ID
    required String title,
    String? description,
    required String postedByUid,
    required String postedByName,
    required String postedByRole,
  }) async {
    try {
      return await _db.collection('guidance_forum').add({
        'title': title,
        'description': description, // Can be null
        'postedAt': FieldValue.serverTimestamp(),
        'postedByUid': postedByUid,
        'postedByName': postedByName,
        'postedByRole': postedByRole,
        'replyCount': 0, // Initialize reply count
      });
    } catch (e) {
      print("Error adding Guidance Post: $e");
      throw FirebaseException(plugin: 'FirestoreService', message: e.toString());
    }
  }

  // Delete a Guidance Post (and its replies - requires Cloud Function ideally)
  // WARNING: Deleting subcollections from client-side is not recommended for large scale.
  // A Cloud Function triggered on document delete is the robust way.
  // This client-side version is for simpler cases or requires manual cleanup.
  Future<void> deleteGuidancePost({required String postId}) async {
    // Authorization handled by Security Rules
    try {
      // TODO: Implement Cloud Function to delete subcollection 'replies' reliably.
      // Simple client-side deletion (may leave orphaned replies if interrupted):
      await _db.collection('guidance_forum').doc(postId).delete();
      print("Guidance Post $postId deleted (client-side). Subcollection deletion recommended via Cloud Function.");
    } catch (e) {
      print("Error deleting Guidance Post $postId: $e");
      throw FirebaseException(plugin: 'FirestoreService', message: e.toString());
    }
  }

  // Get Stream of Replies for a Specific Post
  Stream<List<GuidanceReply>> getGuidanceRepliesStream(String postId) {
    return _db
        .collection('guidance_forum')
        .doc(postId)
        .collection('replies')
        .orderBy('repliedAt') // Show oldest reply first
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => GuidanceReply.fromFirestore(doc))
        .toList());
  }

  // Add a Reply to a Guidance Post
  Future<void> addGuidanceReply({
    required String postId,
    required String text,
    required String repliedByUid,
    required String repliedByName,
    required String repliedByRole,
  }) async {
    try {
      final postRef = _db.collection('guidance_forum').doc(postId);
      final replyRef = postRef.collection('replies');

      // Use a transaction to add reply and increment count atomically
      await _db.runTransaction((transaction) async {
        // Add the new reply
        transaction.set(replyRef.doc(), { // Auto-generate reply ID
          'postId': postId, // Optional: Store parent ID for easier queries later?
          'text': text,
          'repliedAt': FieldValue.serverTimestamp(),
          'repliedByUid': repliedByUid,
          'repliedByName': repliedByName,
          'repliedByRole': repliedByRole,
        });
        // Increment the reply count on the parent post
        transaction.update(postRef, {
          'replyCount': FieldValue.increment(1),
        });
      });
      print("Guidance Reply added successfully to post $postId.");
    } catch (e) {
      print("Error adding Guidance Reply to post $postId: $e");
      throw FirebaseException(plugin: 'FirestoreService', message: e.toString());
    }
  }

  // Delete a Guidance Reply (Requires knowing postId and replyId)
  // Also needs transaction to decrement count reliably
  Future<void> deleteGuidanceReply({required String postId, required String replyId}) async {
    // Authorization handled by Security Rules
    try {
      final postRef = _db.collection('guidance_forum').doc(postId);
      final replyRef = postRef.collection('replies').doc(replyId);

      await _db.runTransaction((transaction) async {
        // Check if reply exists before decrementing (optional safety)
        // DocumentSnapshot replySnapshot = await transaction.get(replyRef);
        // if (!replySnapshot.exists) throw Exception("Reply not found");

        // Delete the reply
        transaction.delete(replyRef);
        // Decrement the reply count (ensure count doesn't go below 0)
        transaction.update(postRef, {'replyCount': FieldValue.increment(-1)});
      });

      print("Guidance Reply $replyId deleted successfully from post $postId.");
    } catch (e) {
      print("Error deleting Guidance Reply $replyId from post $postId: $e");
      throw FirebaseException(plugin: 'FirestoreService', message: e.toString());
    }
  }
  // --- NEW METHODS for Upcoming Drives ---

  // Get Stream of Upcoming Drives (consider filtering past dates)
  Stream<List<UpcomingDrive>> getUpcomingDrivesStream() {
    // Get current timestamp to filter out past drives
    Timestamp now = Timestamp.now();

    return _db
        .collection('upcoming_drives')
        .where('driveDate', isGreaterThanOrEqualTo: now) // Only show future or current drives
        .orderBy('driveDate', descending: false) // Show nearest date first
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UpcomingDrive.fromFirestore(doc))
        .toList());
  }
  // Add a new Upcoming Drive (TPO only)
  Future<void> addUpcomingDrive({
    required String companyName,
    required String jobTitle,
    required String description,
    required Timestamp driveDate, // Use Timestamp for date/time
    String? applyLink,
    List<String>? requiredTechnologies,
    required String postedByUid,
    required String postedByName,
  }) async {
    // Authorization handled by Security Rules
    try {
      await _db.collection('upcoming_drives').add({
        'companyName': companyName,
        'jobTitle': jobTitle,
        'description': description,
        'driveDate': driveDate,
        'applyLink': applyLink, // Can be null
        'requiredTechnologies': requiredTechnologies, // Can be null or empty list
        'postedAt': FieldValue.serverTimestamp(), // When TPO posted this
        'postedByUid': postedByUid,
        'postedByName': postedByName,
      });
      print("Upcoming Drive added successfully.");
    } catch (e) {
      print("Error adding Upcoming Drive: $e");
      throw FirebaseException(plugin: 'FirestoreService', message: e.toString());
    }
  }

  // Update an Upcoming Drive (TPO only)
  Future<void> updateUpcomingDrive({
    required String driveId,
    required String companyName,
    required String jobTitle,
    required String description,
    required Timestamp driveDate,
    String? applyLink,
    List<String>? requiredTechnologies,
  }) async {
    // Authorization handled by Security Rules
    try {
      await _db.collection('upcoming_drives').doc(driveId).update({
        'companyName': companyName,
        'jobTitle': jobTitle,
        'description': description,
        'driveDate': driveDate,
        'applyLink': applyLink,
        'requiredTechnologies': requiredTechnologies,
        // Optionally update a 'lastEditedAt' field
      });
      print("Upcoming Drive $driveId updated successfully.");
    } catch (e) {
      print("Error updating Upcoming Drive $driveId: $e");
      throw FirebaseException(plugin: 'FirestoreService', message: e.toString());
    }
  }


  // Delete an Upcoming Drive (TPO only)
  Future<void> deleteUpcomingDrive({required String driveId}) async {
    // Authorization handled by Security Rules
    try {
      await _db.collection('upcoming_drives').doc(driveId).delete();
      print("Upcoming Drive $driveId deleted successfully.");
    } catch (e) {
      print("Error deleting Upcoming Drive $driveId: $e");
      throw FirebaseException(plugin: 'FirestoreService', message: e.toString());
    }
  }



}