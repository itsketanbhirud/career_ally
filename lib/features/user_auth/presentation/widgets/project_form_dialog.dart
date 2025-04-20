import 'package:flutter/material.dart';

class ProjectFormDialog extends StatefulWidget {
  final Map<String, String>? project; // Pass existing project data for editing

  const ProjectFormDialog({Key? key, this.project}) : super(key: key);

  @override
  _ProjectFormDialogState createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _linkController; // Optional link

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project?['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.project?['description'] ?? '');
    _linkController = TextEditingController(text: widget.project?['link'] ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final projectData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'link': _linkController.text.trim(),
      };
      // Remove empty link if needed
      if (projectData['link']!.isEmpty) {
        projectData.remove('link');
      }
      Navigator.of(context).pop(projectData); // Return data
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.project == null ? 'Add Project' : 'Edit Project'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView( // Ensure content is scrollable
          child: Column(
            mainAxisSize: MainAxisSize.min, // Take minimum space
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Project Title *'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3, // Allow multi-line description
              ),
              SizedBox(height: 8),
              TextFormField(
                  controller: _linkController,
                  decoration: InputDecoration(labelText: 'Project Link (Optional)'),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !Uri.tryParse(value)!.isAbsolute) {
                      return 'Please enter a valid URL';
                    }
                    return null;
                  }
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(), // Close without returning data
        ),
        ElevatedButton(
          child: Text(widget.project == null ? 'Add' : 'Save'),
          onPressed: _submit,
        ),
      ],
    );
  }
}