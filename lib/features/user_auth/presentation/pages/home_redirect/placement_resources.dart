// lib/screens/placement_resources.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Ensure this is imported
// Adjust import paths based on your project structure
import '../../services/firestore_service.dart';
import '../../models/placement_resource_model.dart';
import '../../widgets/resource_form_dialog.dart';

class PlacementResourcesScreen extends StatefulWidget {
  const PlacementResourcesScreen({super.key});

  @override
  _PlacementResourcesScreenState createState() => _PlacementResourcesScreenState();
}

class _PlacementResourcesScreenState extends State<PlacementResourcesScreen> {
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

  Future<void> _showAddResourceDialog() async {
    if (_currentUser == null || _currentUserName == null || _currentUserRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User information not loaded. Please wait.')));
      return;
    }
    final result = await showDialog<Map<String, String>>(
      context: context, barrierDismissible: false, builder: (_) => ResourceFormDialog(),
    );
    if (result != null && mounted) {
      setState(() { _isLoading = true; });
      try {
        await _firestoreService.addPlacementResource(
          title: result['title']!, description: result['description']!, url: result['url']!,
          postedByUid: _currentUser!.uid,
          postedByName: _currentUserName ?? "Unknown",
          postedByRole: _currentUserRole ?? "unknown",
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Resource added successfully!')));
      } catch (e) {
        print("Error adding resource: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding resource: ${e.toString()}')));
      } finally {
        if (mounted) setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _confirmDelete(String resourceId, String resourceTitle) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the resource "$resourceTitle"?'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel')),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirm == true && mounted) {
      setState(() { _isLoading = true; });
      try {
        await _firestoreService.deletePlacementResource(resourceId: resourceId);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Resource deleted successfully!')));
      } catch (e) {
        print("Error deleting resource: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting resource: ${e.toString()}')));
      } finally {
        if(mounted) setState(() { _isLoading = false; });
      }
    }
  }

  // --- Function to launch URLs (Robust Version) ---
  Future<void> _launchURL(BuildContext context, String url) async { // Pass context
    final String trimmedUrl = url.trim();
    print("Attempting to launch URL: '$trimmedUrl'");
    Uri? uri;

    try {
      // Prepend https:// if scheme is missing
      String urlToParse = trimmedUrl;
      if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
        urlToParse = 'https://$trimmedUrl';
        print("Prepended 'https://' to URL: '$urlToParse'");
      }
      uri = Uri.parse(urlToParse);
    } catch (e) {
      print("Error parsing URL: $e");
      if (mounted) { // Check if mounted before showing snackbar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid URL format: $trimmedUrl')));
      }
      return;
    }

    // Check scheme again after parsing
    if (!uri.scheme.startsWith('http')) {
      print("URL scheme is not http or https.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot launch non-web URL: $trimmedUrl')));
      }
      return;
    }

    bool canLaunch = false;
    try {
      canLaunch = await canLaunchUrl(uri);
      print("Can launch '$trimmedUrl'? $canLaunch");
    } catch(e) {
      print("Error checking canLaunchUrl: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error checking if URL can be launched.')));
      }
      return;
    }

    if (!canLaunch) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $trimmedUrl. Ensure a browser or relevant app is installed.')));
      }
    } else {
      try {
        print("Launching URL...");
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print("Launch command issued.");
      } catch (e) {
        print("Error during launchUrl: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to launch URL: ${e.toString()}')));
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Placement Resources', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack( // Stack for loading indicator overlay
        children: [
          StreamBuilder<List<PlacementResource>>(
            stream: _firestoreService.getPlacementResourcesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || (_isLoading && snapshot.data == null)) { // Show loader also during initial load
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No resources posted yet. Tap + to add one.'));
              }

              final resources = snapshot.data!;
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
                  childAspectRatio: 0.85, // Adjusted ratio
                ),
                padding: EdgeInsets.all(16),
                itemCount: resources.length,
                itemBuilder: (context, index) {
                  final resource = resources[index];
                  // ***** Wrap the Card with GestureDetector *****
                  return GestureDetector(
                    onTap: () {
                      // Navigate to detail screen when card body is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResourceDetailScreen(resource: resource),
                        ),
                      );
                    },
                    child: _buildResourceCard(resource), // Pass context to card builder
                  );
                  // ***** End of GestureDetector *****
                },
              );
            },
          ),
          if (_isLoading && _currentUser != null) // Loading overlay during actions
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: _currentUser != null
          ? FloatingActionButton(
        onPressed: _showAddResourceDialog,
        tooltip: 'Add Resource',
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

  // Card Widget - Builds the visual representation of the resource
  Widget _buildResourceCard(PlacementResource resource) {
    bool canDelete = (_currentUserRole == 'tpo') || (_currentUser?.uid == resource.postedByUid);

    // The Card itself does not handle the main tap navigation anymore
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resource.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  SizedBox(height: 4),
                  Text(resource.description, style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis,),
                  SizedBox(height: 6),
                  Text("Posted by: ${resource.postedByName} (${resource.postedByRole})", style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  Text(DateFormat('MMM d, yyyy').format(resource.postedAt.toDate()), style: TextStyle(fontSize: 11, color: Colors.grey[600]),),
                ],
              )
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  // Pass context to _launchURL for potential Snackbars
                  onPressed: () => _launchURL(context, resource.url),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact,
                  ),
                  // onPressed: () => _launchURL(context, resource.url),
                  child: Text('Open Link', style: TextStyle(fontSize: 13, color: Colors.white)),
                ),
                if (canDelete)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    padding: EdgeInsets.zero, constraints: BoxConstraints(), tooltip: 'Delete Resource',
                    onPressed: () => _confirmDelete(resource.id, resource.title),
                  ),
                if (!canDelete) SizedBox(width: 40) // Placeholder for spacing
              ],
            ),
          ),
        ],
      ),
    );
  }
} // End of _PlacementResourcesScreenState


