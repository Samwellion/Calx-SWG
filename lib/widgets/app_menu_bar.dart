import 'package:flutter/material.dart';

class AppMenuBar extends StatelessWidget {
  final String selected;
  final void Function(String) onMenuSelected;
  const AppMenuBar({
    super.key,
    required this.selected,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'label': 'Home', 'route': '/home'},
      {'label': 'Organization Setup', 'route': '/organization'},
      {'label': 'Plant Setup', 'route': '/plant'},
      {'label': 'Part Input', 'route': '/part'},
      {'label': 'Process Input', 'route': '/process'},
      {'label': 'Settings', 'route': '/settings'},
    ];
    return Container(
      width: 220,
      color: Colors.yellow[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          ...menuItems.map((item) {
            final isSelected = selected == item['label'];
            return ListTile(
              title: Text(
                item['label']!,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.black87,
                  fontSize: 18,
                ),
              ),
              selected: isSelected,
              selectedTileColor: Colors.yellow[300],
              onTap: () => onMenuSelected(item['label']!),
            );
            // ignore: unnecessary_to_list_in_spreads
          }).toList(),
        ],
      ),
    );
  }
}
