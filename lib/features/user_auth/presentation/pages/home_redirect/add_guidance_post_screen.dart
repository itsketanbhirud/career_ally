// lib/screens/alumni_guidance/add_guidance_post_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart'; // Adjust path

class AddGuidancePostScreen extends StatefulWidget {
  const AddGuidancePostScreen({super.key});

  @override
  _AddGuidancePostScreenState createState() => _AddGuidancePostScreenState();
}

class _AddGuidancePostScreenState extends State<AddGuidancePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSubmitting = false;

  String? _currentUserName;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _currentUserName = await _firestoreService.getUserDisplayName(user.uid);
      _currentUserRole = await _firestoreService.getUserRole(user.uid);
    }
    // No need to setState here unless UI depends on it before submit
  }


  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return; // Don't submit if validation fails
    }
    if (_auth.currentUser == null || _currentUserName == null || _currentUserRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: User data not available.')));
      return;
    }

    setState(() { _isSubmitting = true; });

    try {
      await _firestoreService.addGuidancePost(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(), // Store null if empty
        postedByUid: _auth.currentUser!.uid,
        postedByName: _currentUserName!,
        postedByRole: _currentUserRole!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post submitted successfully!')));
        Navigator.of(context).pop(); // Go back after successful post
      }
    } catch (e) {
      print("Error submitting post: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting post: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() { _isSubmitting = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Guidance Post', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                    labelText: 'Question / Topic Title *',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., How to prepare for coding interviews?'
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a title' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                    labelText: 'Description / Details (Optional)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    hintText: 'Provide more context or details here...'
                ),
                maxLines: 6, // Allow more lines for description
                // No validator needed as it's optional
              ),
              Spacer(), // Pushes button to bottom
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: _isSubmitting
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Submit Post', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 10), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}