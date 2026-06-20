import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

/// Ouvre le sélecteur de fichier natif du navigateur.
Future<Uint8List?> pickImageAsBytes() async {
  final completer = Completer<Uint8List?>();

  final upload = html.FileUploadInputElement()..accept = 'image/*';

  upload.onChange.listen((_) {
    final file = upload.files?.first;
    if (file == null) {
      completer.complete(null);
      return;
    }
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoad.listen((_) {
      final result = reader.result;
      if (result is List<int>) {
        completer.complete(Uint8List.fromList(result));
      } else {
        completer.complete(null);
      }
    });
    reader.onError.listen((_) => completer.complete(null));
  });

  upload.click();

  return completer.future;
}
