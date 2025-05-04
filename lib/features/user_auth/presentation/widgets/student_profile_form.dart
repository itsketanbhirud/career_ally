import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import 'skills_input_field.dart'; // Import custom skills widget
import 'editable_list_section.dart'; // Import list section widget
import 'project_form_dialog.dart'; // Import project dialog
import 'experience_form_dialog.dart'; // Import experience dialog

class StudentProfileForm extends StatefulWidget {
  final Profile? initialProfile; // Can be null for new students
  final Function(List<String>) onSkillsChanged;
  final Function(List<Map<String, String>>) onProjectsChanged;
  final Function(List<Map<String, String>>) onExperienceChanged;
  // Receive initial temporary state from parent
  final List<String> initialSkills;
  final List<Map<String, String>> initialProjects;
  final List<Map<String, String>> initialExperience;
  // Add the onSaveField callback
  final Function(String key, dynamic value) onSaveField; // Callback to update parent's map

  const StudentProfileForm({
    super.key,
    required this.initialProfile,
    required this.onSkillsChanged,
    required this.onProjectsChanged,
    required this.onExperienceChanged,
    required this.initialSkills,
    required this.initialProjects,
    required this.initialExperience,
    required this.onSaveField, // Receive the callback
  });

  @override
  _StudentProfileFormState createState() => _StudentProfileFormState();
}

class _StudentProfileFormState extends State<StudentProfileForm> {
  // Controllers for basic fields managed locally within this form
  // These hold the current text being edited.
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _batchYearController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _resumeUrlController = TextEditingController();
  final _phoneController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _cgpaController = TextEditingController();
  final _tenthController = TextEditingController();
  final _twelfthController = TextEditingController();

  // Local state lists for complex fields, initialized from parent's temp state
  late List<String> _skills;
  late List<Map<String, String>> _projects;
  late List<Map<String, String>> _experience;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with data from the initial profile
    _nameController.text = widget.initialProfile?.name ?? '';
    _departmentController.text = widget.initialProfile?.department ?? '';
    _batchYearController.text = widget.initialProfile?.batchYear?.toString() ?? '';
    _graduationYearController.text = widget.initialProfile?.graduationYear?.toString() ?? '';
    _resumeUrlController.text = widget.initialProfile?.resumeUrl ?? '';
    _phoneController.text = widget.initialProfile?.contactInfo['phone'] ?? '';
    _linkedinController.text = widget.initialProfile?.contactInfo['linkedin'] ?? '';
    _cgpaController.text = widget.initialProfile?.academicInfo['cgpa']?.toString() ?? '';
    _tenthController.text = widget.initialProfile?.academicInfo['tenth']?.toString() ?? '';
    _twelfthController.text = widget.initialProfile?.academicInfo['twelfth']?.toString() ?? '';

