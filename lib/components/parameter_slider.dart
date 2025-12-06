import 'package:flutter/material.dart';

class ParameterSlider extends StatelessWidget {
  const ParameterSlider({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 127,
  });

  final String title;
  final int value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SizedBox(width: 120.0, child: Text('$title: $value')),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            label: value.toString(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
