import 'package:flutter/material.dart';

class ExperienceFormDialog extends StatefulWidget {
  final Map<String, String>? experience; // Pass existing data for editing

  const ExperienceFormDialog({super.key, this.experience});

  @override
  _ExperienceFormDialogState createState() => _ExperienceFormDialogState();
}

class _ExperienceFormDialogState extends State<ExperienceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyController;
  late TextEditingController _roleController;
  late TextEditingController _durationController; // e.g., "Jun 2022 - Aug 2022" or "3 months"
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: widget.experience?['company'] ?? '');
    _roleController = TextEditingController(text: widget.experience?['role'] ?? '');
    _durationController = TextEditingController(text: widget.experience?['duration'] ?? '');
    _descriptionController = TextEditingController(text: widget.experience?['description'] ?? '');
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final experienceData = {
        'company': _companyController.text.trim(),
        'role': _roleController.text.trim(),
        'duration': _durationController.text.trim(),
        'description': _descriptionController.text.trim(),
      };
      Navigator.of(context).pop(experienceData); // Return data
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.experience == null ? 'Add Experience' : 'Edit Experience'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _companyController,
                decoration: InputDecoration(labelText: 'Company/Organization *'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a company name' : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _roleController,
                decoration: InputDecoration(labelText: 'Role/Position *'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your role' : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(labelText: 'Duration (e.g., Jun 2023 - Present)'),
                // Consider using Date Pickers for start/end dates for better UX
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description/Responsibilities'),
                maxLines: 3,
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
          onPressed: _submit,
          child: Text(widget.experience == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}