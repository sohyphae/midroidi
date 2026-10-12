import 'dart:async';

abstract class RefaceCsEvent {
  const RefaceCsEvent();
}

class PatchDumpReceived extends RefaceCsEvent {
  const PatchDumpReceived(this.toneData);

  final List<int> toneData;

  @override
  String toString() => 'PatchDumpReceived(toneData: ${toneData.length} bytes)';
}

class CcParameterChanged extends RefaceCsEvent {
  const CcParameterChanged(this.parameter, this.value);

  final int parameter;
  final int value;

  @override
  String toString() => 'CcParameterChanged(param: $parameter, value: $value)';
}

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
        // is a CC message
        //     // (data[0] & 0xF0) != 0xB0: Masks off the channel nibble and checks the top bits for 0xB0, which is the Control Change status for channels 1–16 (0xB0…0xBF).
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
        final toneData = List<int>.from(_sysexBuffer.sublist(11, 33));
        _eventController.add(PatchDumpReceived(toneData));
      }
      // clear after processing bulk dump
      _sysexBuffer.clear();
    }
  }

  void _handleControlChange(List<int> data) {
    // cc msgs are always 3-bytes (status, parameter number, value)
    if (data.length < 3) {
      return;
    }
    final controlChangeNumber = data[1];
    final value = data[2];
    _eventController.add(CcParameterChanged(controlChangeNumber, value));
  }

  void dispose() {
    _eventController.close();
  }
}
