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
            ParameterSlider(
              title: 'Volume',
              select: (data) => data.volume,
              onChanged: (notifier, value) => notifier.updateVolume(value),
            ),
            const Divider(),
            ParameterDropdown<LfoType>(
              select: (data) => data.lfoType,
              items: LfoType.values,
              onChanged: (notifier, value) => notifier.updateLfoAssign(value),
            ),
            ParameterSlider(
              title: 'LFO Depth',
              select: (data) => data.lfoDepth,
              onChanged: (notifier, value) => notifier.updateLfoDepth(value),
            ),
            ParameterSlider(
              title: 'LFO Speed',
              select: (data) => data.lfoSpeed,
              onChanged: (notifier, value) => notifier.updateLfoSpeed(value),
            ),
            const Divider(),
            // const SectionHeader('Portamento'),
            // Synth controls are more quantized here, may want to fix later
            ParameterSlider(
              title: 'Portamento',
              select: (data) => data.portamento,
              onChanged: (notifier, value) => notifier.updatePortamento(value),
            ),
            const Divider(),
            ParameterDropdown<OscType>(
              select: (data) => data.oscType,
              items: OscType.values.reversed.toList(),
              onChanged: (notifier, value) => notifier.updateOscType(value),
            ),
            ParameterSlider(
              title: 'OSC Texture',
              select: (data) => data.texture,
              onChanged: (notifier, value) => notifier.updateOscTexture(value),
            ),
            ParameterSlider(
              title: 'OSC Mod',
              select: (data) => data.mod,
              onChanged: (notifier, value) => notifier.updateOscMod(value),
            ),
            const Divider(),
            ParameterSlider(
              title: 'Cutoff',
              select: (data) => data.cutoff,
              onChanged: (notifier, value) => notifier.updateCutoff(value),
            ),
            ParameterSlider(
              title: 'Resonance',
              select: (data) => data.resonance,
              onChanged: (notifier, value) => notifier.updateResonance(value),
            ),
            const Divider(),
            ParameterSlider(
              title: 'EG Balance',
              select: (data) => data.fegAegBalance,
              onChanged: (notifier, value) => notifier.updateEgBalance(value),
            ),
            ParameterSlider(
              title: 'Attack',
              select: (data) => data.attack,
              onChanged: (notifier, value) => notifier.updateEgAttack(value),
            ),
            ParameterSlider(
              title: 'Decay',
              select: (data) => data.decay,
              onChanged: (notifier, value) => notifier.updateEgDecay(value),
            ),
            ParameterSlider(
              title: 'Sustain',
              select: (data) => data.sustain,
              onChanged: (notifier, value) => notifier.updateEgSustain(value),
            ),
            ParameterSlider(
              title: 'Release',
              select: (data) => data.release,
              onChanged: (notifier, value) => notifier.updateEgRelease(value),
            ),
            const Divider(),
            ParameterDropdown<EffectType>(
              select: (data) => data.effectType,
              items: EffectType.values,
              onChanged: (notifier, value) => notifier.updateEffectType(value),
            ),
            ParameterSlider(
              title: 'Effect Depth',
              select: (data) => data.effectDepth,
              onChanged: (notifier, value) => notifier.updateEffectDepth(value),
            ),
            ParameterSlider(
              title: 'Effect Rate',
              select: (data) => data.effectRate,
              onChanged: (notifier, value) => notifier.updateEffectRate(value),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
