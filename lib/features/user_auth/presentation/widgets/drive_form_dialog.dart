// lib/widgets/drive_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:intl/intl.dart'; // For date formatting
import '../models/upcoming_drive_model.dart';
import 'skills_input_field.dart'; // Reuse skills input

class DriveFormDialog extends StatefulWidget {
  final UpcomingDrive? drive; // Pass existing data for editing

  const DriveFormDialog({Key? key, this.drive}) : super(key: key);

  @override
  _DriveFormDialogState createState() => _DriveFormDialogState();
}

class _DriveFormDialogState extends State<DriveFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyController;
  late TextEditingController _jobTitleController;
  late TextEditingController _descriptionController;
  late TextEditingController _applyLinkController;
  DateTime? _selectedDriveDate; // Store selected DateTime
  late List<String> _technologies; // Local state for skills

  @override
  void initState() {
    super.initState();
    // Initialize controllers and state
    _companyController = TextEditingController(text: widget.drive?.companyName ?? '');
    _jobTitleController = TextEditingController(text: widget.drive?.jobTitle ?? '');
    _descriptionController = TextEditingController(text: widget.drive?.description ?? '');
    _applyLinkController = TextEditingController(text: widget.drive?.applyLink ?? '');
    _selectedDriveDate = widget.drive?.driveDate.toDate(); // Convert Timestamp to DateTime
    _technologies = List<String>.from(widget.drive?.requiredTechnologies ?? []);
  }

  @override
  void dispose() {
    _companyController.dispose();
    _jobTitleController.dispose();
    _descriptionController.dispose();
    _applyLinkController.dispose();
    super.dispose();
  }

  // --- Function to show Date Picker ---
  Future<void> _pickDriveDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDriveDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Drives can't be in the past
      lastDate: DateTime(DateTime.now().year + 5), // Allow up to 5 years in future
    );
    if (picked != null && picked != _selectedDriveDate) {
      setState(() {
        _selectedDriveDate = picked;
      });
    }
  }

  void _handleTechnologiesChanged(List<String> newTech) {
    setState(() { _technologies = newTech; });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDriveDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a drive date.')));
        return;
      }
      // Return the entered data as a map
      final driveData = {
        'companyName': _companyController.text.trim(),
        'jobTitle': _jobTitleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'driveDate': Timestamp.fromDate(_selectedDriveDate!), // Convert DateTime back to Timestamp
        'applyLink': _applyLinkController.text.trim().isEmpty ? null : _applyLinkController.text.trim(), // Store null if empty
        'requiredTechnologies': _technologies.isEmpty ? null : _technologies, // Store null if empty
      };
      Navigator.of(context).pop(driveData); // Return data
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.drive == null ? 'Add Upcoming Drive' : 'Edit Upcoming Drive'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _companyController,
                decoration: InputDecoration(labelText: 'Company Name *', border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _jobTitleController,
                decoration: InputDecoration(labelText: 'Job Title / Role(s) *', border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              // --- Date Picker ---
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Drive Date *"),
                subtitle: Text(_selectedDriveDate == null
                    ? 'Select Date'
                    : DateFormat('EEEE, MMM d, yyyy').format(_selectedDriveDate!)),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickDriveDate(context),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description / Eligibility *', border: OutlineInputBorder(), alignLabelWithHint: true),
                maxLines: 4,
                validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                  controller: _applyLinkController,
                  decoration: InputDecoration(labelText: 'Apply/Register Link (Optional)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.url,
                  validator: (value) { // Optional field, only validate if not empty
                    if (value != null && value.trim().isNotEmpty) {
                      final uri = Uri.tryParse(value.trim());
                      if (uri == null || !uri.hasAbsolutePath || !uri.scheme.startsWith('http')) {
                        return 'Please enter a valid URL';
                      }
                    }
                    return null;
                  }
              ),
              SizedBox(height: 16),
              // --- Technologies Input ---
              Text("Required Technologies (Optional)", style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8),
              SkillsInputField( // Reuse the skills input widget
                initialSkills: _technologies,
                onChanged: _handleTechnologiesChanged,
              ),

            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(widget.drive == null ? 'Add Drive' : 'Save Changes'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
          onPressed: _submit,
        ),
      ],
    );
  }
}