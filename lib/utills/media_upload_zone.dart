// ============================================================
// MEDIA UPLOAD ZONE
// ============================================================
//
// A single drop-in widget for uploading images, videos, or any file to
// Cloudinary — with drag & drop, clipboard paste, and browse-to-select,
// plus per-file progress, success and failure states.
//
// WHAT IT REUSES FROM THE EXISTING CLOUDINARY MODULE
// ----------------------------------------------------------
// This does not re-implement uploading, compression, validation, or error
// mapping — [CloudinaryService] (services/cloudinary/cloudinary_service.dart)
// and [CloudinaryMediaHelper] already do all of that correctly:
//   - Images are compressed client-side before upload
//     (CloudinaryMediaHelper.compressImage, via flutter_image_compress).
//   - Videos upload as-is; Cloudinary optimizes them for delivery instead
//     (see `videoUrl` below) — client-side video re-encoding needs a
//     platform plugin with no web support, which would break drag-and-drop.
//   - Errors are already mapped to friendly messages (CloudinaryException).
// This widget only adds the missing piece: a UI to get files in (drag,
// paste, browse) and show upload progress/outcome per file.
//
// "COMPRESSED IN, DECOMPRESSED OUT"
// ----------------------------------------------------------
// - On the way in: images are compressed before the upload request
//   (see CloudinaryUploadOptions.compressImage, on by default).
// - On the way out: this widget never renders the original uploaded
//   bytes. It always renders through CloudinaryService's delivery
//   helpers (`imageUrl`, `videoThumbnailUrl`) which append Cloudinary's
//   `f_auto,q_auto` transformation — Cloudinary decodes/re-encodes the
//   stored asset into whatever format and quality suits the viewer on
//   the fly. Do the same in your own product/category screens: never
//   hand a raw `secureUrl` to an <Image>/CachedNetworkImage — always go
//   through `CloudinaryService.imageUrl(publicId, ...)`.
//
// REQUIRED PACKAGES (add if not already present)
// ----------------------------------------------------------
// Already used elsewhere in this project: dio, cross_file, file_picker,
// flutter_image_compress, cached_network_image, get.
//
// NEW for this widget — add to pubspec.yaml:
//   desktop_drop: ^0.4.4     # drag & drop (Windows/macOS/Linux/Web)
//   super_clipboard: ^0.8.4  # paste an image from the system clipboard
//
// Both degrade gracefully: on a platform where a package has no support,
// this widget simply doesn't show that affordance — Browse always works.
//
// USAGE
// ----------------------------------------------------------
//   MediaUploadZone(
//     folder: 'velora/products/images',
//     kind: MediaUploadKind.image,
//     maxFiles: 8,
//     initialItems: existingImageResults, // e.g. when editing a product
//     onChanged: (items) => setState(() => _images = items),
//   )

import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dio/dio.dart' show CancelToken, DioException;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pasteboard/pasteboard.dart';

import '../services/cloudinary/cloudinary_exception.dart';
import '../services/cloudinary/cloudinary_file_picker.dart';
import '../services/cloudinary/cloudinary_media_helper.dart';
import '../services/cloudinary/cloudinary_models.dart';
import '../services/cloudinary/cloudinary_service.dart';
import '../theme/admin_theme.dart';

enum MediaUploadKind { image, video, any }

enum _ItemStatus { uploading, success, failed }

class _UploadItem {
  _UploadItem({required this.localId, required this.file, this.result})
    : status = result != null ? _ItemStatus.success : _ItemStatus.uploading;

  final String localId;
  final XFile file;
  _ItemStatus status;
  double progress = 0;
  String? errorMessage;
  CloudinaryUploadResult? result;
  CancelToken? cancelToken;

  CloudinaryMediaKind get mediaKind =>
      CloudinaryMediaHelper.kindFromExtension(file.name);
}

class MediaUploadZone extends StatefulWidget {
  const MediaUploadZone({
    super.key,
    required this.folder,
    this.kind = MediaUploadKind.image,
    this.multiple = true,
    this.maxFiles = 10,
    this.maxFileBytes,
    this.initialItems = const [],
    this.onChanged,
    this.onUploaded,
    this.onRemoved,
    this.tileSize = 96,
  });

  /// Cloudinary folder new uploads are saved under.
  final String folder;

