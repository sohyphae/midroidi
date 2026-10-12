import 'dart:async';

import '../models/patch.dart';

abstract class RefaceCsEvent {
  const RefaceCsEvent();
}

class PatchDumpReceived extends RefaceCsEvent {
  const PatchDumpReceived(this.patchData);

  final RefaceCsPatchData patchData;

  @override
  String toString() => 'PatchDumpReceived(${patchData.toJson()})';
}

class ParameterChanged extends RefaceCsEvent {
  const ParameterChanged(this.param, this.value);

  final RefaceCsParam param;
  final int value;

  @override
  String toString() => 'ParameterChanged(${param.name}: $value)';
}

// App to synth
class RefaceCsEncoder {
  static List<int> parameterChange(RefaceCsParam param, int value) => [
    0xF0, // Start of SysEx
    0x43, // Yamaha ID
    0x10, // Device Number
    0x7F, // Group Number High
    0x1C, // Group Number Low
    0x03, // Model ID
    0x30, // Address High
    0x00, // Address Mid
    param.address, // Address Low: parameter to change
    value, // Data
    0xF7, // End of SysEx
  ];

  // Request a bulk dump of the synth's current patch
  static const List<int> patchDumpRequest = [
    0xF0, 0x43, 0x20, 0x7F, 0x1C, 0x03, 0x0E, 0x0F, 0x00, 0xF7, //
  ];
}

// Synth to app
class RefaceCsParser {
  final List<int> _sysexBuffer = [];
  final StreamController<RefaceCsEvent> _eventController =
      StreamController<RefaceCsEvent>.broadcast();

  Stream<RefaceCsEvent> get eventStream => _eventController.stream;

  void processMidiData(List<int> data) {
    // Filter out noisy MIDI clock messages
    if (data.length == 1 && (data[0] == 0xF8 || data[0] == 0xFE)) {
      return;
    }

    if (data.isNotEmpty) {
      if ((data[0] & 0xF0) == 0xB0) {
        // Checks top bits for 0xB0, which is the cc status
        _handleControlChange(data);
      } else if (data[0] == 0xF0 || _sysexBuffer.isNotEmpty) {
        _handleSysEx(data);
      }
    }
  }

  void _handleSysEx(List<int> data) {
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
        _eventController.add(PatchDumpReceived(_decodeToneData(toneData)));
      }
      // clear after processing bulk dump
      _sysexBuffer.clear();
    }
  }

  // Decode synth SysEx tone data to our patch data
  RefaceCsPatchData _decodeToneData(List<int> toneData) {
    var patchData = RefaceCsPatchData();
    for (final param in RefaceCsParam.values) {
      patchData = patchData.withParam(param, toneData[param.address]);
    }
    return patchData;
  }

  void _handleControlChange(List<int> data) {
    // cc msgs are always 3-bytes (status, parameter number, value)
    if (data.length < 3) {
      return;
    }
    final param = RefaceCsParam.fromCc(data[1]);
    if (param == null) {
      return;
    }
    _eventController.add(ParameterChanged(param, _valueFromCc(param, data[2])));
  }

  // Selectors span 0-127 across 5 options, about 26 per step
  int _valueFromCc(RefaceCsParam param, int ccValue) =>
      param.options == null ? ccValue : ccValue ~/ 26;

  void dispose() {
    _eventController.close();
  }
}
