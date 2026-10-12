import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:midroidi/services/reface_cs_codec.dart';
import 'package:midroidi/services/midi_service.dart';

/* MidiStateNotifier: transport layer manager
main responsibility is to manage the connection to synths

MidiState:
- what midi devices are available?
- current user selected midi device
- current connection to that device */

final midiStateProvider = StateNotifierProvider<MidiStateNotifier, MidiState>((
  ref,
) {
  return MidiStateNotifier(ref);
});

final refaceCsParserProvider = Provider<RefaceCsParser>((ref) {
  final parser = RefaceCsParser();
  ref.onDispose(() => parser.dispose());
  return parser;
});

final refaceCsEventStreamProvider = StreamProvider<RefaceCsEvent>((ref) {
  final parser = ref.watch(refaceCsParserProvider);
  final midiService = ref.watch(midiServiceProvider);

  final subscription = midiService.onMidiDataReceived?.listen((packet) {
    parser.processMidiData(packet.data);
  });

  ref.onDispose(() => subscription?.cancel());

  return parser.eventStream;
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
    state = state.copyWith(isConnected: true);
  }

  void disconnect() {
    if (state.selectedDevice != null) {
      _ref.read(midiServiceProvider).disconnectDevice(state.selectedDevice!);
      state = state.copyWith(selectedDevice: null, isConnected: false);
    }
  }

  @override
  void dispose() {
    _midiSetupSubscription?.cancel();
    super.dispose();
  }
}
