import 'package:flutter/material.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, int index);

class EditableListSection<T> extends StatelessWidget {
  final List<T> items;
  final String titleKey; // Key in the map to display as the main title
  final String? subtitleKey; // Optional key for subtitle
  final VoidCallback onAdd;
  final Function(int index) onEdit;
  final Function(int index) onDelete;
  final String addItemLabel;
  final String emptyListText;

  const EditableListSection({
    Key? key,
    required this.items,
    required this.titleKey,
    this.subtitleKey,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.addItemLabel = 'Add Item',
    this.emptyListText = 'No items added yet.',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(emptyListText, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          )
        else
          ListView.builder(
            shrinkWrap: true, // Important inside SingleChildScrollView
            physics: NeverScrollableScrollPhysics(), // Prevent nested scrolling issues
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              String title = 'N/A';
              String? subtitle;

              if (item is Map) {
                title = item[titleKey]?.toString() ?? 'N/A';
                if (subtitleKey != null) {
                  subtitle = item[subtitleKey]?.toString();
                }
              } else {
                // Handle case where T is not a Map, maybe just use item.toString()?
                title = item.toString();
              }


              return Card( // Use Card for better separation
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: subtitle != null ? Text(subtitle) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blueGrey),
                        onPressed: () => onEdit(index),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => onDelete(index),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        SizedBox(height: 8),
        Align( // Align button to the right or center
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: Icon(Icons.add, color: Colors.deepPurple),
            label: Text(addItemLabel, style: TextStyle(color: Colors.deepPurple)),
            onPressed: onAdd,
          ),
        ),
      ],
    );
  }
}