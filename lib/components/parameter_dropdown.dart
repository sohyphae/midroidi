import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patch.dart';
import '../providers/patch_provider.dart';

class ParameterDropdown<T> extends ConsumerWidget {
  const ParameterDropdown({
    super.key,
    required this.select,
    required this.items,
    required this.onChanged,
  });

  final T Function(RefaceCsPatchData patchData) select;
  final List<T> items;
  final void Function(PatchNotifier notifier, T value) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(
      patchProvider.select((state) => select(state.activePatch.patchData)),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<T>(
                value: value,
                onChanged: (newValue) {
                  if (newValue != null) {
                    onChanged(ref.read(patchProvider.notifier), newValue);
                  }
                },
                items: items.map((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString().split('.').last),
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
