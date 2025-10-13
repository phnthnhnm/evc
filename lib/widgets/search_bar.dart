import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const SearchBar({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Search by name',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
