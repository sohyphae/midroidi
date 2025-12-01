import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../services/midi_service.dart';
import '../models/patch.dart';

/*PatchNotifier: patch data model manager
manage the state of a Reface CS patch (or patch_es_ - upcoming)
more about what the actual data means
no info about how connection established / data that is being sent/received / which device is doing thta
*/

// Provider for the MidiService
final midiServiceProvider = Provider<MidiService>((ref) {
  return MidiService();
});

const _uuid = Uuid();

class PatchState {
  PatchState({required this.savedPatches, required this.activePatch});

  final List<Patch> savedPatches;
  final Patch activePatch;

  factory PatchState.initial() {
    final initialPatch = Patch(
      id: _uuid.v4(),
      name: 'Existing Patch',
      patchData: RefaceCsPatchData(),
    );
    return PatchState(savedPatches: [initialPatch], activePatch: initialPatch);
  }

  PatchState copyWith({List<Patch>? savedPatches, Patch? activePatch}) {
    return PatchState(
      savedPatches: savedPatches ?? this.savedPatches,
      activePatch: activePatch ?? this.activePatch,
    );
  }
}

// StateNotifier for the RefaceCsPatch
class PatchNotifier extends StateNotifier<PatchState> {
  PatchNotifier(this._midiService) : super(PatchState.initial());

  final MidiService _midiService;

  Patch getPatch(String patchId) {
    return state.savedPatches.firstWhere((p) => p.id == patchId);
  }

  void loadPatch(String patchId) {
    final patch = getPatch(patchId);
    state = state.copyWith(activePatch: patch);
    sendPatchToSynth(patch.patchData);
  }

  Future<void> newPatch(String newId) async {
    final newPatch = Patch(
      id: newId,
      name: 'New Patch',
      patchData:
          RefaceCsPatchData(), // will be overwritten shortly by bulk dump
    );
    state = state.copyWith(activePatch: newPatch);
    _midiService.requestPatchDump();
  }

  void savePatch(String? id, String name) {
    final patchToSave = state.activePatch.copyWith(id: id, name: name);
    final newSavedPatches = List<Patch>.from(state.savedPatches);

    if (newSavedPatches.any((p) => p.id == id)) {
      newSavedPatches[newSavedPatches.indexWhere(
            (p) => p.id == patchToSave.id,
          )] =
          patchToSave;
    } else {
      newSavedPatches.add(patchToSave);
    }

    state = state.copyWith(
      activePatch: patchToSave, // for activePatch consumers
      savedPatches: newSavedPatches,
    );
  }

  void deletePatch(String? id) {
    final newSavedPatches = List<Patch>.from(state.savedPatches);

    newSavedPatches.removeWhere((p) => p.id == id);

    state = state.copyWith(savedPatches: newSavedPatches);
  }

