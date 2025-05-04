import 'package:cloud_firestore/cloud_firestore.dart';

class GuidancePost {
  final String id; // Document ID
  final String title; // Question or topic title
  final String? description; // Optional initial description/details
  final Timestamp postedAt;
  final String postedByUid;
  final String postedByName;
  final String postedByRole;
  final int replyCount; // Keep track of replies for easy display

  GuidancePost({
    required this.id,
    required this.title,
    this.description,
    required this.postedAt,
    required this.postedByUid,
    required this.postedByName,
    required this.postedByRole,
    this.replyCount = 0, // Default to 0
  });

  factory GuidancePost.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GuidancePost(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      description: data['description'] as String?,
      postedAt: data['postedAt'] is Timestamp ? data['postedAt'] : Timestamp.now(),
      postedByUid: data['postedByUid'] ?? '',
      postedByName: data['postedByName'] ?? 'Unknown User',
      postedByRole: data['postedByRole'] ?? 'unknown',
      replyCount: data['replyCount'] ?? 0,
    );
  }
}