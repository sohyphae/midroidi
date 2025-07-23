import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
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

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  List<MidiDevice> _midiDevices = [];
  MidiDevice? _selectedMidiDevice;

  StreamSubscription<String>? _midiSetupSubscription;
  StreamSubscription<MidiPacket>? _midiDataSubscription;

  @override
  void initState() {
    super.initState();
    final midiService = ref.read(midiServiceProvider);
    _refreshDevices();

    _midiSetupSubscription = midiService.onMidiSetupChanged?.listen((data) {
      // _refreshDevices();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data)));
      }
    });

    _midiDataSubscription = midiService.onMidiDataReceived?.listen((packet) {
      // Filter out noisy
      if (packet.data.length == 1 &&
          (packet.data[0] == 248 || (packet.data[0] == 254))) {
        return;
      }
      _handleControlChange(packet.data);
      print('Received: ${packet.data.toString()} from ${packet.device.name}');
    });
  }

  void _handleControlChange(List<int> data) {
    // CC for now for live param tweaks, may try SysEx later?
    // Return when not CC message, condition 2 filters when not a CC message on any channel
    if (data.length < 3 || (data[0] & 0xF0) != 0xB0) {
      return;
    }

    final controlChangeNumber = data[1];
    final value = data[2];

    final patchNotifier = ref.read(patchProvider.notifier);

    switch (controlChangeNumber) {
      case 78:
        patchNotifier.updateLfoAssignState(LfoType.values[value ~/ 26]);
        break;
      case 77:
        patchNotifier.updateLfoDepth(value);
        break;
      case 76:
        patchNotifier.updateLfoSpeed(value);
        break;
      case 20:
        patchNotifier.updatePortamento(value);
        break;
      case 80:
        patchNotifier.updateOscTypeState(OscType.values[value ~/ 26]);
        break;
      case 81:
        patchNotifier.updateOscTextureState(value);
        break;
      case 82:
        patchNotifier.updateOscModState(value);
        break;
      case 74:
        patchNotifier.updateCutoffState(value);
        break;
      case 71:
        patchNotifier.updateResonanceState(value);
        break;
      case 83:
        patchNotifier.updateEgBalanceState(value);
        break;
      case 73:
        patchNotifier.updateEgAttackState(value);
        break;
      case 75:
        patchNotifier.updateEgDecayState(value);
        break;
      case 79:
        patchNotifier.updateEgSustainState(value);
        break;
      case 72:
        patchNotifier.updateEgReleaseState(value);
        break;
      case 17:
        patchNotifier.updateEffectTypeState(EffectType.values[value ~/ 26]);
        break;
      case 18:
        patchNotifier.updateEffectDepthState(value);
        break;
      case 19:
        patchNotifier.updateEffectRateState(value);
        break;
    }
  }

  @override
  void dispose() {
    _midiSetupSubscription?.cancel();
    _midiDataSubscription?.cancel();
    // disconnectDevice()
    super.dispose();
  }

  void _refreshDevices() async {
    final midiService = ref.read(midiServiceProvider);
    List<MidiDevice> devices = await midiService.devices;
    setState(() {
      _midiDevices = devices;
      if (_midiDevices.isNotEmpty) {
        _selectedMidiDevice = _midiDevices[0];
      }
    });
  }

  void _connect() {
    if (_selectedMidiDevice != null) {
      final midiService = ref.read(midiServiceProvider);
      midiService.connectToDevice(_selectedMidiDevice!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connecting to ${_selectedMidiDevice!.name}...'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the patch provider for changes
    final patch = ref.watch(patchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Midroidi Editor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDevices,
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
              value: _selectedMidiDevice,
              isExpanded: true,
              hint: const Text('No devices found'),
              onChanged: (MidiDevice? newValue) {
                setState(() {
                  _selectedMidiDevice = newValue;
                });
              },
              items: _midiDevices.map<DropdownMenuItem<MidiDevice>>((
                MidiDevice device,
              ) {
                return DropdownMenuItem<MidiDevice>(
                  value: device,
                  child: Text(device.name),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('2. Connect to device'),
            ElevatedButton(
              onPressed: _selectedMidiDevice != null ? _connect : null,
              child: const Text('Connect'),
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