// --- ResourceDetailScreen ---
// (Ensure this class definition exists below or in its own imported file)
class ResourceDetailScreen extends StatelessWidget {
  final PlacementResource resource;

  const ResourceDetailScreen({super.key, required this.resource});

  // Replicated robust launch function here (consider moving to a shared utility file)
  Future<void> _launchURL(BuildContext context, String url) async {
    final String trimmedUrl = url.trim();
    print("DetailScreen: Attempting to launch URL: '$trimmedUrl'");
    Uri? uri;
    try {
      String urlToParse = trimmedUrl;
      if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
        urlToParse = 'https://$trimmedUrl';
      }
      uri = Uri.parse(urlToParse);
    } catch (e) {
      print("DetailScreen: Error parsing URL: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid URL format: $trimmedUrl')));
      return;
    }
    if (!uri.scheme.startsWith('http')) {
      print("DetailScreen: URL scheme is not http or https.");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot launch non-web URL: $trimmedUrl')));
      return;
    }
    bool canLaunch = false;
    try { canLaunch = await canLaunchUrl(uri); } catch(e) { /* ... error handling ... */
      print("DetailScreen: Error checking canLaunchUrl: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error checking if URL can be launched.')));
      return;
    }

    if (!canLaunch) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $trimmedUrl')));
    } else {
      try { await launchUrl(uri, mode: LaunchMode.externalApplication); } catch (e) {
        print("DetailScreen: Error during launchUrl: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to launch URL: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(resource.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)), // Slightly smaller title
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(resource.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text("Posted by: ${resource.postedByName} (${resource.postedByRole})", style: TextStyle(fontSize: 14, color: Colors.blueGrey, fontStyle: FontStyle.italic), overflow: TextOverflow.ellipsis,),
                  ),
                  SizedBox(width: 10),
                  Text(DateFormat('MMM d, yyyy - hh:mm a').format(resource.postedAt.toDate()), style: TextStyle(fontSize: 14, color: Colors.grey[600])) // More precise time
                ],
              ),
              Divider(height: 24),
              SelectableText( // Make description selectable
                resource.description,
                style: TextStyle(fontSize: 16, height: 1.4),
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.link, color: Colors.white),
                  label: Text('Open Resource Link', style: TextStyle(fontSize: 14, color: Colors.white)),
                  // Wrap launch call in error handling within the screen
                  onPressed: () async {
                    try {
                      await _launchURL(context, resource.url); // Pass context
                    } catch (e) {
                      print("Error launching URL from DetailScreen: $e");
                      // Show snackbar directly in this context
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error launching URL: $e')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} // End of ResourceDetailScreen