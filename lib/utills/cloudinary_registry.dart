import 'package:get/get.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_config.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_service.dart';

/// `MediaUploadZone` calls `Get.find<CloudinaryService>()`, which throws if the
/// service was never registered. Call this before building an upload zone.
///
/// Returns null when `CLOUDINARY_CLOUD_NAME` / `CLOUDINARY_UNSIGNED_PRESET`
/// were not supplied via `--dart-define`, so screens can show a friendly note
/// instead of crashing.
CloudinaryService? ensureCloudinaryService() {
  if (Get.isRegistered<CloudinaryService>()) {
    return Get.find<CloudinaryService>();
  }
  try {
    return Get.put<CloudinaryService>(
      CloudinaryService(config: CloudinaryConfig.fromEnvironment()),
      permanent: true,
    );
  } on CloudinaryConfigException {
    return null;
  }
}
