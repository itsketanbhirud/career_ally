import 'package:cloud_firestore/cloud_firestore.dart';

class TpoUpdate {
  final String id; // Document ID
  final String title;
  final String description;
  final Timestamp postedAt;
  final String postedByUid;
  final String postedByName;

  TpoUpdate({
    required this.id,
    required this.title,
    required this.description,
    required this.postedAt,
    required this.postedByUid,
    required this.postedByName,
  });

  factory TpoUpdate.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TpoUpdate(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? '',
      // Handle potential null timestamp or incorrect type gracefully
      postedAt: data['postedAt'] is Timestamp ? data['postedAt'] : Timestamp.now(),
      postedByUid: data['postedByUid'] ?? '',
      postedByName: data['postedByName'] ?? 'Unknown TPO',
    );
  }
}