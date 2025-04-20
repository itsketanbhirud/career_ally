import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import 'skills_input_field.dart';
import 'editable_list_section.dart';
import 'project_form_dialog.dart';
import 'experience_form_dialog.dart';

class AlumniProfileForm extends StatefulWidget {
  final Profile initialProfile; // Alumni profile assumed to exist
  final Function(List<String>) onSkillsChanged;
  final Function(List<Map<String, String>>) onProjectsChanged;
  final Function(List<Map<String, String>>) onExperienceChanged;
  // Receive initial temporary state from parent
  final List<String> initialSkills;
  final List<Map<String, String>> initialProjects;
  final List<Map<String, String>> initialExperience;
  // Add the onSaveField callback
  final Function(String key, dynamic value) onSaveField; // Callback to update parent's map

  const AlumniProfileForm({
    Key? key,
    required this.initialProfile,
    required this.onSkillsChanged,
    required this.onProjectsChanged,
    required this.onExperienceChanged,
    required this.initialSkills,
    required this.initialProjects,
    required this.initialExperience,
    required this.onSaveField, // Receive the callback
  }) : super(key: key);

  @override
  _AlumniProfileFormState createState() => _AlumniProfileFormState();
}

class _AlumniProfileFormState extends State<AlumniProfileForm> {
  // Controllers for fields editable by Alumni
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _resumeUrlController = TextEditingController();
  final _phoneController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _currentCompanyController = TextEditingController();
  final _currentJobTitleController = TextEditingController();

  // Local state lists for complex fields
  late List<String> _skills;
  late List<Map<String, String>> _projects;
  late List<Map<String, String>> _experience;


  @override
  void initState() {
    super.initState();
    // Initialize controllers with data from the initial profile
    _nameController.text = widget.initialProfile.name ?? '';
    _departmentController.text = widget.initialProfile.department ?? '';
    _resumeUrlController.text = widget.initialProfile.resumeUrl ?? '';
    _phoneController.text = widget.initialProfile.contactInfo['phone'] ?? '';
    _linkedinController.text = widget.initialProfile.contactInfo['linkedin'] ?? '';
    _currentCompanyController.text = widget.initialProfile.currentCompany ?? '';
    _currentJobTitleController.text = widget.initialProfile.currentJobTitle ?? '';

    // Initialize local lists from initial temp state passed by parent
    _skills = List<String>.from(widget.initialSkills);
    _projects = List<Map<String, String>>.from(widget.initialProjects.map((p) => Map<String,String>.from(p)));
    _experience = List<Map<String, String>>.from(widget.initialExperience.map((e) => Map<String,String>.from(e)));
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _departmentController.dispose();
    _resumeUrlController.dispose();
    _phoneController.dispose();
    _linkedinController.dispose();
    _currentCompanyController.dispose();
    _currentJobTitleController.dispose();
    super.dispose();
  }

  // --- Methods to handle changes in complex lists ---
  // (These remain the same as in StudentProfileForm, updating local state and notifying parent)
  void _handleSkillsChanged(List<String> newSkills) {
    if (!mounted) return;
    setState(() { _skills = newSkills; });
    widget.onSkillsChanged(_skills);
  }
  void _addOrEditProject({Map<String, String>? project, int? index}) async {
    final result = await showDialog<Map<String, String>>(context: context, builder: (_) => ProjectFormDialog(project: project));
    if (result != null && mounted) {
      setState(() { if (index != null) { _projects[index] = result;} else { _projects.add(result);}});
      widget.onProjectsChanged(_projects);
    }
  }
  void _deleteProject(int index) {
    if (!mounted) return;
    setState(() { _projects.removeAt(index); });
    widget.onProjectsChanged(_projects);
  }
  void _addOrEditExperience({Map<String, String>? exp, int? index}) async {
    final result = await showDialog<Map<String, String>>(context: context, builder: (_) => ExperienceFormDialog(experience: exp));
    if (result != null && mounted) {
      setState(() { if (index != null) { _experience[index] = result; } else { _experience.add(result); }});
      widget.onExperienceChanged(_experience);
    }
  }
  void _deleteExperience(int index) {
    if (!mounted) return;
    setState(() { _experience.removeAt(index); });
    widget.onExperienceChanged(_experience);
  }


