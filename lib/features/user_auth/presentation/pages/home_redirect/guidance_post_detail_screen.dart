// lib/screens/alumni_guidance/guidance_post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../models/guidance_post_model.dart';
import '../../models/guidance_reply_model.dart';

class GuidancePostDetailScreen extends StatefulWidget {
  final GuidancePost post;

  const GuidancePostDetailScreen({super.key, required this.post});

  @override
  _GuidancePostDetailScreenState createState() => _GuidancePostDetailScreenState();
}

class _GuidancePostDetailScreenState extends State<GuidancePostDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _replyController = TextEditingController();
  bool _isPostingReply = false;

  User? _currentUser;
  String? _currentUserRole;
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndRole();
  }

  Future<void> _loadCurrentUserAndRole() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _currentUserRole = await _firestoreService.getUserRole(_currentUser!.uid);
      _currentUserName = await _firestoreService.getUserDisplayName(_currentUser!.uid);
      if (mounted) setState(() {}); // Update state if needed
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _postReply() async {
    if (_replyController.text.trim().isEmpty) return; // Don't post empty replies
    if (_currentUser == null || _currentUserName == null || _currentUserRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: User data not available.')));
      return;
    }

    setState(() { _isPostingReply = true; });

    try {
      await _firestoreService.addGuidanceReply(
        postId: widget.post.id,
        text: _replyController.text.trim(),
        repliedByUid: _currentUser!.uid,
        repliedByName: _currentUserName!,
        repliedByRole: _currentUserRole!,
      );
      _replyController.clear(); // Clear field after successful post
      FocusScope.of(context).unfocus(); // Hide keyboard
    } catch (e) {
      print("Error posting reply: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error posting reply: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() { _isPostingReply = false; });
      }
    }
  }

  Future<void> _confirmDeleteReply(String replyId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) { /* ... Confirmation Dialog ... */
        return AlertDialog(
          title: Text('Confirm Delete Reply'),
          content: Text('Are you sure you want to delete this reply?'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel')),
            TextButton(style: TextButton.styleFrom(foregroundColor: Colors.red), onPressed: () => Navigator.of(context).pop(true), child: Text('Delete')),
          ],
        );
      },
    );
    if (confirm == true && mounted) {
      // Consider showing loading indicator
      try {
        await _firestoreService.deleteGuidanceReply(postId: widget.post.id, replyId: replyId);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reply deleted successfully.')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting reply: ${e.toString()}')));
      } finally {
        // Hide loading indicator
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Discussion", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Original Post Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.post.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade800)),
                SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("By: ${widget.post.postedByName} (${widget.post.postedByRole})", style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.blueGrey)),
                  Text(DateFormat('MMM d, yyyy - hh:mm a').format(widget.post.postedAt.toDate()), style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ]),
                if (widget.post.description != null && widget.post.description!.isNotEmpty) ...[
                  Divider(height: 20),
                  SelectableText(widget.post.description!, style: TextStyle(fontSize: 16, height: 1.4)),
                ],
                Divider(height: 20, thickness: 1.5),
                Text("Replies (${widget.post.replyCount})", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              ],
            ),
          ),
          // Replies List Section
          Expanded(
            child: StreamBuilder<List<GuidanceReply>>(
              stream: _firestoreService.getGuidanceRepliesStream(widget.post.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(strokeWidth: 2));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading replies.'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No replies yet. Be the first to reply!'));
                }
                final replies = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0), // Adjust padding
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    final reply = replies[index];
                    bool canDeleteReply = (_currentUserRole == 'tpo') || (_currentUser?.uid == reply.repliedByUid);

                    return Card(
                      elevation: 1,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        title: Text(reply.repliedByName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.deepPurple)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(reply.text, style: TextStyle(fontSize: 15)),
                            SizedBox(height: 6),
                            Text(DateFormat('MMM d, hh:mm a').format(reply.repliedAt.toDate()), style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        trailing: canDeleteReply ? IconButton(
                          icon: Icon(Icons.delete_outline, size: 18, color: Colors.redAccent.withOpacity(0.8)),
                          onPressed: () => _confirmDeleteReply(reply.id),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          tooltip: 'Delete Reply',
                        ) : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Reply Input Section
          if (_currentUser != null) // Only show input if logged in
            _buildReplyInputSection(),
        ],
      ),
    );
  }

  Widget _buildReplyInputSection() {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                hintText: 'Write a reply...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
              maxLines: null, // Allows multiline input
              textInputAction: TextInputAction.newline, // Suggest newline
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: _isPostingReply
                ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.send, color: Colors.deepPurple),
            onPressed: _isPostingReply ? null : _postReply,
            tooltip: 'Post Reply',
          ),
        ],
      ),
    );
  }

}