import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Browser: triggers a normal file download of [bytes] named [fileName].
/// Returns a short description of where it went, or null on failure.
Future<String?> saveBytesToDevice(Uint8List bytes, String fileName) async {
  try {
    final blob = web.Blob(
      [bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'application/octet-stream'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName
      ..style.display = 'none';
    web.document.body!.append(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
    return 'your Downloads folder';
  } catch (_) {
    return null;
  }
}