    // Initialize local lists from initial temp state passed by parent
    // This ensures edits to lists are reflected immediately via setState
    _skills = List<String>.from(widget.initialSkills);
    _projects = List<Map<String, String>>.from(widget.initialProjects.map((p) => Map<String,String>.from(p)));
    _experience = List<Map<String, String>>.from(widget.initialExperience.map((e) => Map<String,String>.from(e)));
  }

  @override
  void dispose() {
    // Dispose all controllers when the widget is removed
    _nameController.dispose();
    _departmentController.dispose();
    _batchYearController.dispose();
    _graduationYearController.dispose();
    _resumeUrlController.dispose();
    _phoneController.dispose();
    _linkedinController.dispose();
    _cgpaController.dispose();
    _tenthController.dispose();
    _twelfthController.dispose();
    super.dispose();
  }

  // --- Methods to handle changes in complex lists ---
  // These update local state AND notify the parent (_ProfileScreenState)
  // so the parent's temporary state (_tempSkills, etc.) is kept in sync.
  void _handleSkillsChanged(List<String> newSkills) {
    if (!mounted) return;
    setState(() { _skills = newSkills; });
    widget.onSkillsChanged(_skills); // Notify parent
  }
  void _addOrEditProject({Map<String, String>? project, int? index}) async {
    final result = await showDialog<Map<String, String>>(context: context, builder: (_) => ProjectFormDialog(project: project));
    if (result != null && mounted) {
      setState(() { if (index != null) { _projects[index] = result;} else { _projects.add(result);}});
      widget.onProjectsChanged(_projects); // Notify parent
    }
  }
  void _deleteProject(int index) {
    if (!mounted) return;
    setState(() { _projects.removeAt(index); });
    widget.onProjectsChanged(_projects); // Notify parent
  }
  void _addOrEditExperience({Map<String, String>? exp, int? index}) async {
    final result = await showDialog<Map<String, String>>(context: context, builder: (_) => ExperienceFormDialog(experience: exp));
    if (result != null && mounted) {
      setState(() { if (index != null) { _experience[index] = result; } else { _experience.add(result); }});
      widget.onExperienceChanged(_experience); // Notify parent
    }
  }
  void _deleteExperience(int index) {
    if (!mounted) return;
    setState(() { _experience.removeAt(index); });
    widget.onExperienceChanged(_experience); // Notify parent
  }


  @override
  Widget build(BuildContext context) {
    // The parent (_ProfileScreenState) wraps this in a Form widget
    // This widget just returns the Column of fields
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Basic Information"),
        // Pass the key ('name', 'department', etc.) to map the data in the parent
        _buildTextField(_nameController, 'name', 'Full Name', isRequired: true),
        _buildTextField(_departmentController, 'department', 'Department'),
        _buildTextField(_batchYearController, 'batchYear', 'Batch Year (e.g., 2021)', keyboardType: TextInputType.number),
        _buildTextField(_graduationYearController, 'graduationYear', 'Expected Graduation Year (e.g., 2025)', keyboardType: TextInputType.number, isRequired: true),

        _buildSectionHeader("Skills"),
        SkillsInputField(
          initialSkills: _skills, // Use local state for display/interaction
          onChanged: _handleSkillsChanged, // Updates local & parent state
        ),

        _buildSectionHeader("Contact & Resume"),
        _buildTextField(_resumeUrlController, 'resumeUrl', 'Resume URL (Public Link)', keyboardType: TextInputType.url),
        _buildTextField(_phoneController, 'phone', 'Phone Number', keyboardType: TextInputType.phone),
        _buildTextField(_linkedinController, 'linkedin', 'LinkedIn Profile URL', keyboardType: TextInputType.url),

        _buildSectionHeader("Academic Info"),
        _buildTextField(_cgpaController, 'cgpa', 'CGPA', keyboardType: TextInputType.numberWithOptions(decimal: true)),
        _buildTextField(_tenthController, 'tenth', '10th % or Grade', keyboardType: TextInputType.numberWithOptions(decimal: true)),
        _buildTextField(_twelfthController, 'twelfth', '12th % or Grade', keyboardType: TextInputType.numberWithOptions(decimal: true)),

        _buildSectionHeader("Projects"),
        EditableListSection<Map<String, String>>(
          items: _projects, // Use local state for display
          titleKey: 'title',
          subtitleKey: 'description',
          onAdd: () => _addOrEditProject(),
          onEdit: (index) => _addOrEditProject(project: _projects[index], index: index),
          onDelete: _deleteProject,
          addItemLabel: 'Add Project',
          emptyListText: 'No projects added yet.',
        ),

        _buildSectionHeader("Experience"),
        EditableListSection<Map<String, String>>(
          items: _experience, // Use local state for display
          titleKey: 'company',
          subtitleKey: 'role',
          onAdd: () => _addOrEditExperience(),
          onEdit: (index) => _addOrEditExperience(exp: _experience[index], index: index),
          onDelete: _deleteExperience,
          addItemLabel: 'Add Experience',
          emptyListText: 'No experience added yet.',
        ),

      ],
    );
  }

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
          // Numeric Check
          if ((dataKey == 'batchYear' || dataKey == 'graduationYear' || dataKey == 'cgpa' || dataKey == 'tenth' || dataKey == 'twelfth') && value != null && value.isNotEmpty) {
            if (double.tryParse(value) == null) return 'Please enter a valid number';
          }
          // URL Check
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
          dynamic parsedValue = value?.trim(); // Trim whitespace
          // Attempt to parse numbers for relevant fields before calling callback
          if (dataKey == 'batchYear' || dataKey == 'graduationYear') {
            parsedValue = int.tryParse(value ?? '');
          } else if (dataKey == 'cgpa' || dataKey == 'tenth' || dataKey == 'twelfth') {
            parsedValue = double.tryParse(value ?? '');
          }
          // Call the parent's function to update the central data map
          widget.onSaveField(dataKey, parsedValue);
        },
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