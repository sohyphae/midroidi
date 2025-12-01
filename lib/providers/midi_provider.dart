import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:midroidi/providers/patch_provider.dart';
import 'package:midroidi/models/patch.dart';

/* MidiStateNotifier: transport layer manager
main responsibility is to manage the connection to synths

MidiState:
- what midi devices are available?
- current user selected midi device
- current connection to that device
- route midi data to the appropriate handler */

final midiStateProvider = StateNotifierProvider<MidiStateNotifier, MidiState>((
  ref,
) {
  return MidiStateNotifier(ref);
});

class MidiState {
  final List<MidiDevice>? devices;
  final MidiDevice? selectedDevice;
  final bool isConnected;

  MidiState({this.devices, this.selectedDevice, this.isConnected = false});

  MidiState copyWith({
    List<MidiDevice>? devices,
    MidiDevice? selectedDevice,
    bool? isConnected,
  }) {
    return MidiState(
      devices: devices ?? this.devices,
      selectedDevice: selectedDevice ?? this.selectedDevice,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class MidiStateNotifier extends StateNotifier<MidiState> {
  final Ref _ref;
  StreamSubscription<String>? _midiSetupSubscription;
  StreamSubscription<MidiPacket>? _midiDataSubscription;
  final List<int> _sysexBuffer = [];

  MidiStateNotifier(this._ref) : super(MidiState()) {
    _midiSetupSubscription = _ref
        .read(midiServiceProvider)
        .onMidiSetupChanged
        ?.listen((data) {
          refreshDevices();
        });
    refreshDevices();
  }

  Future<void> refreshDevices() async {
    final devices = await _ref.read(midiServiceProvider).devices;
    MidiDevice? newSelectedDevice;

    if (state.selectedDevice != null) {
      for (var device in devices) {
        if (device.id == state.selectedDevice!.id) {
          newSelectedDevice = device;
          break;
        }
      }
    }

    state = state.copyWith(
      devices: devices,
      selectedDevice: newSelectedDevice,
      isConnected: newSelectedDevice?.connected ?? false,
    );
  }

  void selectDevice(MidiDevice? device) {
    state = state.copyWith(selectedDevice: device);
  }

  Future<void> connect() async {
    if (state.selectedDevice == null) return;

    _ref.read(midiServiceProvider).connectToDevice(state.selectedDevice!);
    _midiDataSubscription = _ref
        .read(midiServiceProvider)
        .onMidiDataReceived
        ?.listen((packet) {
          _onMidiData(packet.data);
        });
    state = state.copyWith(isConnected: true);
    // // Delay to allow the connection to establish before sending msg // doing this on new patch now
    // Future.delayed(const Duration(milliseconds: 500), () {
    //   _ref.read(midiServiceProvider).requestPatchDump();
    // });
  }

  void disconnect() {
    if (state.selectedDevice != null) {
      _ref.read(midiServiceProvider).disconnectDevice(state.selectedDevice!);
      _midiDataSubscription?.cancel();
      _midiDataSubscription = null;
      state = state.copyWith(selectedDevice: null, isConnected: false);
    }
  }

  void _onMidiData(List<int> data) {
    // Filter out noisy MIDI clock messages
    if (data.length == 1 && (data[0] == 248 || data[0] == 254)) {
      return;
    }

    if (data.isNotEmpty) {
      if ((data[0] & 0xF0) == 0xB0) {
        // is a CC message
        _handleControlChange(data);
      } else {
        _handleSysEx(data);
      }
    }
  }

  // Handles patch dump
  void _handleSysEx(List<int> data) {
    /* Reface doesn't send a single 61 byte SysEx msg. Instead, sends patch
    data sequence of three separate SysEx msgs:
    1) 13-byte header msg
    2) 35-byte msg with 22 bytes of patch data
    3) 13-byte footer msg
    This logic specifically targets the 35-byte msg */

    // SysEx msg start byte
    if (data[0] == 0xF0) {
      _sysexBuffer.clear();
      _sysexBuffer.addAll(data);
    } else if (_sysexBuffer.isNotEmpty) {
      // continue adding to the buffer
      _sysexBuffer.addAll(data);
    }

    // check for SysEx end byte
    if (_sysexBuffer.isNotEmpty && _sysexBuffer.last == 0xF7) {
      // check for the specific 35-byte tone data message
      if (_sysexBuffer.length == 35 &&
          _sysexBuffer[1] == 0x43 &&
          _sysexBuffer[8] == 0x30) {
        // this is the bulk dump! extract the relevant data (22 bytes)
        // Tone data starts at index 11 and is 22 bytes long
        final toneData = _sysexBuffer.sublist(11, 33);
        _ref.read(patchProvider.notifier).updateFromBulkDump(toneData);
        print('Patch received from Reface CS');
      }
      // clear after processing bulk dump
      _sysexBuffer.clear();
    }
  }

  void _handleControlChange(List<int> data) {
    if (data.length < 3) {
      return;
    }
    final controlChangeNumber = data[1];
    final value = data[2];

    final patchNotifier = _ref.read(patchProvider.notifier);
    switch (controlChangeNumber) {
      case 78:
        patchNotifier.updateLfoAssignState(LfoType.values[value ~/ 26]);
        break;
      case 77:
        patchNotifier.updateLfoDepthState(value);
        break;
      case 76:
        patchNotifier.updateLfoSpeedState(value);
        break;
      case 20:
        patchNotifier.updatePortamentoState(value);
        break;
      case 80:
        patchNotifier.updateOscTypeState(OscType.values[value ~/ 26]);
        break;
      case 81:
        patchNotifier.updateOscTextureState(value);
        break;
      case 82:
        patchNotifier.updateOscModState(value);
        break;
      case 74:
        patchNotifier.updateCutoffState(value);
        break;
      case 71:
        patchNotifier.updateResonanceState(value);
        break;
      case 83:
        patchNotifier.updateEgBalanceState(value);
        break;
      case 73:
        patchNotifier.updateEgAttackState(value);
        break;
      case 75:
        patchNotifier.updateEgDecayState(value);
        break;
      case 79:
        patchNotifier.updateEgSustainState(value);
        break;
      case 72:
        patchNotifier.updateEgReleaseState(value);
        break;
      case 17:
        patchNotifier.updateEffectTypeState(EffectType.values[value ~/ 26]);
        break;
      case 18:
        patchNotifier.updateEffectDepthState(value);
        break;
      case 19:
        patchNotifier.updateEffectRateState(value);
        break;
    }
  }

  @override
  void dispose() {
    _midiSetupSubscription?.cancel();
    _midiDataSubscription?.cancel();
    super.dispose();
  }
}
