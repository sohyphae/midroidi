import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_midi_command/flutter_midi_command.dart';

class MidiService {
  final MidiCommand _midiCommand = MidiCommand();

  // Stream that emits messages when the midi setup changes (e.g. device dis/connected)
  Stream<String>? get onMidiSetupChanged => _midiCommand.onMidiSetupChanged;

  // Stream that emits midi data packets from connected devices
  Stream<MidiPacket>? get onMidiDataReceived => _midiCommand.onMidiDataReceived;

  // Returns available midi devices
  Future<List<MidiDevice>> get devices async {
    return await _midiCommand.devices ?? [];
  }

  // Connects to the specified midi device
  void connectToDevice(MidiDevice device) {
    _midiCommand.connectToDevice(device);
  }

  // Disconnects from specified midi device
  void disconnectDevice(MidiDevice device) {
    _midiCommand.disconnectDevice(device);
  }

  // Sends a raw data packet (like a SysEx message) to the connected device
  // Needs to be a complete midi message
  void sendData(List<int> data) {
    _midiCommand.sendData(Uint8List.fromList(data));
  }
}