  /// Which kind of media this zone accepts. Governs the browse dialog's
  /// file-type filter and which upload method is used.
  final MediaUploadKind kind;

  /// Whether more than one file can be added.
  final bool multiple;

  /// Upper bound on how many files this zone will hold at once.
  final int maxFiles;

  /// Optional per-file size cap, enforced before upload starts.
  final int? maxFileBytes;

  /// Already-uploaded media to show when this zone mounts — e.g. the
  /// existing images when editing a product.
  final List<CloudinaryUploadResult> initialItems;

  /// Fires whenever the set of successfully uploaded results changes.
  final ValueChanged<List<CloudinaryUploadResult>>? onChanged;

  /// Fires once per newly-completed upload.
  final ValueChanged<CloudinaryUploadResult>? onUploaded;

  /// Fires when a previously-uploaded item is removed from the zone.
  final ValueChanged<CloudinaryUploadResult>? onRemoved;

  final double tileSize;

  @override
  State<MediaUploadZone> createState() => _MediaUploadZoneState();
}

class _MediaUploadZoneState extends State<MediaUploadZone> {
  late final CloudinaryService _service;
  final List<_UploadItem> _items = [];
  bool _dragging = false;
  int _localIdSeed = 0;

  bool get _dragDropSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  @override
  void initState() {
    super.initState();
    _service = Get.find<CloudinaryService>();
    for (final result in widget.initialItems) {
      _items.add(
        _UploadItem(
          localId: _nextLocalId(),
          file: result.sourceFile,
          result: result,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.cancelToken?.cancel('Widget disposed.');
    }
    super.dispose();
  }

  String _nextLocalId() => 'upload_${_localIdSeed++}';

  int get _remainingSlots => widget.maxFiles - _items.length;

  List<CloudinaryUploadResult> get _successfulResults => _items
      .where((i) => i.status == _ItemStatus.success && i.result != null)
      .map((i) => i.result!)
      .toList(growable: false);

  void _notifyChanged() => widget.onChanged?.call(_successfulResults);

  // ==========================================================
  // ADDING FILES (shared entry point for drop / paste / browse)
  // ==========================================================

  Future<void> _addFiles(List<XFile> files) async {
    if (files.isEmpty) return;

    final allowedKind = switch (widget.kind) {
      MediaUploadKind.image => CloudinaryMediaKind.image,
      MediaUploadKind.video => CloudinaryMediaKind.video,
      MediaUploadKind.any => null,
    };

    var accepted = files;
    if (allowedKind != null) {
      accepted = files
          .where(
            (f) =>
                CloudinaryMediaHelper.kindFromExtension(f.name) == allowedKind,
          )
          .toList();
    }

    if (!widget.multiple) {
      accepted = accepted.take(1).toList();
      // Replace whatever is already here for a single-file zone.
      for (final existing in List<_UploadItem>.from(_items)) {
        _removeItem(existing, silent: true);
      }
    }

    if (accepted.length > _remainingSlots) {
      accepted = accepted
          .take(_remainingSlots.clamp(0, accepted.length))
          .toList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Only ${widget.maxFiles} files are allowed here.'),
          ),
        );
      }
    }

