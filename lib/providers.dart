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

  // Update app state AND send MIDI message with new parameter values
  void updateCutoff(int newCutoff) {
    state = state.copyWith(cutoff: newCutoff);

    final List<int> controlChangeFilter = [
      0xB0, // Control change on MIDI channel 1 - todo: enable channel setting in future
      74, // CC number for filter cutoff
      newCutoff,
    ];
    _midiService.sendData(controlChangeFilter);
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
