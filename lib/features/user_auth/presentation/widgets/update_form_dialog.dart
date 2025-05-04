// lib/widgets/update_form_dialog.dart
import 'package:flutter/material.dart';
import '../models/tpo_update_model.dart'; // Adjust path if needed

class UpdateFormDialog extends StatefulWidget {
  // Pass existing update data for editing, null for adding
  final TpoUpdate? update;

  const UpdateFormDialog({super.key, this.update});

  @override
  _UpdateFormDialogState createState() => _UpdateFormDialogState();
}

class _UpdateFormDialogState extends State<UpdateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if editing
    _titleController = TextEditingController(text: widget.update?.title ?? '');
    _descriptionController = TextEditingController(text: widget.update?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Return the entered data as a map
      final updateData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
      };
      Navigator.of(context).pop(updateData); // Return data
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.update == null ? 'Add New Update' : 'Edit Update'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView( // Ensure content is scrollable
          child: Column(
            mainAxisSize: MainAxisSize.min, // Take minimum space
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a title' : null,
              ),
              SizedBox(height: 16), // Add spacing
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // Good for multi-line
                ),
                maxLines: 5, // Allow multi-line description
                validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a description' : null,
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, ),
          onPressed: _submit,
          child: Text(widget.update == null ? 'Add Update' : 'Save Changes' , style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}