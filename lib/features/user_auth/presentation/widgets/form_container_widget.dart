import 'package:flutter/material.dart';

class FormContainerWidget extends StatefulWidget {
  final TextEditingController? controller;
  final Key? fieldKey;
  final bool? isPasswordField;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  // final FormFieldValidator<String>? validator; // Keep this signature
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? inputType;
  final IconData? prefixIcon; // Added for icons
  final VoidCallback? onTap; // Added for tapping
  final bool readOnly; // Added for read-only state
  // Accept validator function with correct signature
  final String? Function(String?)? validator;


  const FormContainerWidget({
    super.key,
    this.controller,
    this.isPasswordField,
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator, // Accept the validator
    this.onFieldSubmitted,
    this.inputType,
    this.prefixIcon,
    this.onTap,
    this.readOnly = false,
  });

  @override
  _FormContainerWidgetState createState() => _FormContainerWidgetState();
}

class _FormContainerWidgetState extends State<FormContainerWidget> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    // Ensure initial state respects isPasswordField
    if (widget.isPasswordField != true) {
      _obscureText = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      // Removed fixed width to allow stretching
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white, // White background for the field
        borderRadius: BorderRadius.circular(12), // Slightly more rounded corners
        boxShadow: [ // Subtle shadow for depth
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField( // Uses TextFormField for validation
        style: TextStyle(color: Colors.black87),
        controller: widget.controller,
        keyboardType: widget.inputType,
        key: widget.fieldKey,
        obscureText: widget.isPasswordField == true ? _obscureText : false,
        onSaved: widget.onSaved,
        validator: widget.validator, // Pass validator to TextFormField
        onFieldSubmitted: widget.onFieldSubmitted,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        decoration: InputDecoration(
          border: InputBorder.none, // Remove default border of TextFormField within Container
          filled: true, // Needed for background color
          fillColor: Colors.white, // Match container background
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Adjusted padding
          // Correctly implement prefixIcon
          prefixIcon: widget.prefixIcon != null
              ? Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 8.0),
            child: Icon(widget.prefixIcon, color: Colors.deepPurple.shade300, size: 20),
          )
              : null,
          // Suffix icon logic for password visibility toggle
          suffixIcon: widget.isPasswordField == true
              ? InkWell( // Use InkWell for better tap feedback area
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0), // Add padding
              child: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade500,
                size: 20, // Consistent icon size
              ),
            ),
          )
              : null, // No suffix icon if not a password field
        ),
      ),
    );
  }
}