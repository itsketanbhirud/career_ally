// import 'package:flutter/material.dart';
//
// class ProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'My Profile',
//           style: TextStyle(
//               fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: Colors.deepPurple,
//         // iconTheme: IconThemeData(color: Colors.white),
//         automaticallyImplyLeading: false,
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: CircleAvatar(
//                 radius: 60,
//                 backgroundColor: Colors.deepPurple,
//                 child: Icon(Icons.person, size: 60, color: Colors.white),
//               ),
//             ),
//             SizedBox(height: 20),
//             buildProfileDetail('Name', 'Ketan Bhirud'),
//             buildProfileDetail('Email', 'ketanbhirud@example.com'),
//             buildProfileDetail('Position', 'Software Engineer'),
//             SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: () {},
//               icon: Icon(Icons.edit, color: Colors.white,),
//               label: Text('Edit Profile',style: TextStyle(color: Colors.white),),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//                 textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//             SizedBox(height: 20),
//             Divider(),
//             ListTile(
//               leading: Icon(Icons.settings, color: Colors.deepPurple),
//               title: Text('Settings'),
//               onTap: () {},
//             ),
//             ListTile(
//               leading: Icon(Icons.logout, color: Colors.deepPurple),
//               title: Text('Logout'),
//               onTap: () {},
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildProfileDetail(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(Icons.info_outline, color: Colors.deepPurple),
//           SizedBox(width: 10),
//           Text('$title: ',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           Expanded(
//             child: Text(value, style: TextStyle(fontSize: 16)),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart'; // Adjust import path
import '../models/profile_model.dart'; // Adjust import path

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  bool _isEditing = false;
  String? _userRole;
  Profile? _profile;
  String? _errorMessage;

  // Text Editing Controllers - Initialize later if needed
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "User not logged in.";
      });
      // Optional: Navigate to login screen
      return;
    }

    try {
      final role = await _firestoreService.getUserRole(currentUser.uid);
      final profileData = await _firestoreService.getProfile(currentUser.uid);

      setState(() {
        _userRole = role;
        _profile = profileData; // Will be null if no profile exists yet
        _isLoading = false;
      });

      // If profile exists and we enter edit mode later, controllers will be initialized then
      if (profileData == null && role == 'student') {
        // Handle new student onboarding - prompt to create profile
        print("New student detected - profile needs creation.");
        // Maybe automatically switch to edit mode?
        // _isEditing = true;
      } else if (profileData == null && role == 'alumni') {
        // Should ideally not happen if transition logic is correct, but handle it
        print("Alumnus without profile data found.");
        _errorMessage = "Alumni profile data missing.";
      }

    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load profile data.";
      });
    }
  }

  // Initialize controllers when entering edit mode
  void _initializeControllers() {
    _controllers.clear(); // Clear previous controllers

    // --- Common Fields ---
    _controllers['name'] = TextEditingController(text: _profile?.name ?? '');
    _controllers['department'] = TextEditingController(text: _profile?.department ?? '');
    _controllers['batchYear'] = TextEditingController(text: _profile?.batchYear?.toString() ?? '');
    _controllers['graduationYear'] = TextEditingController(text: _profile?.graduationYear?.toString() ?? '');
    _controllers['resumeUrl'] = TextEditingController(text: _profile?.resumeUrl ?? '');
    // For complex fields like lists/maps, handle differently (e.g., specific widgets)
    _controllers['skills'] = TextEditingController(text: _profile?.skills?.join(', ') ?? ''); // Simple comma separated for now
    _controllers['phone'] = TextEditingController(text: _profile?.contactInfo?['phone'] ?? '');
    _controllers['linkedin'] = TextEditingController(text: _profile?.contactInfo?['linkedin'] ?? '');
    // Add controllers for other fields (academic, projects, experience) as needed


    // --- Alumni Specific Fields ---
    if (_userRole == 'alumni') {
      _controllers['currentCompany'] = TextEditingController(text: _profile?.currentCompany ?? '');
      _controllers['currentJobTitle'] = TextEditingController(text: _profile?.currentJobTitle ?? '');
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        // Initialize controllers with current data when starting edit
        _initializeControllers();
      } else {
        // Clear controllers when exiting edit mode (optional)
        // _controllers.forEach((key, controller) => controller.dispose());
        // _controllers.clear();
      }
    });
  }

  Future<void> _saveProfile() async {
    print("Current User UID before save: ${_auth.currentUser?.uid}");
    if (_auth.currentUser == null) return; // Should not happen if logged in

    setState(() {
      _isLoading = true; // Show loading indicator during save
      _errorMessage = null;
    });

    // --- Construct Profile object from controllers ---
    // Basic example, needs refinement for lists/maps/numbers
    Map<String, dynamic> updatedData = {
      'name': _controllers['name']?.text,
      'department': _controllers['department']?.text,
      'batchYear': int.tryParse(_controllers['batchYear']?.text ?? ''),
      'graduationYear': int.tryParse(_controllers['graduationYear']?.text ?? ''),
      'resumeUrl': _controllers['resumeUrl']?.text,
      'skills': _controllers['skills']?.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      'contactInfo': {
        'phone': _controllers['phone']?.text,
        'linkedin': _controllers['linkedin']?.text,
      },
      // Add logic to parse other fields (academic, projects, experience)
    };

    if (_userRole == 'alumni') {
      updatedData['currentCompany'] = _controllers['currentCompany']?.text;
      updatedData['currentJobTitle'] = _controllers['currentJobTitle']?.text;
    }

    // Create a temporary profile object to use the toJson method
    // Note: We pass the UID but it won't be included in the JSON map itself
    Profile updatedProfile = Profile.fromJson(_auth.currentUser!.uid, updatedData);


    try {
      await _firestoreService.createOrUpdateProfile(
        _auth.currentUser!.uid,
        updatedProfile, // Pass the updated profile data
      );

      // Reload data after saving
      await _loadUserData(); // Fetch fresh data

      setState(() {
        _isEditing = false; // Exit edit mode on success
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      });

    } catch (e) {
      print("Error saving profile: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to save profile.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: ${e.toString()}')),
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Profile' : 'My Profile',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        actions: [
          // Show Save button only in edit mode
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: _saveProfile,
              tooltip: 'Save',
            ),
          // Toggle Edit/View Button (excluding loading state)
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit, color: Colors.white),
              onPressed: _toggleEditMode,
              tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }

    if (_auth.currentUser == null) {
      return Center(child: Text('Please log in.')); // Should be handled by redirect earlier
    }

    // Handle case where user is logged in but role/profile somehow failed to load
    // (though _errorMessage should catch most Firestore errors)
    if (_userRole == null) {
      return Center(child: Text('Could not determine user role.'));
    }


    // --- New Student Onboarding ---
    if (_profile == null && _userRole == 'student' && !_isEditing) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome!", style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 15),
              Text("Please create your profile to get started.", textAlign: TextAlign.center),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text("Create Profile"),
                onPressed: _toggleEditMode, // Switches to edit mode
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              )
            ],
          ),
        ),
      );
    }

    // --- Profile View / Edit ---
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center( // Keep the avatar
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.deepPurple.shade100,
              // TODO: Load actual profile picture from _profile?.profilePictureUrl
              backgroundImage: _profile?.profilePictureUrl != null
                  ? NetworkImage(_profile!.profilePictureUrl!)
                  : null, // Handle null case
              child: _profile?.profilePictureUrl == null
                  ? Icon(Icons.person, size: 60, color: Colors.deepPurple.shade700)
                  : null, // Show icon if no image
            ),
          ),
          SizedBox(height: 20),

          // Conditionally display View or Edit Form
          if (_isEditing)
            _buildEditForm()
          else
            _buildViewDetails(),


          // Keep Settings/Logout outside the edit form
          if (!_isEditing) ...[
            SizedBox(height: 20),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.deepPurple),
              title: Text('Settings'),
              onTap: () {
                // TODO: Implement Settings Navigation
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.deepPurple),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                // Optional: Navigate to login screen after logout
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false); // Example navigation
              },
            ),
          ]
        ],
      ),
    );
  }

  // --- VIEW MODE WIDGET ---
  Widget _buildViewDetails() {
    if (_profile == null) {
      // This case is mostly handled by the onboarding check, but as a fallback
      return Center(child: Text("Profile not available."));
    }
    // Display data from the _profile object
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildProfileDetailView('Name', _profile?.name ?? 'N/A'),
        buildProfileDetailView('Email', _auth.currentUser?.email ?? 'N/A'), // Get email from auth
        buildProfileDetailView('Role', _userRole ?? 'N/A'),
        buildProfileDetailView('Department', _profile?.department ?? 'N/A'),
        buildProfileDetailView('Graduation Year', _profile?.graduationYear?.toString() ?? 'N/A'),
        buildProfileDetailView('Skills', _profile?.skills?.join(', ') ?? 'N/A'),
        buildProfileDetailView('Resume', _profile?.resumeUrl ?? 'N/A'), // TODO: Make this a tappable link
        buildProfileDetailView('Phone', _profile?.contactInfo?['phone'] ?? 'N/A'),
        buildProfileDetailView('LinkedIn', _profile?.contactInfo?['linkedin'] ?? 'N/A'), // TODO: Tappable link

        // --- Display Alumni Specific Fields ---
        if (_userRole == 'alumni') ...[
          Divider(height: 30),
          Text("Alumni Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          buildProfileDetailView('Current Company', _profile?.currentCompany ?? 'N/A'),
          buildProfileDetailView('Current Job Title', _profile?.currentJobTitle ?? 'N/A'),
          buildProfileDetailView('Alumni Since', _profile?.alumniSince?.toDate().toString().substring(0,10) ?? 'N/A'), // Format date
        ]
        // TODO: Add sections for Academic Info, Projects, Experience using data from _profile
      ],
    );
  }

  // Helper for View Mode display
  Widget buildProfileDetailView(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(width: 5),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }


  // --- EDIT MODE WIDGET ---
  Widget _buildEditForm() {
    // Use the _controllers map to link TextFields
    // This needs significant expansion for a good UX
    return Column(
      children: [
        _buildTextField('name', 'Full Name'),
        _buildTextField('department', 'Department'),
        _buildTextField('batchYear', 'Batch Year (e.g., 2021)', keyboardType: TextInputType.number),
        _buildTextField('graduationYear', 'Expected Graduation Year (e.g., 2025)', keyboardType: TextInputType.number, enabled: _userRole == 'student'), // Disable for alumni
        _buildTextField('skills', 'Skills (comma-separated)'),
        _buildTextField('resumeUrl', 'Resume URL'),
        _buildTextField('phone', 'Phone Number', keyboardType: TextInputType.phone),
        _buildTextField('linkedin', 'LinkedIn Profile URL'),

        // TODO: Add form fields for Academic Info, Projects, Experience (might need dedicated widgets)

        if (_userRole == 'alumni') ...[
          Divider(height: 30),
          Text("Alumni Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          _buildTextField('currentCompany', 'Current Company'),
          _buildTextField('currentJobTitle', 'Current Job Title'),
        ]
      ],
    );
  }

  // Helper for Edit Mode TextFields
  Widget _buildTextField(String key, String label, {TextInputType keyboardType = TextInputType.text, bool enabled = true}) {
    // Ensure controller exists for the key
    if (_controllers[key] == null) {
      _controllers[key] = TextEditingController();
      print("Warning: Controller for '$key' was null, initialized."); // Should be init'd in _initializeControllers
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: keyboardType,
        enabled: enabled, // Control if field is editable
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: !enabled, // Indicate disabled fields
          fillColor: !enabled ? Colors.grey[200] : null,
        ),
        validator: (value) { // Add basic validation if needed
          if (value == null || value.isEmpty) {
            // Make specific fields required if necessary
            // return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }


} // End of _ProfileScreenState