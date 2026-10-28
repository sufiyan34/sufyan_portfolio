// Saves bytes straight to the user's computer (no new tab, no navigation).
// Web: builds a Blob and clicks a hidden <a download>. Other platforms: the
// stub returns false so callers can fall back to opening the link.
export 'file_download_stub.dart'
    if (dart.library.js_interop) 'file_download_web.dart';
