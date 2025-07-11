import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'midi_service.dart';

void main() {
  runApp(const MyApp());
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MidiService _midiService = MidiService();
  StreamSubscription<String>? _midiSetupSubscription;
  StreamSubscription<MidiPacket>? _midiDataSubscription;
  final List<String> _receivedData = [];
  List<MidiDevice> _midiDevices = [];
  MidiDevice? _selectedMidiDevice;

  @override
  void initState() {
    super.initState();
    _refreshDevices();

    // Listen for midi setup changes (devices dis/connecting)
    _midiSetupSubscription = _midiService.onMidiSetupChanged?.listen((data) {
      // _refreshDevices();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data)));
    });

    // Listen & save latest incoming midi msgs to state
    _midiDataSubscription = _midiService.onMidiDataReceived?.listen((packet) {
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
    List<MidiDevice> devices = await _midiService.devices;
    setState(() {
      _midiDevices = devices;
      if (_midiDevices.isNotEmpty) {
        _selectedMidiDevice = _midiDevices[0];
      }
    });
  }

  void _connect() {
    if (_selectedMidiDevice != null) {
      _midiService.connectToDevice(_selectedMidiDevice!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connecting to ${_selectedMidiDevice!.name}...'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // filter noisy msgs from test device
    final showData = _receivedData.isNotEmpty
        ? !['[248]', '[254]'].any((elem) => _receivedData[0].contains(elem))
        : true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Midroidi: POC'),
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
            const SizedBox(height: 20),
            const Divider(),
            const Text('Received data:'),
            Expanded(
              child: ListView.builder(
                itemCount: _receivedData.length,
                itemBuilder: (context, index) {
                  if (showData) {
                    print(_receivedData[0]);
                  }
                  return showData ? Text(_receivedData[index]) : Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
