// lib/screens/alumni_guidance/alumni_guidance_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../models/guidance_post_model.dart';
import 'guidance_post_detail_screen.dart'; // Screen for viewing replies
import 'add_guidance_post_screen.dart'; // Screen/Dialog for adding posts

class AlumniGuidanceScreen extends StatefulWidget {
  const AlumniGuidanceScreen({super.key});

  @override
  _AlumniGuidanceScreenState createState() => _AlumniGuidanceScreenState();
}

class _AlumniGuidanceScreenState extends State<AlumniGuidanceScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _currentUser;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserRole(); // Load role for delete permissions
  }

  Future<void> _loadCurrentUserRole() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _currentUserRole = await _firestoreService.getUserRole(_currentUser!.uid);
      if (mounted) setState(() {}); // Trigger rebuild if role check needed for UI
    }
  }

  Future<void> _confirmDeletePost(String postId, String postTitle) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) { /* ... Confirmation Dialog ... */
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the post "$postTitle" and all its replies?'), // Warn about replies
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel')),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true), child: Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirm == true && mounted) {
      // Consider showing loading indicator
      try {
        await _firestoreService.deleteGuidancePost(postId: postId);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post deleted successfully.')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting post: ${e.toString()}')));
      } finally {
        // Hide loading indicator
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guidance Forum', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        // Removed automaticallyImplyLeading: false
      ),
      body: StreamBuilder<List<GuidancePost>>(
        stream: _firestoreService.getGuidancePostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No guidance topics or questions posted yet.'));
          }

          final posts = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              bool canDelete = (_currentUserRole == 'tpo') || (_currentUser?.uid == post.postedByUid);

              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(15.0),
                  title: Text(post.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.deepPurple.shade700)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (post.description != null && post.description!.isNotEmpty) ...[
                          Text(post.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700])),
                          SizedBox(height: 8),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("By: ${post.postedByName} (${post.postedByRole})", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey)),
                            Text("${post.replyCount} Replies", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                        Text(DateFormat('MMM d, yyyy').format(post.postedAt.toDate()), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  trailing: canDelete ? IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: 'Delete Post',
                    onPressed: () => _confirmDeletePost(post.id, post.title),
                  ) : null,
                  onTap: () {
                    // Navigate to detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GuidancePostDetailScreen(post: post),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to a screen or show dialog to add a new post
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddGuidancePostScreen()));
        },
        tooltip: 'Ask Question / Add Topic',
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: Icon(Icons.add_comment_outlined, color: Colors.white),
      ),
    );
  }
}