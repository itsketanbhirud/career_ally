import 'package:cloud_firestore/cloud_firestore.dart';

class PlacementResource {
  final String id; // Document ID
  final String title;
  final String description;
  final String url; // Link to the resource
  final Timestamp postedAt;
  final String postedByUid;
  final String postedByName;
  final String postedByRole; // 'student', 'alumni', 'tpo'

  PlacementResource({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.postedAt,
    required this.postedByUid,
    required this.postedByName,
    required this.postedByRole,
  });

  factory PlacementResource.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PlacementResource(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? '',
      url: data['url'] ?? '',
      postedAt: data['postedAt'] is Timestamp ? data['postedAt'] : Timestamp.now(),
      postedByUid: data['postedByUid'] ?? '',
      postedByName: data['postedByName'] ?? 'Unknown User',
      postedByRole: data['postedByRole'] ?? 'unknown',
    );
  }
}