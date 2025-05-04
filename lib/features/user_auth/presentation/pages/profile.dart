// This is the code you provided, confirmed to have the onSaved implementation.
// No further changes needed *here* for the data collection fix.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/profile_model.dart';
import '../widgets/student_profile_form.dart'; // Ensure this uses onSaveField
import '../widgets/alumni_profile_form.dart';   // Ensure this uses onSaveField

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // GlobalKey to manage the Form state and trigger onSaved callbacks
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isEditing = false;
  String? _userRole;
  Profile? _profile; // Holds the currently loaded profile
  String? _errorMessage;

  // --- State for form data populated by onSaved ---
  final Map<String, dynamic> _formData = {};

  // --- Temporary state for complex list fields updated via direct callbacks ---
  List<String> _tempSkills = [];
  List<Map<String, String>> _tempProjects = [];
  List<Map<String, String>> _tempExperience = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      if (!mounted) return;
      setState(() { _isLoading = false; _errorMessage = "User not logged in."; });
      return;
    }
    try {
      final role = await _firestoreService.getUserRole(currentUser.uid);
      final profileData = await _firestoreService.getProfile(currentUser.uid);
      if (!mounted) return;
      setState(() {
        _userRole = role;
        _profile = profileData;
        _initializeTemporaryEditState(); // Initialize temps for lists
        _isLoading = false;
      });
      if (profileData == null && role == 'student') {
        print("New student detected - profile needs creation.");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _toggleEditMode(startEditing: true);
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      if (!mounted) return;
      setState(() { _isLoading = false; _errorMessage = "Failed to load profile data."; });
    }
  }

  // Initializes the temporary state for complex lists when entering edit mode
  void _initializeTemporaryEditState() {
    _tempSkills = List<String>.from(_profile?.skills ?? []);
    _tempProjects = List<Map<String, String>>.from(_profile?.projects ?? []);
    _tempExperience = List<Map<String, String>>.from(_profile?.experience ?? []);
    // _formData map is cleared before each save, initialization not strictly needed here
  }

  void _toggleEditMode({bool startEditing = false}) {
    if (!mounted) return;
    setState(() {
      _isEditing = startEditing ? true : !_isEditing;
      if (_isEditing) {
        _initializeTemporaryEditState(); // Ensure temp lists are reset from profile
      } else {
        _formData.clear(); // Clear collected form data when cancelling edit
      }
    });
  }

  // --- Callback Functions for complex lists from Form Widgets ---
  void _updateSkills(List<String> newSkills) {
    if (!mounted) return;
    setState(() { _tempSkills = newSkills; });
  }
  void _updateProjects(List<Map<String, String>> newProjects) {
    if (!mounted) return;
    setState(() { _tempProjects = newProjects; });
  }
  void _updateExperience(List<Map<String, String>> newExperience) {
    if (!mounted) return;
    setState(() { _tempExperience = newExperience; });
  }

  // --- Callback for basic fields from Form Widgets' onSaved ---
  void _updateFormData(String key, dynamic value) {
    // This map is populated when _formKey.currentState!.save() is called
    _formData[key] = value;
    // No setState needed here as it's just collecting data before the final save setState
  }

  Future<void> _saveProfile() async {
    // 1. Validate the form using the GlobalKey
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fix the errors in the form.')),
      );
      return;
    }

    // 2. Clear previous form data and trigger onSaved for all FormFields
    _formData.clear(); // Ensure we start fresh for this save
    _formKey.currentState!.save(); // This populates _formData via _updateFormData callback

    if (_auth.currentUser == null) return;
    if (!mounted) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    // 3. Construct the Profile object using _formData and temporary state
    Profile updatedProfile = Profile(
      uid: _auth.currentUser!.uid,

      // --- Get data from the _formData map populated by onSaved ---
      name: _formData['name'] as String?,
      department: _formData['department'] as String?,
      batchYear: _formData['batchYear'] as int?, // Parsed in child form's onSaved
      graduationYear: _formData['graduationYear'] as int?, // Parsed in child form's onSaved
      resumeUrl: _formData['resumeUrl'] as String?,
      contactInfo: { // Reconstruct map
        'phone': _formData['phone'] as String? ?? '',
        'linkedin': _formData['linkedin'] as String? ?? '',
      },
      academicInfo: { // Reconstruct map
        'cgpa': _formData['cgpa'] as double?, // Parsed in child form's onSaved
        'tenth': _formData['tenth'] as double?, // Parsed in child form's onSaved
        'twelfth': _formData['twelfth'] as double?, // Parsed in child form's onSaved
      },
      profilePictureUrl: _profile?.profilePictureUrl, // TODO: Needs image handling

      // --- Use temporary state updated by direct callbacks ---
      skills: _tempSkills,
      projects: _tempProjects,
      experience: _tempExperience,

      // --- Alumni Specific Fields (get from _formData if Alumni form) ---
      currentCompany: _userRole == 'alumni' ? (_formData['currentCompany'] as String?) : null,
      currentJobTitle: _userRole == 'alumni' ? (_formData['currentJobTitle'] as String?) : null,

      // --- Fields not typically edited ---
      alumniSince: _profile?.alumniSince,
      email: _profile?.email, // Keep original email associated with profile model if needed
    );

    // !!!!! CRITICAL DEBUG STEP !!!!!
    print("--- Saving Profile Data ---");
    print("User ID: ${updatedProfile.uid}");
    print("Data collected via onSaved (_formData): $_formData"); // Log the map populated by onSaved
    print("Data from _tempSkills: $_tempSkills");
    print("Data from _tempProjects: $_tempProjects");
    print("Data from _tempExperience: $_tempExperience");
    print("Final Profile Object to Save (JSON): ${updatedProfile.toJson()}"); // Log the final object
    print("---------------------------");
    // !!!!! END OF DEBUG STEP !!!!!


    try {
      await _firestoreService.createOrUpdateProfile(
        _auth.currentUser!.uid,
        updatedProfile,
      );
      if (!mounted) return;
      // Update the local state *after* successful save
      setState(() {
        _profile = updatedProfile; // Reflect changes immediately in view mode
        _isEditing = false;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      print("Error saving profile: $e");
      if (!mounted) return;
      setState(() { _isLoading = false; _errorMessage = "Failed to save profile."; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: ${e.toString()}')),
      );
    } finally {
      // Ensure loading stops if still mounted and loading is true
      if (mounted && _isLoading) {
        setState(() { _isLoading = false; });
      }
    }
  }


  // --- Build Methods ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'My Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isEditing && !_isLoading)
            IconButton(icon: Icon(Icons.save, color: Colors.white), onPressed: _saveProfile, tooltip: 'Save'),
          if (!_isLoading)
            IconButton(icon: Icon(_isEditing ? Icons.close : Icons.edit, color: Colors.white), onPressed: () => _toggleEditMode(), tooltip: _isEditing ? 'Cancel' : 'Edit Profile'),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $_errorMessage', style: TextStyle(color: Colors.red))));
    if (_auth.currentUser == null) return Center(child: Text('Please log in.'));
    if (_userRole == null) return Center(child: Text('Could not determine user role.'));

    return RefreshIndicator(
      onRefresh: _loadUserData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _buildAvatar()),
            SizedBox(height: 20),
            _isEditing
                ? _buildEditFormContainer() // Contains the Form widget now
                : _buildViewDetails(),
            if (!_isEditing) _buildSettingsLogout(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
        child: Stack(
          children: [
            CircleAvatar( /* ... Avatar display logic ... */
              radius: 60,
              backgroundColor: Colors.deepPurple.shade100,
              backgroundImage: _profile?.profilePictureUrl != null
                  ? NetworkImage(_profile!.profilePictureUrl!)
                  : null,
              child: _profile?.profilePictureUrl == null
                  ? Icon(Icons.person, size: 60, color: Colors.deepPurple.shade700)
                  : null,
            ),
            if (_isEditing)
              Positioned( /* ... Camera Icon Logic ... */
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.deepPurple,
                  child: IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: () {
                      // TODO: Implement Image Picking Logic
                      print("Pick Image pressed");
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image picking not implemented yet.')));
                    },
                  ),
                ),
              ),
          ],
        )
    );
  }


  Widget _buildEditFormContainer() {
    Widget formWidget;
    // Clear previous form data when rebuilding the form container
    _formData.clear();

    if (_userRole == 'student') {
      formWidget = StudentProfileForm(
        initialProfile: _profile,
        onSkillsChanged: _updateSkills,
        onProjectsChanged: _updateProjects,
        onExperienceChanged: _updateExperience,
        initialSkills: _tempSkills,
        initialProjects: _tempProjects,
        initialExperience: _tempExperience,
        onSaveField: _updateFormData, // Pass the callback to populate _formData
      );
    } else if (_userRole == 'alumni') {
      formWidget = AlumniProfileForm(
        initialProfile: _profile!,
        onSkillsChanged: _updateSkills,
        onProjectsChanged: _updateProjects,
        onExperienceChanged: _updateExperience,
        initialSkills: _tempSkills,
        initialProjects: _tempProjects,
        initialExperience: _tempExperience,
        onSaveField: _updateFormData, // Pass the callback to populate _formData
      );
    } else {
      formWidget = Center(child: Text("Editing not available for role: $_userRole"));
    }

    // Wrap the specific form widget with the Form and its key
    return Form(
      key: _formKey,
      child: formWidget,
    );
  }

  // --- _buildViewDetails and its helpers ---
  Widget _buildViewDetails() {
    if (_profile == null && _userRole == 'student') {
      return _buildOnboardingPrompt();
    }
    if (_profile == null) {
      return Center(child: Text("Profile data not available."));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildViewSection("Basic Information", [
          _buildDetailItem('Name', _profile?.name),
          _buildDetailItem('Email', _auth.currentUser?.email),
          _buildDetailItem('Role', _userRole),
          _buildDetailItem('Department', _profile?.department),
          if (_userRole != 'alumni') _buildDetailItem('Expected Graduation', _profile?.graduationYear?.toString()),
        ]),
        _buildViewSection("Skills", [
          _profile?.skills.isEmpty ?? true
              ? Text("No skills added.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
              : Wrap(
            spacing: 8.0, runSpacing: 4.0,
            children: _profile!.skills.map((skill) => Chip(label: Text(skill))).toList(),
          )
        ]),
        _buildViewSection("Contact & Resume", [
          _buildDetailItem('Resume URL', _profile?.resumeUrl), // TODO: Tappable
          _buildDetailItem('Phone', _profile?.contactInfo['phone']),
          _buildDetailItem('LinkedIn', _profile?.contactInfo['linkedin']), // TODO: Tappable
        ]),
        _buildViewSection("Academic Info", [
          _buildDetailItem('CGPA', _profile?.academicInfo['cgpa']?.toString()),
          _buildDetailItem('10th %', _profile?.academicInfo['tenth']?.toString()),
          _buildDetailItem('12th %', _profile?.academicInfo['twelfth']?.toString()),
        ]),
        _buildViewSection("Projects", _buildProjectExperienceList(_profile!.projects)),
        _buildViewSection("Experience", _buildProjectExperienceList(_profile!.experience)),
        if (_userRole == 'alumni')
          _buildViewSection("Alumni Information", [
            _buildDetailItem('Current Company', _profile?.currentCompany),
            _buildDetailItem('Current Job Title', _profile?.currentJobTitle),
            _buildDetailItem('Alumni Since', _profile?.alumniSince?.toDate().toString().substring(0, 10)),
          ]),
      ],
    );
  }

  Widget _buildViewSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text( title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),),
          SizedBox(height: 8),
          if (children.isEmpty || children.every((w) => w is SizedBox && w.height == 0))
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("No information added.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
            )
          else
            ...children,
          Divider(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    if (value == null || value.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(width: 5),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  List<Widget> _buildProjectExperienceList(List<Map<String, String>> items) {
    if (items.isEmpty) return [SizedBox.shrink()];
    return items.map((item) {
      String title = item['title'] ?? item['company'] ?? 'N/A';
      String description = item['description'] ?? item['role'] ?? 'No description';
      return ListTile(
        dense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
      );
    }).toList();
  }

  Widget _buildOnboardingPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Added padding here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome!", style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 15),
            Text("Create your profile to showcase your skills!", textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text("Create Profile"),
              onPressed: () => _toggleEditMode(startEditing: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsLogout() {
    return Column(
        children: [
          SizedBox(height: 20),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.deepPurple),
            title: Text('Settings'),
            onTap: () { /* TODO: Implement Settings */ },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.deepPurple),
            title: Text('Logout'),
            onTap: () async {
              // Optional: Add confirmation dialog before logout
              await _auth.signOut();
              // Ensure context is still valid if async gap happens
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ]
    );
  }

} // End of _ProfileScreenState