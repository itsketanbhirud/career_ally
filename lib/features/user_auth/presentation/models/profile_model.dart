import 'package:cloud_firestore/cloud_firestore.dart';

// Helper function to safely cast lists (can be placed here or in a utils file)
// Helper function to safely cast lists
List<T>? _castList<T>(dynamic listData) {
  // 1. Basic checks: Ensure listData is actually a non-null List
  if (listData == null || listData is! List || listData.isEmpty) {
    // Return null or an empty list based on preference. Empty is often safer.
    return [];
  }

  // 2. Check the type of the FIRST element to infer the list type
  //    This assumes the list is homogeneous (all elements are the same type).
  var firstElement = listData.first;

  try {
    // 3. Specific check for List<Map<String, String>>
    //    Check if the first element is actually a Map
    if (firstElement is Map) {
      // Now we try to cast. If this cast fails, the source list wasn't List<Map>
      // Further check if T *is* Map<String,String> - This requires a slightly more complex approach
      // if T's expected type IS Map<String, String>, proceed with map conversion
      if (<Map<String, String>>[] is List<T>) { // Check if List<T> is assignable from List<Map<String,String>>
        return listData.map((item) => Map<String, String>.from(item as Map)).toList().cast<T>();
      } else {
        // If T is not Map<String, String> but first element IS a Map,
        // we might have a List<Map<String, dynamic>> or similar.
        // If T itself is Map or Map<dynamic, dynamic>, cast more generally.
        if(<Map>[] is List<T> || <Map<dynamic, dynamic>>[] is List<T>){
          return listData.map((item) => Map.from(item as Map)).toList().cast<T>();
        }
        // If T is something else entirely but data is List<Map>, it's a mismatch.
        print("Warning: _castList expected List<$T> but received List<Map>.");
        return []; // Return empty on type mismatch
      }
    }
    // 4. Check for List<String>
    else if (firstElement is String) {
      if(<String>[] is List<T>){ // Check if T is String
        return List<T>.from(listData);
      } else {
        print("Warning: _castList expected List<$T> but received List<String>.");
        return []; // Return empty on type mismatch
      }
    }
    // 5. Handle other potential primitive types if necessary (e.g., int, double)
    else if (firstElement is int) {
      if(<int>[] is List<T>){ return List<T>.from(listData); }
      else { print("Warning: _castList expected List<$T> but received List<int>."); return []; }
    }
    else if (firstElement is double) {
      if(<double>[] is List<T>){ return List<T>.from(listData); }
      else { print("Warning: _castList expected List<$T> but received List<double>."); return []; }
    }


    // 6. Fallback/General Case (or throw error)
    //    If the first element type doesn't match expected logic or T is complex,
    //    try a general cast, which might fail if types are incompatible.
    print("Warning: _castList attempting general cast for List<$T>.");
    return List<T>.from(listData);

  } catch (e) {
    print("Error casting list during element check: $e. Input type: ${listData.runtimeType}, Element type: ${firstElement.runtimeType}, Expected: List<$T>");
    return []; // Return empty list on casting error
  }
}

class Profile {
  final String uid;
  final String? name;
  final String? email;
  final String? department;
  final int? batchYear;
  final int? graduationYear;
  final List<String> skills; // Changed to non-nullable, defaults to empty list
  final String? resumeUrl;
  final Map<String, String> contactInfo; // Changed to non-nullable
  final Map<String, dynamic> academicInfo; // Changed to non-nullable
  final List<Map<String, String>> projects; // Changed to non-nullable
  final List<Map<String, String>> experience; // Changed to non-nullable
  final String? profilePictureUrl;

  // Alumni specific fields
  final String? currentCompany;
  final String? currentJobTitle;
  final Timestamp? alumniSince;

  Profile({
    required this.uid,
    this.name,
    this.email,
    this.department,
    this.batchYear,
    this.graduationYear,
    this.skills = const [], // Default to empty list
    this.resumeUrl,
    this.contactInfo = const {}, // Default to empty map
    this.academicInfo = const {}, // Default to empty map
    this.projects = const [], // Default to empty list
    this.experience = const [], // Default to empty list
    this.profilePictureUrl,
    this.currentCompany,
    this.currentJobTitle,
    this.alumniSince,
  });

  factory Profile.fromJson(String uid, Map<String, dynamic> json) {
    return Profile(
      uid: uid,
      name: json['name'] as String?,
      email: json['email'] as String?,
      department: json['department'] as String?,
      batchYear: json['batchYear'] as int?,
      graduationYear: json['graduationYear'] as int?,
      skills: _castList<String>(json['skills']) ?? [], // Use helper, default empty
      resumeUrl: json['resumeUrl'] as String?,
      contactInfo: json['contactInfo'] != null ? Map<String, String>.from(json['contactInfo']) : {}, // Default empty
      academicInfo: json['academicInfo'] != null ? Map<String, dynamic>.from(json['academicInfo']) : {}, // Default empty
      projects: _castList<Map<String, String>>(json['projects']) ?? [], // Use helper, default empty
      experience: _castList<Map<String, String>>(json['experience']) ?? [], // Use helper, default empty
      profilePictureUrl: json['profilePictureUrl'] as String?,
      currentCompany: json['currentCompany'] as String?,
      currentJobTitle: json['currentJobTitle'] as String?,
      alumniSince: json['alumniSince'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // uid is the document ID, not stored inside
      'name': name,
      'email': email,
      'department': department,
      'batchYear': batchYear,
      'graduationYear': graduationYear,
      'skills': skills,
      'resumeUrl': resumeUrl,
      'contactInfo': contactInfo,
      'academicInfo': academicInfo,
      'projects': projects,
      'experience': experience,
      'profilePictureUrl': profilePictureUrl,
      'currentCompany': currentCompany,
      'currentJobTitle': currentJobTitle,
      'alumniSince': alumniSince,
    }..removeWhere((key, value) => value == null || (value is List && value.isEmpty) || (value is Map && value.isEmpty) );
    // Also remove empty lists/maps to keep Firestore clean
  }
}