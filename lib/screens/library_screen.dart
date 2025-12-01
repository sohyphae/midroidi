import 'package:flutter/material.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midroidi/screens/patch_screen.dart';
import 'package:uuid/uuid.dart';
import '../providers/midi_provider.dart';
import '../providers/patch_provider.dart';

const _uuid = Uuid();

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final midiState = ref.watch(midiStateProvider);
    final patchState = ref.watch(patchProvider);

    final MidiDevice? selectedDevice = midiState.selectedDevice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Midroidi Editor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(midiStateProvider.notifier).refreshDevices(),
            tooltip: 'Refresh devices',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('1. Select MIDI device'),
            DropdownButton<MidiDevice>(
              value: selectedDevice,
              isExpanded: true,
              hint: const Text('Show devices'),
              onChanged: (MidiDevice? newValue) {
                ref.read(midiStateProvider.notifier).selectDevice(newValue);
              },
              items: midiState.devices?.map<DropdownMenuItem<MidiDevice>>((
                MidiDevice device,
              ) {
                return DropdownMenuItem<MidiDevice>(
                  value: device,
                  child: Text(device.name),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('2. Connection Status'),
            ElevatedButton(
              onPressed: midiState.isConnected
                  ? () => ref.read(midiStateProvider.notifier).disconnect()
                  : (selectedDevice != null
                        ? () => ref.read(midiStateProvider.notifier).connect()
                        : null),
              child: Text(midiState.isConnected ? 'Disconnect' : 'Connect'),
            ),
            const Divider(height: 30),
            ElevatedButton(
              child: Text('New patch'),
              onPressed: () async {
                final newPatchId = _uuid.v4();
                await ref.read(patchProvider.notifier).newPatch(newPatchId);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PatchScreen(id: newPatchId),
                  ),
                );
              },
            ),
            const Divider(height: 30),
            const Text('Saved patches'),
            Expanded(
              child: ListView.builder(
                itemCount: patchState.savedPatches.length,
                itemBuilder: (context, index) {
                  final patch = patchState.savedPatches[index];
                  return Column(
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                            child: Text(patch.name),
                            onPressed: () {
                              ref
                                  .read(patchProvider.notifier)
                                  .loadPatch(patch.id);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PatchScreen(id: patch.id),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'delete patch',
                            onPressed: () => {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete patch forever?'),
                                    content: Text(
                                      "You cannot undo this operation",
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Delete patch'),
                                        onPressed: () {
                                          ref
                                              .read(patchProvider.notifier)
                                              .deletePatch(patch.id);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
