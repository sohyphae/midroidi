import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/parameter_dropdown.dart';
import '../components/parameter_slider.dart';
import '../components/section_header.dart';
import '../providers/patch_provider.dart';
import '../models/patch.dart';

class PatchScreen extends ConsumerWidget {
  const PatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patchData = ref.watch(patchProvider).activePatch.patchData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patch {name}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            //todo
            onPressed: () => {},
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
              value: patchData.volume,
              onChanged: (value) =>
                  ref.read(patchProvider.notifier).updateVolume(value.toInt()),
            ),
            const Divider(),
            const SectionHeader('LFO'),
            ParameterDropdown<LfoType>(
              value: patchData.lfoType,
              items: LfoType.values,
              onChanged: (value) {
                if (value != null) {
                  ref.read(patchProvider.notifier).updateLfoAssign(value);
                }
              },
            ),
            ParameterSlider(
              title: 'LFO Depth',
              value: patchData.lfoDepth,
              onChanged: (value) => ref
                  .read(patchProvider.notifier)
                  .updateLfoDepth(value.toInt()),
            ),
            ParameterSlider(
              title: 'LFO Speed',
              value: patchData.lfoSpeed,
              onChanged: (value) => ref
                  .read(patchProvider.notifier)
                  .updateLfoSpeed(value.toInt()),
            ),
            const Divider(),
            const SectionHeader('Portamento'),
            // Synth controls are more quantized here, may want to fix later
            ParameterSlider(
              title: 'Portamento',
              value: patchData.portamento,
              onChanged: (value) => ref
                  .read(patchProvider.notifier)
                  .updatePortamento(value.toInt()),
            ),
            const Divider(),
            const SectionHeader('Oscillator'),
            ParameterDropdown<OscType>(
              value: patchData.oscType,
              items: OscType.values.reversed.toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(patchProvider.notifier).updateOscType(value);
                }
              },
            ),
            ParameterSlider(
              title: 'OSC Texture',
              value: patchData.texture,
              onChanged: (value) => ref
                  .read(patchProvider.notifier)
                  .updateOscTexture(value.toInt()),
            ),
            ParameterSlider(
              title: 'OSC Mod',
              value: patchData.mod,
              onChanged: (value) =>
                  ref.read(patchProvider.notifier).updateOscMod(value.toInt()),
            ),
            const Divider(),
            const SectionHeader('Filter'),
            ParameterSlider(
              title: 'Cutoff',
              value: patchData.cutoff,
              onChanged: (value) =>
                  ref.read(patchProvider.notifier).updateCutoff(value.toInt()),
            ),
            ParameterSlider(
              title: 'Resonance',
              value: patchData.resonance,
              onChanged: (value) => ref
                  .read(patchProvider.notifier)
                  .updateResonance(value.toInt()),
            ),
            const Divider(),
            const SectionHeader('Envelope Generator'),
            ParameterSlider(
              title: 'EG Balance',
              value: patchData.fegAegBalance,
              onChanged: (value) => ref
                  .read(patchProvider.notifier)
                  .updateEgBalance(value.toInt()),
            ),
            ParameterSlider(
              title: 'Attack',
              value: patchData.attack,
              onChanged: (value) => ref
                  .read(patchProvider.notifier)
                  .updateEgAttack(value.toInt()),
            ),
            ParameterSlider(
              title: 'Decay',
              value: patchData.decay,
              onChanged: (value) =>
                  ref.read(patchProvider.notifier).updateEgDecay(value.toInt()),
            ),
            ParameterSlider(
              title: 'Sustain',
              value: patchData.sustain,
              onChanged: (value) => ref
                  .read(patchProvider.notifier)
                  .updateEgSustain(value.toInt()),
            ),
            ParameterSlider(
              title: 'Release',
              value: patchData.release,
              onChanged: (value) => ref
                  .read(patchProvider.notifier)
                  .updateEgRelease(value.toInt()),
            ),
            const Divider(),
            const SectionHeader('Effect'),
            ParameterDropdown<EffectType>(
              value: patchData.effectType,
              items: EffectType.values,
              onChanged: (value) {
                if (value != null) {
                  ref.read(patchProvider.notifier).updateEffectType(value);
                }
              },
            ),
            ParameterSlider(
              title: 'Effect Depth',
              value: patchData.effectDepth,
              onChanged: (value) => ref
                  .read(patchProvider.notifier)
                  .updateEffectDepth(value.toInt()),
            ),
            ParameterSlider(
              title: 'Effect Rate',
              value: patchData.effectRate,
              onChanged: (value) => ref
                  .read(patchProvider.notifier)
                  .updateEffectRate(value.toInt()),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
