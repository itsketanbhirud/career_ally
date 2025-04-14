import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String uid; // Store UID for reference, maybe not directly in Firestore doc
  final String? name;
  final String? email; // Can store email here too, though it's in Auth/users
  final String? department;
  final int? batchYear;
  final int? graduationYear; // Expected graduation year
  final List<String>? skills;
  final String? resumeUrl;
  final Map<String, String>? contactInfo; // e.g., {'phone': '...', 'linkedin': '...'}
  final Map<String, dynamic>? academicInfo; // e.g., {'cgpa': 8.5, 'tenth': 90.0, 'twelfth': 88.0}
  final List<Map<String, String>>? projects; // e.g., [{'title': '...', 'desc': '...'}, ...]
  final List<Map<String, String>>? experience; // e.g., [{'company': '...', 'role': '...'}, ...]
  final String? profilePictureUrl;

  // Alumni specific fields (will be null for students)
  final String? currentCompany;
  final String? currentJobTitle;
  final Timestamp? alumniSince; // When they transitioned to alumni

  Profile({
    required this.uid,
    this.name,
    this.email,
    this.department,
    this.batchYear,
    this.graduationYear,
    this.skills,
    this.resumeUrl,
    this.contactInfo,
    this.academicInfo,
    this.projects,
    this.experience,
    this.profilePictureUrl,
    this.currentCompany,
    this.currentJobTitle,
    this.alumniSince,
  });

  // Factory constructor to create a Profile object from Firestore data (Map)
  factory Profile.fromJson(String uid, Map<String, dynamic> json) {
    // Helper to safely cast lists
    List<T>? _castList<T>(dynamic listData) {
      if (listData == null || listData is! List) return null;
      try {
        // Firestore often returns List<dynamic>, need to cast map elements
        if (T == Map<String, String>) {
          return listData.map((item) => Map<String, String>.from(item as Map)).toList().cast<T>();
        }
        return List<T>.from(listData);
      } catch (e) {
        print("Error casting list: $e"); // Log error
        return null; // Return null or empty list on error
      }
    }


    return Profile(
      uid: uid, // Use the document ID passed in
      name: json['name'] as String?,
      email: json['email'] as String?,
      department: json['department'] as String?,
      batchYear: json['batchYear'] as int?,
      graduationYear: json['graduationYear'] as int?,
      skills: _castList<String>(json['skills']),
      resumeUrl: json['resumeUrl'] as String?,
      contactInfo: json['contactInfo'] != null ? Map<String, String>.from(json['contactInfo']) : null,
      academicInfo: json['academicInfo'] != null ? Map<String, dynamic>.from(json['academicInfo']) : null,
      projects: _castList<Map<String, String>>(json['projects']),
      experience: _castList<Map<String, String>>(json['experience']),
      profilePictureUrl: json['profilePictureUrl'] as String?,
      currentCompany: json['currentCompany'] as String?,
      currentJobTitle: json['currentJobTitle'] as String?,
      alumniSince: json['alumniSince'] as Timestamp?,
    );
  }

  // Method to convert a Profile object back into a Map suitable for Firestore
  Map<String, dynamic> toJson() {
    return {
      // Don't include uid in the document data itself, it's the doc ID
      if (name != null) 'name': name,
      if (email != null) 'email': email, // Optional to store here
      if (department != null) 'department': department,
      if (batchYear != null) 'batchYear': batchYear,
      if (graduationYear != null) 'graduationYear': graduationYear,
      if (skills != null) 'skills': skills,
      if (resumeUrl != null) 'resumeUrl': resumeUrl,
      if (contactInfo != null) 'contactInfo': contactInfo,
      if (academicInfo != null) 'academicInfo': academicInfo,
      if (projects != null) 'projects': projects,
      if (experience != null) 'experience': experience,
      if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      if (currentCompany != null) 'currentCompany': currentCompany,
      if (currentJobTitle != null) 'currentJobTitle': currentJobTitle,
      if (alumniSince != null) 'alumniSince': alumniSince,
    }..removeWhere((key, value) => value == null); // Clean up null values before sending
  }
}