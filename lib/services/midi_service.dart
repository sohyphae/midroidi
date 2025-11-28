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

  // request bulk dump of the current patch from the reface
  void requestPatchDump() {
    sendData([0xF0, 0x43, 0x20, 0x7F, 0x1C, 0x03, 0x0E, 0x0F, 0x00, 0xF7]);
  }
}
