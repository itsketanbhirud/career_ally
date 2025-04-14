// import 'package:firebase_auth/firebase_auth.dart';
//
// class FirebaseAuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   Future<User?> signUpWithEmailAndPassword(
//       String email, String password) async {
//     try {
//       UserCredential credential = await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       return credential.user;
//     } catch (e) {
//       print("some error occured");
//     }
//     return null;
//   }
//
//   Future<User?> signInWithEmailAndPassword(
//       String email, String password) async {
//     try {
//       UserCredential credential = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);
//       return credential.user;
//     } catch (e) {
//       print("some error occured");
//     }
//     return null;
//   }
// }


// firebase_auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String role,String username) async {  // Added 'role' parameter
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = credential.user;

      if (user != null) {
        // Store user role in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'role': role,       // Store the role
          'username': username,    // Initialize with empty string, to be updated later maybe
          // Add other user data here as needed
        });
      }

      return user; // Return the User object
    } catch (e) {
      print("Error occurred during signup: $e");
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } catch (e) {
      print("some error occured");
    }
    return null;
  }
}