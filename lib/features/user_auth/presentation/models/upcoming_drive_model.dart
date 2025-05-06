import 'package:cloud_firestore/cloud_firestore.dart';

class UpcomingDrive {
  final String id; // Document ID
  final String companyName;
  final String jobTitle; // Role(s) they are hiring for
  final String description; // More details, eligibility, process
  final Timestamp driveDate; // The actual date of the drive/visit
  final String? applyLink; // Optional link to apply/register externally
  final List<String>? requiredTechnologies; // List of key skills/tech
  final Timestamp postedAt; // When the TPO posted this info
  final String postedByUid; // TPO's UID
  final String postedByName; // TPO's Name

  UpcomingDrive({
    required this.id,
    required this.companyName,
    required this.jobTitle,
    required this.description,
    required this.driveDate,
    this.applyLink,
    this.requiredTechnologies,
    required this.postedAt,
    required this.postedByUid,
    required this.postedByName,
  });

  factory UpcomingDrive.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Helper to safely create list from Firestore data
    List<String>? _parseTechnologies(dynamic techData) {
      if (techData is List) {
        // Ensure elements are strings before casting
        return techData.map((item) => item.toString()).toList();
      }
      return null; // Return null if it's not a list
    }

    return UpcomingDrive(
      id: doc.id,
      companyName: data['companyName'] ?? 'N/A',
      jobTitle: data['jobTitle'] ?? 'N/A',
      description: data['description'] ?? '',
      // Ensure Timestamps are handled correctly
      driveDate: data['driveDate'] is Timestamp ? data['driveDate'] : Timestamp.now(), // Default if missing/invalid
      applyLink: data['applyLink'] as String?, // Can be null
      requiredTechnologies: _parseTechnologies(data['requiredTechnologies']), // Parse list safely
      postedAt: data['postedAt'] is Timestamp ? data['postedAt'] : Timestamp.now(),
      postedByUid: data['postedByUid'] ?? '',
      postedByName: data['postedByName'] ?? 'TPO',
    );
  }
}