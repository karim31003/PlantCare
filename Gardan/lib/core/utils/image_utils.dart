import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  /// Pick a photo and return the raw file without opening the editor.
  static Future<File?> pickDirect({
    required ImageSource source,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 800,
    );
    if (picked == null) return null;

    return File(picked.path);
  }

  /// Pick from [source], then open the full editor.
  /// Returns null if the user cancels either step.
  static Future<File?> pickAndEdit({
    required BuildContext context,
    required ImageSource source,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 800,
    );
    if (picked == null) return null;

    final originalFile = File(picked.path);
    final edited = await _openEditor(context, await originalFile.readAsBytes());
    return edited ?? originalFile;
  }

  /// Re-open the editor on an already-selected file.
  static Future<File?> editExisting({
    required BuildContext context,
    required File file,
  }) async {
    final edited = await _openEditor(context, await file.readAsBytes());
    return edited ?? file;
  }

  static Future<File?> _openEditor(
      BuildContext context, Uint8List bytes) async {
    final result = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        builder: (_) => ImageEditor(
          image: bytes,
        ),
      ),
    );

    if (result == null) return null;

    // Save edited bytes to a temp file
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/plant_edit_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(path);
    await file.writeAsBytes(result);
    return file;
  }
}
