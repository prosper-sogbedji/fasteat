import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

/// Ouvre le sélecteur de fichier natif (desktop / mobile).
Future<Uint8List?> pickImageAsBytes() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
    withData: true,
  );
  return result?.files.first.bytes;
}
