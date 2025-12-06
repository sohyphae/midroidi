import 'dart:convert';
import 'dart:io';

import 'package:midroidi/models/patch.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // nicer browse in file system but id is safer as name currently non unique
  Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName.json');
  }

  Future<void> savePatch(Patch patch) async {
    final file = await _localFile(patch.name);
    final jsonString = jsonEncode(patch.toJson());
    await file.writeAsString(jsonString);
  }

  Future<List<Patch>> loadPatches() async {
    try {
      final path = await _localPath;
      final directory = Directory(path);
      final files = directory
          .listSync()
          .where((item) => item.path.endsWith('.json'))
          .toList();

      final List<Patch> patches = [];
      for (final fileSystemEntity in files) {
        final file = File(fileSystemEntity.path);
        final jsonString = await file.readAsString();
        patches.add(Patch.fromJson(jsonDecode(jsonString)));
      }
      return patches;
    } catch (e) {
      // If encountering an error, return an empty list
      return [];
    }
  }

  Future<void> deletePatch(String patchName) async {
    try {
      final file = await _localFile(patchName);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Error handling for deletion
      print('Error deleting patch: $e');
    }
  }
}