  @override
  Widget build(BuildContext context) {
    // Parent (_ProfileScreenState) wraps this in a Form widget
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Basic Information"),
        // Pass field key 'name' to onSaved callback
        _buildTextField(_nameController, 'name', 'Full Name', isRequired: true),
        // Pass field key 'department'
        _buildTextField(_departmentController, 'department', 'Department'),
        // Display Batch/Graduation Year but disable editing (no onSaved needed)
        _buildDisplayField("Batch Year", widget.initialProfile.batchYear?.toString() ?? 'N/A'),
        _buildDisplayField("Graduation Year", widget.initialProfile.graduationYear?.toString() ?? 'N/A'),


        _buildSectionHeader("Alumni Information"),
        // Pass field keys 'currentCompany', 'currentJobTitle'
        _buildTextField(_currentCompanyController, 'currentCompany', 'Current Company'),
        _buildTextField(_currentJobTitleController, 'currentJobTitle', 'Current Job Title'),

        _buildSectionHeader("Skills"),
        // Skills handled via callback, no onSaved needed here
        SkillsInputField(initialSkills: _skills, onChanged: _handleSkillsChanged),

        _buildSectionHeader("Contact & Resume"),
        // Pass field keys 'resumeUrl', 'phone', 'linkedin'
        _buildTextField(_resumeUrlController, 'resumeUrl', 'Resume URL (Public Link)', keyboardType: TextInputType.url),
        _buildTextField(_phoneController, 'phone', 'Phone Number', keyboardType: TextInputType.phone),
        _buildTextField(_linkedinController, 'linkedin', 'LinkedIn Profile URL', keyboardType: TextInputType.url),

        _buildSectionHeader("Academic Info"),
        // Display academic info but disable editing (no onSaved needed)
        _buildDisplayField('CGPA', widget.initialProfile.academicInfo['cgpa']?.toString() ?? 'N/A'),
        _buildDisplayField('10th %', widget.initialProfile.academicInfo['tenth']?.toString() ?? 'N/A'),
        _buildDisplayField('12th %', widget.initialProfile.academicInfo['twelfth']?.toString() ?? 'N/A'),


        _buildSectionHeader("Projects (from College)"), // Clarify these are historical
        // Allow viewing/editing/deleting historical projects if needed
        EditableListSection<Map<String, String>>(
          items: _projects, titleKey: 'title', subtitleKey: 'description',
          onAdd: () => _addOrEditProject(),
          onEdit: (index) => _addOrEditProject(project: _projects[index], index: index),
          onDelete: _deleteProject,
        ),

        _buildSectionHeader("Experience (Includes Internships & Jobs)"),
        // Allow viewing/editing/deleting historical and adding new experience
        EditableListSection<Map<String, String>>(
          items: _experience, titleKey: 'company', subtitleKey: 'role',
          onAdd: () => _addOrEditExperience(),
          onEdit: (index) => _addOrEditExperience(exp: _experience[index], index: index),
          onDelete: _deleteExperience,
          addItemLabel: "Add Experience",
        ),
      ],
    );
  }

  // --- Helper Widgets ---

  // Helper for building TextFormFields - Includes onSaved callback
  Widget _buildTextField(TextEditingController controller, String dataKey, String label, {TextInputType keyboardType = TextInputType.text, bool enabled = true, bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: !enabled,
          fillColor: !enabled ? Colors.grey[200] : null,
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) { return 'Please enter $label';}
          // Add specific alumni validations if needed
          if ((dataKey == 'resumeUrl' || dataKey == 'linkedin') && value != null && value.isNotEmpty) {
            final uri = Uri.tryParse(value);
            if (uri == null || !uri.hasAbsolutePath || !uri.scheme.startsWith('http')) {
              return 'Please enter a valid, absolute URL (e.g., https://...)';
            }
          }
          return null; // Valid
        },
        // --- Call the onSaveField callback passed from the parent ---
        onSaved: (value) {
          // Only save editable fields. No parsing needed for these alumni fields (all strings)
          // But trim whitespace.
          widget.onSaveField(dataKey, value?.trim());
        },
      ),
    );
  }

  // Helper for displaying non-editable fields
  Widget _buildDisplayField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator( // Using InputDecorator to mimic look of TextFormField
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true, fillColor: Colors.grey[200],
        ),
        child: Padding( // Add padding inside decorator
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(value, style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  // Helper for section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
    );
  }
}