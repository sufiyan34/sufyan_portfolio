/// Paste your Cloudinary values here if you don't want to pass
/// `--dart-define` flags on every run. A `--dart-define` value always wins.
///
///  - cloud name: Cloudinary dashboard → top-left (e.g. `dxyz123abc`)
///  - unsigned preset: Settings → Upload → Upload presets → add preset with
///    "Signing mode: Unsigned" (e.g. `portfolio_unsigned`)
const String kCloudinaryCloudName = 'dxi3umqzq';
const String kCloudinaryUnsignedPreset = 'sufyan_portfolio';

class CloudinaryConfig {
  final String cloudName;
  final String unsignedUploadPreset;
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  const CloudinaryConfig({
    required this.cloudName,
    required this.unsignedUploadPreset,
    this.apiBaseUrl = 'https://api.cloudinary.com/v1_1',
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(minutes: 5),
    this.sendTimeout = const Duration(minutes: 10),
  });

  factory CloudinaryConfig.fromEnvironment() {
    const envCloudName = String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
    const envPreset = String.fromEnvironment('CLOUDINARY_UNSIGNED_PRESET');
    const cloudName = envCloudName != '' ? envCloudName : kCloudinaryCloudName;
    const preset = envPreset != '' ? envPreset : kCloudinaryUnsignedPreset;

    if (cloudName.isEmpty || preset.isEmpty) {
      throw const CloudinaryConfigException(
        'Cloudinary configuration is missing. Supply '
        'CLOUDINARY_CLOUD_NAME and CLOUDINARY_UNSIGNED_PRESET.',
      );
    }

    return const CloudinaryConfig(
      cloudName: cloudName,
      unsignedUploadPreset: preset,
    );
  }

  Uri uploadUri(String resourceType) {
    return Uri.parse('$apiBaseUrl/$cloudName/$resourceType/upload');
  }
}

class CloudinaryConfigException implements Exception {
  final String message;

  const CloudinaryConfigException(this.message);

  @override
  String toString() => 'CloudinaryConfigException($message)';
}
