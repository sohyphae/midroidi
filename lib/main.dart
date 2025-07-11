import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

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
  final List<String> _receivedData = [];

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
      setState(() {
        _receivedData.insert(
          0,
          'Received: ${packet.data.toString()} from ${packet.device.name}',
        );
        if (_receivedData.length > 5) {
          _receivedData.removeLast();
        }
      });
    });
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
            Text(
              'Filter Cutoff: ${patch.cutoff}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Slider(
              value: patch.cutoff.toDouble(),
              min: 0,
              max: 127,
              divisions: 127,
              label: patch.cutoff.toString(),
              onChanged: (double value) {
                ref.read(patchProvider.notifier).updateCutoff(value.toInt());
              },
            ),

            const Divider(height: 30),
            const Text('Received data:'),
            Expanded(
              child: ListView.builder(
                itemCount: _receivedData.length,
                itemBuilder: (context, index) {
                  return Text(_receivedData[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
