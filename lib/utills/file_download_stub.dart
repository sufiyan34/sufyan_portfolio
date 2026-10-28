import 'dart:io';
import 'dart:typed_data';

/// Windows / macOS / Linux: writes [bytes] into the user's Downloads folder
/// (never overwrites — "Resume (1).pdf", …). Returns the saved path, or null
/// when unsupported (mobile) or the write fails.
Future<String?> saveBytesToDevice(Uint8List bytes, String fileName) async {
  try {
    final env = Platform.environment;
    final home = Platform.isWindows ? env['USERPROFILE'] : env['HOME'];
    if (home == null || home.isEmpty) return null;
    if (Platform.isAndroid || Platform.isIOS) return null;

    final sep = Platform.pathSeparator;
    final dir = Directory('$home${sep}Downloads');
    if (!await dir.exists()) await dir.create(recursive: true);

    final dot = fileName.lastIndexOf('.');
    final base = dot > 0 ? fileName.substring(0, dot) : fileName;
    final ext = dot > 0 ? fileName.substring(dot) : '';

    var file = File('${dir.path}$sep$fileName');
    for (var i = 1; await file.exists(); i++) {
      file = File('${dir.path}$sep$base ($i)$ext');
    }
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  } catch (_) {
    return null;
  }
}
