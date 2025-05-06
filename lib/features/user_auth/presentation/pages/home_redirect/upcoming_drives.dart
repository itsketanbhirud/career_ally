// lib/screens/home_redirect/upcoming_drives.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
// Adjust import paths based on your project structure
import '../../services/firestore_service.dart';
import '../../models/upcoming_drive_model.dart';
import '../../widgets/drive_form_dialog.dart';
import 'drive_detail_screen.dart'; // Import the detail screen

class UpcomingDrivesScreen extends StatefulWidget {
  const UpcomingDrivesScreen({super.key});

  @override
  State<UpcomingDrivesScreen> createState() => _UpcomingDrivesScreenState();
}

class _UpcomingDrivesScreenState extends State<UpcomingDrivesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  User? _currentUser;
  String? _currentUserRole;
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndRole();
  }

  // Load user role to conditionally show TPO controls
  Future<void> _loadCurrentUserAndRole() async {
    if (!mounted) return;
    setState(() { _isLoading = true; });
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      _currentUserRole = await _firestoreService.getUserRole(_currentUser!.uid);
      _currentUserName = await _firestoreService.getUserDisplayName(_currentUser!.uid);
    }
    if (!mounted) return;
    setState(() { _isLoading = false; });
  }

  // --- Function to show Add/Edit Drive Dialog ---
  Future<void> _showDriveDialog({UpcomingDrive? drive}) async {
    // (Implementation remains the same as previous correct version)
    if (_currentUser == null || _currentUserName == null || _currentUserRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User information not loaded. Please wait.')));
      return;
    }
    final result = await showDialog<Map<String, dynamic>>( context: context, barrierDismissible: false, builder: (_) => DriveFormDialog(drive: drive),);
    if (result != null && mounted) {
      setState(() { _isLoading = true; });
      try {
        if (drive == null) {
          await _firestoreService.addUpcomingDrive(
            companyName: result['companyName'] as String, jobTitle: result['jobTitle'] as String, description: result['description'] as String,
            driveDate: result['driveDate'] as Timestamp, applyLink: result['applyLink'] as String?, requiredTechnologies: result['requiredTechnologies'] as List<String>?,
            postedByUid: _currentUser!.uid, postedByName: _currentUserName ?? "TPO",
          );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Drive added successfully!')));
        } else {
          await _firestoreService.updateUpcomingDrive(
            driveId: drive.id, companyName: result['companyName'] as String, jobTitle: result['jobTitle'] as String, description: result['description'] as String,
            driveDate: result['driveDate'] as Timestamp, applyLink: result['applyLink'] as String?, requiredTechnologies: result['requiredTechnologies'] as List<String>?,
          );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Drive updated successfully!')));
        }
      } catch (e) { /* ... error handling ... */ print("Error saving drive: $e"); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving drive: ${e.toString()}'))); }
      finally { if (mounted) setState(() { _isLoading = false; }); }
    }
  }

  // --- Function to confirm and delete a drive ---
  Future<void> _confirmDeleteDrive(String driveId, String companyName) async {
    // (Implementation remains the same as previous correct version)
    final bool? confirm = await showDialog<bool>( context: context, builder: (BuildContext context) { /* ... Confirmation Dialog ... */ return AlertDialog(title: Text('Confirm Deletion'), content: Text('Are you sure you want to delete the drive for "$companyName"?'), actions: <Widget>[ TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel')), TextButton(style: TextButton.styleFrom(foregroundColor: Colors.red), onPressed: () => Navigator.of(context).pop(true), child: Text('Delete')),],);},);
    if (confirm == true && mounted) {
      setState(() { _isLoading = true; });
      try { await _firestoreService.deleteUpcomingDrive(driveId: driveId); if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Drive deleted successfully!'))); }
      catch (e) { /* ... error handling ... */ print("Error deleting drive: $e"); if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting drive: ${e.toString()}'))); }
      finally { if(mounted) setState(() { _isLoading = false; }); }
    }
  }

  // --- Function to launch URLs ---
  Future<void> _launchURL(BuildContext context, String? url) async {
    // (Implementation remains the same as previous correct version)
    if (url == null || url.isEmpty) { /* ... handle missing url ... */ return; }
    final String trimmedUrl = url.trim(); Uri? uri;
    try { String urlToParse = trimmedUrl; if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) { urlToParse = 'https://$trimmedUrl'; } uri = Uri.parse(urlToParse); }
    catch (e) { /* ... handle parse error ... */ if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid URL format: $trimmedUrl'))); return; }
    if (!uri.scheme.startsWith('http')) { /* ... handle non-web scheme ... */ if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot launch non-web URL: $trimmedUrl'))); return; }
    bool canLaunch = false; try { canLaunch = await canLaunchUrl(uri); } catch(e) { /* ... handle canLaunchUrl error ... */ return;}
    if (!canLaunch) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $trimmedUrl'))); }
    else { try { await launchUrl(uri, mode: LaunchMode.externalApplication); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to launch URL: ${e.toString()}'))); } }
  }

  @override
  Widget build(BuildContext context) {
    bool isTpo = _currentUserRole == 'tpo';

    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Drives', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          StreamBuilder<List<UpcomingDrive>>(
            stream: _firestoreService.getUpcomingDrivesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No upcoming drives announced yet.'));
              }

              final drives = snapshot.data!;
              // Use ListView.builder for scrollable list
              return ListView.builder( // Changed from GridView to ListView
                padding: const EdgeInsets.all(10.0), // Adjust padding as needed
                itemCount: drives.length,
                itemBuilder: (context, index) {
                  final drive = drives[index];
                  // ***** WRAP Card with GestureDetector *****
                  return GestureDetector(
                    onTap: () {
                      // Navigate to detail screen when card body is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DriveDetailScreen(drive: drive),
                        ),
                      );
                    },
                    child: _buildDriveCard(drive, isTpo), // Pass drive and TPO status
                  );
                  // ***** END OF WRAP *****
                },
              );
            },
          ),
          if (_isLoading) // Loading overlay
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      // Show FAB only for TPO users
      floatingActionButton: isTpo ? FloatingActionButton(
        onPressed: () => _showDriveDialog(),
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Upcoming Drive',
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,
      ) : null,
    );
  }

  // Updated Card Widget (Internal Structure remains the same)
  Widget _buildDriveCard(UpcomingDrive drive, bool isTpo) {
    // Card is NOT wrapped in GestureDetector here
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row( // Title and TPO Buttons
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded( child: Text( drive.companyName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple), overflow: TextOverflow.ellipsis,)),
                if (isTpo) Row( mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: Icon(Icons.edit, size: 20, color: Colors.blueGrey), padding: EdgeInsets.zero, constraints: BoxConstraints(), tooltip: 'Edit Drive', onPressed: () => _showDriveDialog(drive: drive),),
                  SizedBox(width: 8),
                  IconButton(icon: Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), padding: EdgeInsets.zero, constraints: BoxConstraints(), tooltip: 'Delete Drive', onPressed: () => _confirmDeleteDrive(drive.id, drive.companyName),),
                ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(drive.jobTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[850])),
            SizedBox(height: 8),
            Row( // Date
              children: [ Icon(Icons.calendar_today, size: 14, color: Colors.blueGrey), SizedBox(width: 6), Text("Drive Date: ${DateFormat('EEE, MMM d, yyyy').format(drive.driveDate.toDate())}", style: TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w500),),],
            ),
            SizedBox(height: 12),
            Text(drive.description, style: TextStyle(fontSize: 15, color: Colors.grey[700]), maxLines: 3, overflow: TextOverflow.ellipsis,), // Reduced maxLines slightly for card view
            if (drive.requiredTechnologies != null && drive.requiredTechnologies!.isNotEmpty) ...[
              SizedBox(height: 10), Text("Key Technologies:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)), SizedBox(height: 4),
              Wrap( spacing: 6.0, runSpacing: 4.0, children: drive.requiredTechnologies!.map((tech) => Chip( label: Text(tech, style: TextStyle(fontSize: 12)), backgroundColor: Colors.deepPurple.shade50, padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2), visualDensity: VisualDensity.compact,)).toList(),)
            ],
            SizedBox(height: 12),
            Row( // Row for Apply Button and Posted By Info
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end, // Align items at bottom
              children: [
                // Posted By Info (aligned left)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0), // Add some space above
                    child: Text(
                      "Announced by: ${drive.postedByName}",
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // Apply Button (aligned right - only if link exists)
                if (drive.applyLink != null && drive.applyLink!.isNotEmpty)
                  ElevatedButton(
                    onPressed: () => _launchURL(context, drive.applyLink!),
                    child: Text("Apply / Details", style: TextStyle(fontSize: 13, color: Colors.white)),
                    style: ElevatedButton.styleFrom( backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), visualDensity: VisualDensity.compact,),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} // End of _UpcomingDrivesScreenState