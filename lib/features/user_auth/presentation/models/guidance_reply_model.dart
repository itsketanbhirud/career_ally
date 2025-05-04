import 'package:cloud_firestore/cloud_firestore.dart';

class GuidanceReply {
  final String id; // Document ID of the reply itself
  final String postId; // ID of the parent GuidancePost
  final String text; // The content of the reply
  final Timestamp repliedAt;
  final String repliedByUid;
  final String repliedByName;
  final String repliedByRole;

  GuidanceReply({
    required this.id,
    required this.postId,
    required this.text,
    required this.repliedAt,
    required this.repliedByUid,
    required this.repliedByName,
    required this.repliedByRole,
  });

  factory GuidanceReply.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GuidanceReply(
      id: doc.id,
      // postId is implicitly known when fetching from subcollection, but good practice to store? Optional.
      postId: data['postId'] ?? doc.reference.parent.parent?.id ?? '', // Get parent doc ID if not stored
      text: data['text'] ?? '',
      repliedAt: data['repliedAt'] is Timestamp ? data['repliedAt'] : Timestamp.now(),
      repliedByUid: data['repliedByUid'] ?? '',
      repliedByName: data['repliedByName'] ?? 'Unknown User',
      repliedByRole: data['repliedByRole'] ?? 'unknown',
    );
  }
}