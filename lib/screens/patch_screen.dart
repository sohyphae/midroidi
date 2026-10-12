import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/parameter_dropdown.dart';
import '../components/parameter_slider.dart';
import '../models/patch.dart';
import '../providers/patch_provider.dart';

class PatchScreen extends ConsumerWidget {
  const PatchScreen({this.id, super.key});

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patchName = ref.watch(
      patchProvider.select((state) => state.activePatch.name),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(patchName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final TextEditingController nameController =
                  TextEditingController(text: patchName);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Save Patch'),
                    content: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: "Enter patch name",
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Save'),
                        onPressed: () {
                          ref
                              .read(patchProvider.notifier)
                              .savePatch(id, nameController.text);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: 'save or something',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ParameterSlider(param: RefaceCsParam.volume),
            const Divider(),
            const ParameterDropdown(
              param: RefaceCsParam.lfoType,
              reversed: true,
            ),
            const ParameterSlider(param: RefaceCsParam.lfoDepth),
            const ParameterSlider(param: RefaceCsParam.lfoSpeed),
            const Divider(),
            // const SectionHeader('Portamento'),
            // Synth controls are more quantized here, may want to fix later
            const ParameterSlider(param: RefaceCsParam.portamento),
            const Divider(),
            const ParameterDropdown(
              param: RefaceCsParam.oscType,
              reversed: true,
            ),
            const ParameterSlider(param: RefaceCsParam.texture),
            const ParameterSlider(param: RefaceCsParam.mod),
            const Divider(),
            const ParameterSlider(param: RefaceCsParam.cutoff),
            const ParameterSlider(param: RefaceCsParam.resonance),
            const Divider(),
            const ParameterSlider(param: RefaceCsParam.fegAegBalance),
            const ParameterSlider(param: RefaceCsParam.attack),
            const ParameterSlider(param: RefaceCsParam.decay),
            const ParameterSlider(param: RefaceCsParam.sustain),
            const ParameterSlider(param: RefaceCsParam.release),
            const Divider(),
            const ParameterDropdown(param: RefaceCsParam.effectType),
            const ParameterSlider(param: RefaceCsParam.effectDepth),
            const ParameterSlider(param: RefaceCsParam.effectRate),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
