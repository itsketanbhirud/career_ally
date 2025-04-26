// lib/screens/home_redirect/manage_updates.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get current TPO user
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../models/tpo_update_model.dart';
import '../../widgets/update_form_dialog.dart'; // Import the dialog

class ManageUpdatesScreen extends StatefulWidget {
  @override
  _ManageUpdatesScreenState createState() => _ManageUpdatesScreenState();
}

class _ManageUpdatesScreenState extends State<ManageUpdatesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false; // To show loading indicator during operations

  String? _currentTpoName; // Store TPO name for adding updates

  @override
  void initState() {
    super.initState();
    _fetchTpoName(); // Fetch the TPO's name when the screen loads
  }

  Future<void> _fetchTpoName() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final name = await _firestoreService.getTpoName(currentUser.uid);
      if(mounted) {
        setState(() {
          _currentTpoName = name;
        });
      }
    }
  }

  // --- Function to show the Add/Edit Dialog ---
  Future<void> _showUpdateDialog({TpoUpdate? update}) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (_) => UpdateFormDialog(update: update), // Pass update data if editing
    );

    // If user submitted data from dialog
    if (result != null && mounted) {
      setState(() { _isLoading = true; });
      try {
        User? currentUser = _auth.currentUser;
        // Ensure TPO info is available before adding/updating
        if (currentUser == null || (_currentTpoName == null && update == null)) {
          throw Exception("TPO information not available.");
        }

        if (update == null) {
          // Adding a new update
          await _firestoreService.addTpoUpdate(
            title: result['title']!,
            description: result['description']!,
            tpoUid: currentUser!.uid,
            tpoName: _currentTpoName ?? "TPO", // Fallback name
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update added successfully!')),
          );
        } else {
          // Editing an existing update
          await _firestoreService.updateTpoUpdate(
            updateId: update.id,
            newTitle: result['title']!,
            newDescription: result['description']!,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update modified successfully!')),
          );
        }
      } catch (e) {
        print("Error saving update: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving update: ${e.toString()}')),
        );
      } finally {
        if(mounted) setState(() { _isLoading = false; });
      }
    }
  }

  // --- Function to confirm and delete an update ---
  Future<void> _confirmDelete(String updateId, String updateTitle) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the update "$updateTitle"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Return false
              child: Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true), // Return true
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      setState(() { _isLoading = true; });
      try {
        await _firestoreService.deleteTpoUpdate(updateId: updateId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update deleted successfully!')),
        );
      } catch (e) {
        print("Error deleting update: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting update: ${e.toString()}')),
        );
      } finally {
        if(mounted) setState(() { _isLoading = false; });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage TPO Updates', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white), // Ensure back button is white
        backgroundColor: Colors.deepPurple,

      ),
      body: Stack( // Use Stack to overlay loading indicator
        children: [
          StreamBuilder<List<TpoUpdate>>(
            stream: _firestoreService.getTpoUpdatesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading updates: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No updates posted yet. Tap + to add one.'));
              }

              final updates = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: updates.length,
                itemBuilder: (context, index) {
                  final update = updates[index];
                  // Build card with Edit/Delete buttons
                  return _buildTpoUpdateCard(update);
                },
              );
            },
          ),
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      // Floating Action Button to add new updates
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUpdateDialog(), // Call dialog without existing update
        child: Icon(Icons.add),
        tooltip: 'Add New Update',
foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,

      ),
    );
  }

  // Card widget specifically for TPO view with Edit/Delete actions
  Widget _buildTpoUpdateCard(TpoUpdate update) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 8.0, bottom: 8.0), // Adjust padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              update.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 8),
            Text(
              update.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                // Left side: TPO Name and Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "By: ${update.postedByName}",
                        style: TextStyle(fontSize: 13, color: Colors.blueGrey, fontStyle: FontStyle.italic),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('yyyy-MM-dd hh:mm a').format(update.postedAt.toDate()),
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Right side: Action Buttons
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blueGrey, size: 20),
                  onPressed: () => _showUpdateDialog(update: update), // Pass update data
                  tooltip: 'Edit Update',
                  visualDensity: VisualDensity.compact, // Make button smaller
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _confirmDelete(update.id, update.title), // Call delete confirmation
                  tooltip: 'Delete Update',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}