  // TODO: Reface CS can read but not transmit vol data, consider how to handle in UI?
  void updateVolumeState(int newVolume) {
    final newPatchData = state.activePatch.patchData.copyWith(
      volume: newVolume,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateLfoAssignState(LfoType newLfoAssign) {
    final newPatchData = state.activePatch.patchData.copyWith(
      lfoType: newLfoAssign,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateLfoDepthState(int newLfoDepth) {
    final newPatchData = state.activePatch.patchData.copyWith(
      lfoDepth: newLfoDepth,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateLfoSpeedState(int newLfoSpeed) {
    final newPatchData = state.activePatch.patchData.copyWith(
      lfoSpeed: newLfoSpeed,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updatePortamentoState(int newPortamento) {
    final newPatchData = state.activePatch.patchData.copyWith(
      portamento: newPortamento,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateOscTypeState(OscType newOscType) {
    final newPatchData = state.activePatch.patchData.copyWith(
      oscType: newOscType,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateOscTextureState(int newTexture) {
    final newPatchData = state.activePatch.patchData.copyWith(
      texture: newTexture,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateOscModState(int newMod) {
    final newPatchData = state.activePatch.patchData.copyWith(mod: newMod);
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateCutoffState(int newCutoff) {
    final newPatchData = state.activePatch.patchData.copyWith(
      cutoff: newCutoff,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateResonanceState(int newResonance) {
    final newPatchData = state.activePatch.patchData.copyWith(
      resonance: newResonance,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateEgBalanceState(int newEgBalance) {
    final newPatchData = state.activePatch.patchData.copyWith(
      fegAegBalance: newEgBalance,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateEgAttackState(int newAttack) {
    final newPatchData = state.activePatch.patchData.copyWith(
      attack: newAttack,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateEgDecayState(int newDecay) {
    final newPatchData = state.activePatch.patchData.copyWith(decay: newDecay);
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateEgSustainState(int newSustain) {
    final newPatchData = state.activePatch.patchData.copyWith(
      sustain: newSustain,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateEgReleaseState(int newRelease) {
    final newPatchData = state.activePatch.patchData.copyWith(
      release: newRelease,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateEffectTypeState(EffectType newEffectType) {
    final newPatchData = state.activePatch.patchData.copyWith(
      effectType: newEffectType,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateEffectDepthState(int newEffectDepth) {
    final newPatchData = state.activePatch.patchData.copyWith(
      effectDepth: newEffectDepth,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

  void updateEffectRateState(int newEffectRate) {
    final newPatchData = state.activePatch.patchData.copyWith(
      effectRate: newEffectRate,
    );
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: newPatchData),
    );
  }

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

  // Send SysEx
  void updateVolume(int newVolume) {
    updateVolumeState(newVolume);
    _sendSysEx(0x00, newVolume);
  }

  void updateLfoAssign(LfoType newLfoAssign) {
    updateLfoAssignState(newLfoAssign);
    _sendSysEx(0x02, newLfoAssign.index);
  }

  void updateLfoDepth(int newLfoDepth) {
    updateLfoDepthState(newLfoDepth);
    _sendSysEx(0x03, newLfoDepth);
  }

  void updateLfoSpeed(int newLfoSpeed) {
    updateLfoSpeedState(newLfoSpeed);
    _sendSysEx(0x04, newLfoSpeed);
  }

  void updatePortamento(int newPortamento) {
    updatePortamentoState(newPortamento);
    _sendSysEx(0x05, newPortamento);
  }

  void updateOscType(OscType newOscType) {
    updateOscTypeState(newOscType);
    _sendSysEx(0x06, newOscType.index);
  }

  void updateOscTexture(int newTexture) {
    updateOscTextureState(newTexture);
    _sendSysEx(0x07, newTexture);
  }

  void updateOscMod(int newMod) {
    updateOscModState(newMod);
    _sendSysEx(0x08, newMod);
  }

  void updateCutoff(int newCutoff) {
    updateCutoffState(newCutoff);
    _sendSysEx(0x09, newCutoff);
  }

  void updateResonance(int newResonance) {
    updateResonanceState(newResonance);
    _sendSysEx(0x0A, newResonance);
  }

  void updateEgBalance(int newEgBalance) {
    updateEgBalanceState(newEgBalance);
    _sendSysEx(0x0B, newEgBalance);
  }

  void updateEgAttack(int newAttack) {
    updateEgAttackState(newAttack);
    _sendSysEx(0x0C, newAttack);
  }

  void updateEgDecay(int newDecay) {
    updateEgDecayState(newDecay);
    _sendSysEx(0x0D, newDecay);
  }

  void updateEgSustain(int newSustain) {
    updateEgSustainState(newSustain);
    _sendSysEx(0x0E, newSustain);
  }

  void updateEgRelease(int newRelease) {
    updateEgReleaseState(newRelease);
    _sendSysEx(0x0F, newRelease);
  }

  void updateEffectType(EffectType newEffectType) {
    updateEffectTypeState(newEffectType);
    _sendSysEx(0x10, newEffectType.index);
  }

  void updateEffectDepth(int newEffectDepth) {
    updateEffectDepthState(newEffectDepth);
    _sendSysEx(0x11, newEffectDepth);
  }

  void updateEffectRate(int newEffectRate) {
    updateEffectRateState(newEffectRate);
    _sendSysEx(0x12, newEffectRate);
  }

  void sendPatchToSynth(RefaceCsPatchData patch) {
    updateVolume(patch.volume);
    updateLfoAssign(patch.lfoType);
    updateLfoDepth(patch.lfoDepth);
    updateLfoSpeed(patch.lfoSpeed);
    updatePortamento(patch.portamento);
    updateOscType(patch.oscType);
    updateOscTexture(patch.texture);
    updateOscMod(patch.mod);
    updateCutoff(patch.cutoff);
    updateResonance(patch.resonance);
    updateEgBalance(patch.fegAegBalance);
    updateEgAttack(patch.attack);
    updateEgDecay(patch.decay);
    updateEgSustain(patch.sustain);
    updateEgRelease(patch.release);
    updateEffectType(patch.effectType);
    updateEffectDepth(patch.effectDepth);
    updateEffectRate(patch.effectRate);
  }

  void updateFromBulkDump(List<int> data) {
    final newPatchData = state.activePatch.patchData.copyWith(
      // note in manual: "[vol] can be set only via MIDI" :| handle with cc later
      volume: data[0], // not working
      lfoType: LfoType.values[data[2]],
      lfoDepth: data[3],
      lfoSpeed: data[4],
      portamento: data[5],
      oscType: OscType.values[data[6]],
      texture: data[7],
      mod: data[8],
      cutoff: data[9],
      resonance: data[10],
      fegAegBalance: data[11],
      attack: data[12],
      decay: data[13],
      sustain: data[14],
      release: data[15],
      effectType: EffectType.values[data[16]],
      effectDepth: data[17],
      effectRate: data[18],
    );

    final newActivePatch = state.activePatch.copyWith(patchData: newPatchData);

    state = state.copyWith(activePatch: newActivePatch);

    print('''
        Active patch: 
          Volume: ${state.activePatch.patchData.volume},
          LFO Type: ${state.activePatch.patchData.lfoType},
          LFO Depth: ${state.activePatch.patchData.lfoDepth},
          LFO Speed: ${state.activePatch.patchData.lfoSpeed},
          Portamento: ${state.activePatch.patchData.portamento},
          OSC Type: ${state.activePatch.patchData.oscType},
          Texture: ${state.activePatch.patchData.texture},
          Mod: ${state.activePatch.patchData.mod},
          Cutoff: ${state.activePatch.patchData.cutoff},
          Resonance: ${state.activePatch.patchData.resonance},
          EG Balance: ${state.activePatch.patchData.fegAegBalance},
          Attack: ${state.activePatch.patchData.attack},
          Decay: ${state.activePatch.patchData.decay},
          Sustain: ${state.activePatch.patchData.sustain},
          Release: ${state.activePatch.patchData.release},
          Effect Type: ${state.activePatch.patchData.effectType},
          Effect Depth: ${state.activePatch.patchData.effectDepth},
          Effect Rate: ${state.activePatch.patchData.effectRate},
        ''');
  }
}

final patchProvider = StateNotifierProvider<PatchNotifier, PatchState>((ref) {
  // Watch the midiServiceProvider to get the MidiService instance
  // and provide it to the PatchNotifier
  final midiService = ref.watch(midiServiceProvider);
  return PatchNotifier(midiService);
});
