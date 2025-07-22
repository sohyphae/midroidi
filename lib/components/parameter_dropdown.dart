import 'package:flutter/material.dart';

class ParameterDropdown<T> extends StatelessWidget {
  const ParameterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<T>(
          value: value,
          onChanged: onChanged,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString().split('.').last),
            );
          }).toList(),
        ),
      ],
    );
  }
}
