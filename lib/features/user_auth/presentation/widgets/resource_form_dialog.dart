// lib/widgets/resource_form_dialog.dart
import 'package:flutter/material.dart';

class ResourceFormDialog extends StatefulWidget {
  // Add initial data if editing is needed later
  const ResourceFormDialog({super.key});

  @override
  _ResourceFormDialogState createState() => _ResourceFormDialogState();
}

class _ResourceFormDialogState extends State<ResourceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final resourceData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'url': _urlController.text.trim(),
      };
      Navigator.of(context).pop(resourceData); // Return data
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Placement Resource'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Resource Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter a title' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter a description' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Resource URL *',
                  hintText: 'e.g., https://example.com/doc.pdf',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a URL';
                  }
                  final uri = Uri.tryParse(value.trim());
                  if (uri == null || !uri.hasAbsolutePath || !uri.scheme.startsWith('http')) {
                    return 'Please enter a valid, absolute URL (e.g., https://...)';
                  }
                  return null; // Valid
                },
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
          onPressed: _submit,
          child: Text('Add Resource'),
        ),
      ],
    );
  }
}