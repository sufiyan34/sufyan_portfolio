import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/media_asset_model.dart';
import 'package:sufyan_portfolio/repositories/media_repository.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_models.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';

/// Admin controller for the media library (`mediaLibrary/` node).
class MediaManagementController extends GetxController {
  final _repo = MediaRepository.instance;

  /// Folders offered in the upload panel. Stored under `portfolio/<folder>`.
  static const folders = ['general', 'projects', 'site', 'testimonials'];

  final RxList<MediaAssetModel> items = <MediaAssetModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  /// all | image | video | file
  final RxString typeFilter = 'all'.obs;
  final RxString uploadFolder = 'general'.obs;

  String get cloudinaryFolder => 'portfolio/${uploadFolder.value}';

  int get imageCount => items.where((a) => a.isImage).length;
  int get videoCount => items.where((a) => a.isVideo).length;
  int get totalBytes => items.fold(0, (sum, a) => sum + a.bytes);

  List<MediaAssetModel> get filtered {
    final query = searchQuery.value.trim().toLowerCase();
    return items.where((a) {
      final matchesType = switch (typeFilter.value) {
        'image' => a.isImage,
        'video' => a.isVideo,
        'file' => !a.isImage && !a.isVideo,
        _ => true,
      };
      final matchesQuery =
          query.isEmpty ||
          a.name.toLowerCase().contains(query) ||
          a.folder.toLowerCase().contains(query) ||
          a.format.toLowerCase().contains(query);
      return matchesType && matchesQuery;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      items.value = await _repo.getAll();
    } catch (e) {
      adminSnack('Couldn\'t load media', _friendly(e), error: true);
    } finally {
      isLoading.value = false;
    }
  }

  /// Called by the upload zone once Cloudinary has accepted a file.
  Future<void> recordUpload(CloudinaryUploadResult result) async {
    final asset = MediaAssetModel(
      id: '',
      name: (result.originalFilename?.isNotEmpty ?? false)
          ? result.originalFilename!
          : result.sourceFile.name,
      url: result.secureUrl,
      publicId: result.publicId,
      resourceType: result.resourceType,
      format: result.format,
      bytes: result.bytes,
      width: result.width ?? 0,
      height: result.height ?? 0,
      folder: result.assetFolder ?? cloudinaryFolder,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    try {
      await _repo.add(asset);
      await load();
    } catch (e) {
      adminSnack('Uploaded, but not added to the library', _friendly(e), error: true);
    }
  }

  Future<void> delete(MediaAssetModel asset) async {
    try {
      await _repo.delete(asset.id);
      items.removeWhere((a) => a.id == asset.id);
      adminSnack('Removed from library', asset.name);
    } catch (e) {
      adminSnack('Couldn\'t remove item', _friendly(e), error: true);
    }
  }

  Future<void> copyUrl(MediaAssetModel asset) async {
    await Clipboard.setData(ClipboardData(text: asset.url));
    adminSnack('Link copied', asset.name);
  }

  void setSearch(String value) => searchQuery.value = value;
  void setTypeFilter(String value) => typeFilter.value = value;
  void setUploadFolder(String value) => uploadFolder.value = value;

  String _friendly(Object e) =>
      kDebugMode ? e.toString() : 'Please check your connection and try again.';
}
