import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'midi_service.dart';
import 'reface_cs_patch.dart';

// Provider for the MidiService
final midiServiceProvider = Provider<MidiService>((ref) {
  return MidiService();
});

// StateNotifier for the RefaceCsPatch
class PatchNotifier extends StateNotifier<RefaceCsPatch> {
  PatchNotifier(this._midiService) : super(RefaceCsPatch());

  final MidiService _midiService;

  // Update app state AND send MIDI message with new parameter values
  void updateCutoff(int newCutoff) {
    state = state.copyWith(cutoff: newCutoff);

    // F0 43 10 7F 1C 03 30 00 09 dd F7
    final List<int> sysexMessage = [
      0xF0, // Start of SysEx
      0x43, // // Yamaha ID
      0x10, // Device Number
      0x7F, // Group Number High
      0x1C, // Group Number Low
      0x03, // Model ID
      0x30, // Address High
      0x00, // Address Mid
      0x09, // Address Low
      newCutoff, // Data
      0xF7, // End of SysEx
    ];
    _midiService.sendData(sysexMessage);
  }

  void updateResonance(int newResonance) {
    state = state.copyWith(resonance: newResonance);

    // F0 43 10 7F 1C 03 30 00 0A dd F7
    final List<int> sysexMessage = [
      0xF0, // Start of SysEx
      0x43, // Yamaha ID
      0x10, // Device Number
      0x7F, // Group Number High
      0x1C, // Group Number Low
      0x03, // Model ID
      0x30, // Address High
      0x00, // Address Mid
      0x0A, // Address Low
      newResonance, // Data
      0xF7, // End of SysEx
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
