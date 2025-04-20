import 'package:flutter/material.dart';

class SkillsInputField extends StatefulWidget {
  final List<String> initialSkills;
  final Function(List<String>) onChanged;

  const SkillsInputField({
    Key? key,
    required this.initialSkills,
    required this.onChanged,
  }) : super(key: key);

  @override
  _SkillsInputFieldState createState() => _SkillsInputFieldState();
}

class _SkillsInputFieldState extends State<SkillsInputField> {
  late List<String> _skills;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _skills = List<String>.from(widget.initialSkills);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    // Add skill from text field when focus is lost and text is not empty
    if (!_focusNode.hasFocus && _textController.text.trim().isNotEmpty) {
      _addSkill(_textController.text.trim());
    }
  }

  void _addSkill(String skill) {
    final String trimmedSkill = skill.trim();
    if (trimmedSkill.isNotEmpty && !_skills.contains(trimmedSkill)) {
      setState(() {
        _skills.add(trimmedSkill);
      });
      widget.onChanged(_skills); // Notify parent
    }
    _textController.clear(); // Clear input field
    FocusScope.of(context).requestFocus(_focusNode); // Keep focus on text field
  }

  void _removeSkill(String skillToRemove) {
    setState(() {
      _skills.remove(skillToRemove);
    });
    widget.onChanged(_skills); // Notify parent
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _skills.map((skill) {
            return Chip(
              label: Text(skill),
              onDeleted: () => _removeSkill(skill),
              deleteIconColor: Colors.redAccent,
              backgroundColor: Colors.deepPurple.shade50,
            );
          }).toList(),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          decoration: InputDecoration(
              labelText: 'Add Skill',
              hintText: 'Type a skill and press Enter or tap away',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: IconButton(
                icon: Icon(Icons.add_circle_outline, color: Colors.deepPurple),
                onPressed: () => _addSkill(_textController.text.trim()),
              )
          ),
          onSubmitted: _addSkill, // Add skill on Enter key press
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}