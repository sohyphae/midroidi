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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title: $value'),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
