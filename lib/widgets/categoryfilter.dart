import 'package:flutter/material.dart';

class FilterWidget extends StatefulWidget {
  final List<String> categories; // List of categories to display
  final Function(String) onCategorySelected; // Callback to pass selected category

  const FilterWidget({
    Key? key,
    required this.categories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  String selectedCategory = 'All'; // Default selected category

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widget.categories.map((category) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategory = category; // Update selected category
            });
            widget.onCategorySelected(category); // Notify parent widget
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: selectedCategory == category ? Colors.yellow : Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category,
              style: TextStyle(
                color: selectedCategory == category ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

