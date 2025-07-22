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

  // Base SysEx message for Reface CS parameter change
  // F0 43 10 7F 1C 03 hh mm ll dd F7
  final List<int> _baseSysEx = [
    0xF0, // Start of SysEx
    0x43, // Yamaha ID
    0x10, // Device Number
    0x7F, // Group Number High
    0x1C, // Group Number Low
    0x03, // Model ID
    0x30, // Address High
    0x00, // Address Mid
    0x00, // Address Low
    0x00, // Data
    0xF7, // End of SysEx
  ];

  void _sendSysEx(int addressLow, int data) {
    final message = List<int>.from(_baseSysEx);
    message[8] = addressLow; // Parameter to change
    message[9] = data; // Change value
    _midiService.sendData(message);
  }

  void updateVolume(int newVolume) {
    state = state.copyWith(volume: newVolume);
    _sendSysEx(0x00, newVolume);
  }

  void updateLfoAssign(LfoType newLfoAssign) {
    state = state.copyWith(lfoType: newLfoAssign);
    _sendSysEx(0x02, newLfoAssign.index);
  }

  void updateLfoDepth(int newLfoDepth) {
    state = state.copyWith(lfoDepth: newLfoDepth);
    _sendSysEx(0x03, newLfoDepth);
  }

  void updateLfoSpeed(int newLfoSpeed) {
    state = state.copyWith(lfoSpeed: newLfoSpeed);
    _sendSysEx(0x04, newLfoSpeed);
  }

  void updatePortamento(int newPortamento) {
    state = state.copyWith(portamento: newPortamento);
    _sendSysEx(0x05, newPortamento);
  }

  void updateOscType(OscType newOscType) {
    state = state.copyWith(oscType: newOscType);
    _sendSysEx(0x06, newOscType.index);
  }

  void updateOscTexture(int newTexture) {
    state = state.copyWith(texture: newTexture);
    _sendSysEx(0x07, newTexture);
  }

  void updateOscMod(int newMod) {
    state = state.copyWith(mod: newMod);
    _sendSysEx(0x08, newMod);
  }

  void updateCutoff(int newCutoff) {
    state = state.copyWith(cutoff: newCutoff);
    _sendSysEx(0x09, newCutoff);
  }

  void updateResonance(int newResonance) {
    state = state.copyWith(resonance: newResonance);
    _sendSysEx(0x0A, newResonance);
  }

  void updateEgBalance(int newEgBalance) {
    state = state.copyWith(fegAegBalance: newEgBalance);
    _sendSysEx(0x0B, newEgBalance);
  }

  void updateEgAttack(int newAttack) {
    state = state.copyWith(attack: newAttack);
    _sendSysEx(0x0C, newAttack);
  }

  void updateEgDecay(int newDecay) {
    state = state.copyWith(decay: newDecay);
    _sendSysEx(0x0D, newDecay);
  }

  void updateEgSustain(int newSustain) {
    state = state.copyWith(sustain: newSustain);
    _sendSysEx(0x0E, newSustain);
  }

  void updateEgRelease(int newRelease) {
    state = state.copyWith(release: newRelease);
    _sendSysEx(0x0F, newRelease);
  }

  void updateEffectType(EffectType newEffectType) {
    state = state.copyWith(effectType: newEffectType);
    _sendSysEx(0x10, newEffectType.index);
  }

  void updateEffectDepth(int newEffectDepth) {
    state = state.copyWith(effectDepth: newEffectDepth);
    _sendSysEx(0x11, newEffectDepth);
  }

  void updateEffectRate(int newEffectRate) {
    state = state.copyWith(effectRate: newEffectRate);
    _sendSysEx(0x12, newEffectRate);
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