    for (final file in accepted) {
      final item = _UploadItem(localId: _nextLocalId(), file: file);
      setState(() => _items.add(item));
      _startUpload(item);
    }
  }

  Future<void> _startUpload(_UploadItem item) async {
    final kind = item.mediaKind;
    final cancelToken = CancelToken();
    item.cancelToken = cancelToken;

    try {
      if (widget.maxFileBytes != null) {
        await CloudinaryMediaHelper.validateSize(
          item.file,
          maxBytes: widget.maxFileBytes,
        );
      }

      final result = await switch (kind) {
        CloudinaryMediaKind.video => _service.uploadVideo(
          item.file,
          options: CloudinaryUploadOptions(
            folder: widget.folder,
            maxBytes: widget.maxFileBytes ?? 500 * 1024 * 1024,
            compressImage: false,
          ),
          onSendProgress: (sent, total) => _updateProgress(item, sent, total),
          cancelToken: cancelToken,
        ),
        CloudinaryMediaKind.image => _service.uploadImage(
          item.file,
          options: CloudinaryUploadOptions(
            folder: widget.folder,
            maxBytes: widget.maxFileBytes ?? 15 * 1024 * 1024,
          ),
          onSendProgress: (sent, total) => _updateProgress(item, sent, total),
          cancelToken: cancelToken,
        ),
        CloudinaryMediaKind.model3d => _service.upload3dModel(
          item.file,
          options: CloudinaryUploadOptions(
            folder: widget.folder,
            maxBytes: widget.maxFileBytes ?? 100 * 1024 * 1024,
            compressImage: false,
          ),
          onSendProgress: (sent, total) => _updateProgress(item, sent, total),
          cancelToken: cancelToken,
        ),
        CloudinaryMediaKind.file => _service.upload(
          item.file,
          kind: CloudinaryMediaKind.file,
          options: CloudinaryUploadOptions(
            folder: widget.folder,
            maxBytes: widget.maxFileBytes ?? 50 * 1024 * 1024,
            compressImage: false,
          ),
          onSendProgress: (sent, total) => _updateProgress(item, sent, total),
          cancelToken: cancelToken,
        ),
      };

      if (!mounted) return;
      setState(() {
        item.status = _ItemStatus.success;
        item.result = result;
        item.progress = 1;
      });
      widget.onUploaded?.call(result);
      _notifyChanged();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        item.status = _ItemStatus.failed;
        item.errorMessage = _messageFor(error);
      });
    }
  }

  void _updateProgress(_UploadItem item, int sent, int total) {
    if (!mounted || total <= 0) return;
    setState(() => item.progress = (sent / total).clamp(0.0, 1.0));
  }

  String _messageFor(Object error) {
    if (error is CloudinaryException) return error.message;
    if (error is DioException && CancelToken.isCancel(error)) {
      return 'Upload cancelled.';
    }
    return 'Upload failed. Please try again.';
  }

  void _retry(_UploadItem item) {
    setState(() {
      item.status = _ItemStatus.uploading;
      item.progress = 0;
      item.errorMessage = null;
    });
    _startUpload(item);
  }

  void _removeItem(_UploadItem item, {bool silent = false}) {
    item.cancelToken?.cancel('Removed by user.');
    setState(() => _items.remove(item));
    if (!silent && item.result != null) {
      widget.onRemoved?.call(item.result!);
      _notifyChanged();
    }
  }

  // ==========================================================
  // BROWSE
  // ==========================================================

  Future<void> _browse() async {
    switch (widget.kind) {
      case MediaUploadKind.image:
        final files = await CloudinaryFilePicker.pickImages(
          multiple: widget.multiple,
        );
        await _addFiles(files);
      case MediaUploadKind.video:
        final file = await CloudinaryFilePicker.pickVideo();
        if (file != null) await _addFiles([file]);
      case MediaUploadKind.any:
        final files = await CloudinaryFilePicker.pickAnyFiles(
          multiple: widget.multiple,
        );
        await _addFiles(files);
    }
  }

  // ==========================================================
  // CLIPBOARD PASTE
  // ==========================================================

  Future<void> _pasteFromClipboard() async {
    if (widget.kind == MediaUploadKind.video) return; // rarely usefuls

    final bytes = await Pasteboard.image;

    if (bytes != null && bytes.isNotEmpty) {
      final xfile = XFile.fromData(
        bytes,
        name: 'pasted_${DateTime.now().millisecondsSinceEpoch}.png',
        mimeType: 'image/png',
      );
      await _addFiles([xfile]);
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image found on the clipboard.')),
      );
    }
  }
  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final canAddMore = _remainingSlots > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (canAddMore) _buildDropzone(),
        if (_items.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [for (final item in _items) _buildTile(item)],
          ),
        ],
      ],
    );
  }

  Widget _buildDropzone() {
    final zone = Focus(
      onKeyEvent: (node, event) {
        final isPasteShortcut =
            event is KeyDownEvent &&
            (HardwareKeyboard.instance.isMetaPressed ||
                HardwareKeyboard.instance.isControlPressed) &&
            event.logicalKey == LogicalKeyboardKey.keyV;
        if (isPasteShortcut) {
          _pasteFromClipboard();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: InkWell(
        onTap: _browse,
        borderRadius: BorderRadius.circular(14),
        child: DottedBorderBox(
          highlighted: _dragging,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _dragging
                      ? Icons.file_download_outlined
                      : Icons.cloud_upload_outlined,
                  size: 28,
                  color: _dragging ? AdminColors.brassDark : AdminColors.muted,
                ),
                const SizedBox(height: 8),
                Text(
                  _dragging ? 'Drop to upload' : _hintText(),
                  textAlign: TextAlign.center,
                  style: AdminText.body(
                    12.5,
                    weight: FontWeight.w600,
                    color: AdminColors.inkSoft,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_items.length}/${widget.maxFiles} added',
                  style: AdminText.body(11, color: AdminColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!_dragDropSupported) return zone;

    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (details) {
        setState(() => _dragging = false);
        _addFiles(details.files);
      },
      child: zone,
    );
  }

  String _hintText() {
    final action = _dragDropSupported
        ? 'Drag & drop, paste (Ctrl/Cmd+V), or '
        : 'Paste (Ctrl/Cmd+V) or ';
    return '$action tap to browse';
  }

  Widget _buildTile(_UploadItem item) {
    final size = widget.tileSize;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: size,
              height: size,
              child: _buildTileContent(item),
            ),
          ),

          if (item.status == _ItemStatus.uploading)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: item.progress > 0 ? item.progress : null,
                          strokeWidth: 2.5,
                          color: Colors.white,
                          backgroundColor: Colors.white24,
                        ),
                        Text(
                          '${(item.progress * 100).round()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (item.status == _ItemStatus.failed)
            Positioned.fill(
              child: Tooltip(
                message: item.errorMessage ?? 'Upload failed',
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AdminColors.dangerTint,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AdminColors.danger),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _retry(item),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: AdminColors.danger,
                            size: 20,
                          ),
                          SizedBox(height: 3),
                          Icon(
                            Icons.refresh_rounded,
                            color: AdminColors.danger,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (item.status == _ItemStatus.success)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AdminColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),

          Positioned(
            top: -6,
            left: size - 14,
            child: InkWell(
              onTap: () => _removeItem(item),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileContent(_UploadItem item) {
    final kind = item.mediaKind;

    // Success — render through Cloudinary's delivery transformation
    // (f_auto,q_auto), never the raw uploaded bytes.
    if (item.status == _ItemStatus.success && item.result != null) {
      final result = item.result!;

      if (kind == CloudinaryMediaKind.image) {
        return CachedNetworkImage(
          imageUrl: _service.imageUrl(
            result.publicId,
            width: (widget.tileSize * 2).round(),
            height: (widget.tileSize * 2).round(),
          ),
          fit: BoxFit.cover,
          placeholder: (_, __) => const ColoredBox(color: AdminColors.canvas),
          errorWidget: (_, __, ___) =>
              const _FileFallback(icon: Icons.image_outlined),
        );
      }

      if (kind == CloudinaryMediaKind.video) {
        return Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: _service.videoThumbnailUrl(
                result.publicId,
                width: (widget.tileSize * 2).round(),
                height: (widget.tileSize * 2).round(),
              ),
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  const ColoredBox(color: AdminColors.canvas),
              errorWidget: (_, __, ___) =>
                  const _FileFallback(icon: Icons.videocam_outlined),
            ),
            const ColoredBox(color: Colors.transparent),
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        );
      }

      return _FileFallback(
        icon: Icons.insert_drive_file_outlined,
        label: item.file.name,
      );
    }

    // Still uploading or failed — show a lightweight local preview so the
    // user recognizes which file this tile is.
    if (kind == CloudinaryMediaKind.image) {
      return FutureBuilder<Uint8List>(
        future: item.file.readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const ColoredBox(color: AdminColors.canvas);
          }
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        },
      );
    }

    return _FileFallback(
      icon: kind == CloudinaryMediaKind.video
          ? Icons.videocam_outlined
          : Icons.insert_drive_file_outlined,
      label: item.file.name,
    );
  }
}

class _FileFallback extends StatelessWidget {
  const _FileFallback({required this.icon, this.label});

  final IconData icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AdminColors.canvas,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: AdminColors.muted),
            if (label != null) ...[
              const SizedBox(height: 3),
              Text(
                label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AdminText.body(9, color: AdminColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A dashed-border container — Flutter has no built-in dashed border, so
/// this paints one with a CustomPainter.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({
    super.key,
    required this.child,
    this.highlighted = false,
  });

  final Widget child;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: highlighted ? AdminColors.brass : AdminColors.line,
        strokeWidth: highlighted ? 1.6 : 1.2,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: highlighted ? AdminColors.brassTint : AdminColors.canvas,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(14),
    );

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
