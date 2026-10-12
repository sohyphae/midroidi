import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patch.dart';
import '../providers/patch_provider.dart';

class ParameterSlider extends ConsumerWidget {
  const ParameterSlider({
    super.key,
    required this.param,
    this.min = 0,
    this.max = 127,
  });

  final RefaceCsParam param;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(
      patchProvider.select((state) => state.activePatch.patchData.get(param)),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SizedBox(width: 120.0, child: Text('${param.label}: $value')),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            label: value.toString(),
            onChanged: (newValue) => ref
                .read(patchProvider.notifier)
                .setParam(param, newValue.toInt()),
          ),
        ),
      ],
    );
  }
}
