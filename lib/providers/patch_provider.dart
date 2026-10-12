import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../services/midi_service.dart';
import '../services/storage_service.dart';
import '../models/patch.dart';
import '../services/reface_cs_codec.dart';
import 'midi_provider.dart';

/*PatchNotifier: patch data model manager
manage the state of a Reface CS patch (or patch_es_ - upcoming)
more about what the actual data means
no info about how connection established / data that is being sent/received / which device is doing thta
*/

const _uuid = Uuid();

class PatchState {
  PatchState({
    required this.savedPatches,
    required this.activePatch,
    this.isLoading = true,
  });

  final List<Patch> savedPatches;
  final Patch activePatch;
  final bool isLoading;

  factory PatchState.initial() {
    final initialPatch = Patch(
      id: _uuid.v4(),
      name: 'Default Patch',
      patchData: RefaceCsPatchData(),
    );
    return PatchState(
      savedPatches: [],
      activePatch: initialPatch,
      isLoading: true,
    );
  }

  PatchState copyWith({
    List<Patch>? savedPatches,
    Patch? activePatch,
    bool? isLoading,
  }) {
    return PatchState(
      savedPatches: savedPatches ?? this.savedPatches,
      activePatch: activePatch ?? this.activePatch,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// StateNotifier for the RefaceCsPatch
class PatchNotifier extends StateNotifier<PatchState> {
  PatchNotifier(this._ref, this._midiService, this._storageService)
    : super(PatchState.initial()) {
    _loadPatches();
    _listenToMidiEvents();
  }

  final Ref _ref;
  final MidiService _midiService;
  final StorageService _storageService;

  void _listenToMidiEvents() {
    _ref.listen(refaceCsEventStreamProvider, (previous, next) {
      next.whenData((event) {
        if (event is PatchDumpReceived) {
          _setPatchData(event.patchData);
        } else if (event is CcParameterChanged) {
          handleCcParameter(event.parameter, event.value);
        }
      });
    });
  }

  Future<void> _loadPatches() async {
    final patches = await _storageService.loadPatches();
    if (patches.isNotEmpty) {
      state = state.copyWith(
        savedPatches: patches,
        activePatch: patches.first,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

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
    _midiService.sendData(RefaceCsEncoder.patchDumpRequest);
  }

  Future<void> savePatch(String? id, String name) async {
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
      activePatch: patchToSave,
      savedPatches: newSavedPatches,
    );
    await _storageService.savePatch(patchToSave);
  }

  Future<void> deletePatch(String? id) async {
    if (id != null) {
      final patchToDelete = state.savedPatches.firstWhere((p) => p.id == id);
      final newSavedPatches = List<Patch>.from(state.savedPatches);

      newSavedPatches.removeWhere((p) => p.id == id);

      state = state.copyWith(savedPatches: newSavedPatches);
      await _storageService.deletePatch(patchToDelete.id);
    }
  }

  // Set a parameter on the activePatch
  // When called from a UI widget, also send to synth
  void setParam(RefaceCsParam param, int value, {bool sendToSynth = true}) {
    _setPatchData(state.activePatch.patchData.withParam(param, value));
    if (sendToSynth) {
      _midiService.sendData(RefaceCsEncoder.parameterChange(param, value));
    }
  }

  // Whole patch update - state only
  void _setPatchData(RefaceCsPatchData patchData) {
    state = state.copyWith(
      activePatch: state.activePatch.copyWith(patchData: patchData),
    );
  }

  void sendPatchToSynth(RefaceCsPatchData patch) {
    _setPatchData(patch);
    for (final param in RefaceCsParam.values) {
      _midiService.sendData(
        RefaceCsEncoder.parameterChange(param, patch.get(param)),
      );
    }
  }

  void handleCcParameter(int parameter, int value) {
    final param = RefaceCsParam.fromCc(parameter);
    if (param != null) {
      setParam(param, param.valueFromCc(value), sendToSynth: false);
    }
  }
}

final patchProvider = StateNotifierProvider<PatchNotifier, PatchState>((ref) {
  final midiService = ref.watch(midiServiceProvider);
  final storageService = StorageService();
  return PatchNotifier(ref, midiService, storageService);
});
