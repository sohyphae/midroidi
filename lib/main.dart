import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/midi_provider.dart';
import 'providers/patch_provider.dart';
import 'reface_cs_patch.dart';
import 'components/parameter_slider.dart';
import 'components/parameter_dropdown.dart';
import 'components/section_header.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Midroidi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final midiState = ref.watch(midiStateProvider);
    final patch = ref.watch(patchProvider);

    final MidiDevice? selectedDevice = midiState.selectedDevice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Midroidi Editor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(midiStateProvider.notifier).refreshDevices(),
            tooltip: 'Refresh devices',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('1. Select MIDI device'),
            DropdownButton<MidiDevice>(
              value: selectedDevice,
              isExpanded: true,
              hint: const Text('No devices found'),
              onChanged: (MidiDevice? newValue) {
                ref.read(midiStateProvider.notifier).selectDevice(newValue);
              },
              items: midiState.devices?.map<DropdownMenuItem<MidiDevice>>((
                MidiDevice device,
              ) {
                return DropdownMenuItem<MidiDevice>(
                  value: device,
                  child: Text(device.name),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('2. Connection Status'),
            ElevatedButton(
              onPressed: midiState.isConnected
                  ? () => ref.read(midiStateProvider.notifier).disconnect()
                  : (selectedDevice != null
                        ? () => ref.read(midiStateProvider.notifier).connect()
                        : null),
              child: Text(midiState.isConnected ? 'Disconnect' : 'Connect'),
            ),
            const Divider(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ParameterSlider(
                      title: 'Volume',
                      value: patch.volume,
                      onChanged: (value) => ref
                          .read(patchProvider.notifier)
                          .updateVolume(value.toInt()),
                    ),
                    const Divider(),
                    const SectionHeader('LFO'),
                    ParameterDropdown<LfoType>(
                      value: patch.lfoType,
                      items: LfoType.values,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(patchProvider.notifier)
                              .updateLfoAssign(value);
                        }
                      },
                    ),
                    ParameterSlider(
                      title: 'LFO Depth',
                      value: patch.lfoDepth,
                      onChanged: (value) => ref
                          .read(patchProvider.notifier)
                          .updateLfoDepth(value.toInt()),
                    ),
                    ParameterSlider(
                      title: 'LFO Speed',
                      value: patch.lfoSpeed,
                      onChanged: (value) => ref
                          .read(patchProvider.notifier)
                          .updateLfoSpeed(value.toInt()),
                    ),
                    const Divider(),
                    const SectionHeader('Portamento'),
                    // Synth controls are more quantized here, may want to fix later
                    ParameterSlider(
                      title: 'Portamento',
                      value: patch.portamento,
                      onChanged: (value) => ref
                          .read(patchProvider.notifier)
                          .updatePortamento(value.toInt()),
                    ),
                    const Divider(),
                    const SectionHeader('Oscillator'),
                    ParameterDropdown<OscType>(
                      value: patch.oscType,
                      items: OscType.values.reversed.toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(patchProvider.notifier).updateOscType(value);
                        }
                      },
                    ),
                    ParameterSlider(
                      title: 'OSC Texture',
                      value: patch.texture,
                      onChanged: (value) => ref
                          .read(patchProvider.notifier)
                          .updateOscTexture(value.toInt()),
                    ),
                    ParameterSlider(
                      title: 'OSC Mod',
                      value: patch.mod,
                      onChanged: (value) => ref
                          .read(patchProvider.notifier)
                          .updateOscMod(value.toInt()),
                    ),
                    const Divider(),
                    const SectionHeader('Filter'),
                    ParameterSlider(
                      title: 'Cutoff',
                      value: patch.cutoff,
                      onChanged: (value) => ref
                          .read(patchProvider.notifier)
                          .updateCutoff(value.toInt()),
                    ),
                    ParameterSlider(
                      title: 'Resonance',
                      value: patch.resonance,
                      onChanged: (value) => ref
                          .read(patchProvider.notifier)
                          .updateResonance(value.toInt()),
                    ),
                    const Divider(),
                    const SectionHeader('Envelope Generator'),
                    ParameterSlider(
                      title: 'EG Balance',
                      value: patch.fegAegBalance,
                      onChanged: (value) => ref
                          .read(patchProvider.notifier)
                          .updateEgBalance(value.toInt()),
                    ),
                    ParameterSlider(
                      title: 'Attack',
                      value: patch.attack,
                      onChanged: (value) => ref
                          .read(patchProvider.notifier)
                          .updateEgAttack(value.toInt()),
                    ),
                    ParameterSlider(
                      title: 'Decay',
                      value: patch.decay,
                      onChanged: (value) => ref
                          .read(patchProvider.notifier)
                          .updateEgDecay(value.toInt()),
                    ),
                    ParameterSlider(
                      title: 'Sustain',
                      value: patch.sustain,
                      onChanged: (value) => ref
                          .read(patchProvider.notifier)
                          .updateEgSustain(value.toInt()),
                    ),
                    ParameterSlider(
                      title: 'Release',
                      value: patch.release,
                      onChanged: (value) => ref
                          .read(patchProvider.notifier)
                          .updateEgRelease(value.toInt()),
                    ),
                    const Divider(),
                    const SectionHeader('Effect'),
                    ParameterDropdown<EffectType>(
                      value: patch.effectType,
                      items: EffectType.values,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(patchProvider.notifier)
                              .updateEffectType(value);
                        }
                      },
                    ),
                    ParameterSlider(
                      title: 'Effect Depth',
                      value: patch.effectDepth,
                      onChanged: (value) => ref
                          .read(patchProvider.notifier)
                          .updateEffectDepth(value.toInt()),
                    ),
                    ParameterSlider(
                      title: 'Effect Rate',
                      value: patch.effectRate,
                      onChanged: (value) => ref
                          .read(patchProvider.notifier)
                          .updateEffectRate(value.toInt()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
