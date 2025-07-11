import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'midi_service.dart';
import 'reface_cs_patch.dart';

// Provider for the MidiService
final midiServiceProvider = Provider<MidiService>((ref) {
  return MidiService();
});

// StateNotifier for the RefaceCsPatch
class PatchNotifier extends StateNotifier<RefaceCsPatch> {
  final MidiService _midiService;

  PatchNotifier(this._midiService) : super(RefaceCsPatch());

  // Update app state AND sends the MIDI message with new parameter values
  void updateCutoff(int newCutoff) {
    _midiService.devices;

    state = state.copyWith(cutoff: newCutoff);
    // SysEx msg
    // F0 43 10 7F 1C 03 00 00 09 vv F7
    final List<int> sysexMessage = [
      0xF0, // Start of Exclusive
      0x43, // Yamaha ID
      0x10, // Device Number (MIDI Channel 1) // CHECK
      0x7F, // Group Number High
      0x1C, // Group Number Low
      0x03, // Model ID (Reface CS)
      0x00, // Address High
      0x00, // Address Mid
      0x09, // Address Low (Filter Cutoff)
      newCutoff, // Data (the new value)
      0xF7, // End of Exclusive
    ];
    _midiService.sendData(sysexMessage);
  }

  // // Later : send all parameters
  // void loadPatch(RefaceCsPatch patch) {
  //   state = patch;
  // }
}

final patchProvider = StateNotifierProvider<PatchNotifier, RefaceCsPatch>((
  ref,
) {
  // Watch the midiServiceProvider to get the MidiService instance
  // and provide it to the PatchNotifier
  final midiService = ref.watch(midiServiceProvider);
  return PatchNotifier(midiService);
});
