import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patch.dart';
import '../providers/patch_provider.dart';

class ParameterDropdown extends ConsumerWidget {
  const ParameterDropdown({
    super.key,
    required this.param,
    this.reversed = false,
  });

  final RefaceCsParam param;
  // reverse where actual synth panel is inverted vs midi data table
  final bool reversed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(
      patchProvider.select((state) => state.activePatch.patchData.get(param)),
    );
    final options = param.options!;
    final indices = List.generate(options.length, (i) => i);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<int>(
                value: value,
                onChanged: (newValue) {
                  if (newValue != null) {
                    ref.read(patchProvider.notifier).setParam(param, newValue);
                  }
                },
                items: (reversed ? indices.reversed : indices).map((int index) {
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(options[index].name),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
