/// Mirrors `mediaLibrary/{assetId}` in Firebase Realtime Database.
///
/// Cloudinary's unsigned upload preset cannot list or delete assets from the
/// browser, so every upload made through the admin Media screen is recorded
/// here. That record is what the library grid is built from.
class MediaAssetModel {
  final String id;
  final String name;
  final String url;
  final String publicId;

  /// `image`, `video` or `raw` (Cloudinary's resource_type).
  final String resourceType;
  final String format;
  final int bytes;
  final int width;
  final int height;
  final String folder;
  final int createdAt;

  const MediaAssetModel({
    required this.id,
    required this.name,
    required this.url,
    required this.publicId,
    required this.resourceType,
    required this.format,
    required this.bytes,
    required this.width,
    required this.height,
    required this.folder,
    required this.createdAt,
  });

  bool get isImage => resourceType == 'image';
  bool get isVideo => resourceType == 'video';

  factory MediaAssetModel.fromMap(String id, Map<dynamic, dynamic> map) {
    int toInt(dynamic v) => v is num ? v.round() : 0;
    return MediaAssetModel(
      id: id,
      name: map['name']?.toString() ?? '',
      url: map['url']?.toString() ?? '',
      publicId: map['publicId']?.toString() ?? '',
      resourceType: map['resourceType']?.toString() ?? 'image',
      format: map['format']?.toString() ?? '',
      bytes: toInt(map['bytes']),
      width: toInt(map['width']),
      height: toInt(map['height']),
      folder: map['folder']?.toString() ?? '',
      createdAt: toInt(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'url': url,
    'publicId': publicId,
    'resourceType': resourceType,
    'format': format,
    'bytes': bytes,
    'width': width,
    'height': height,
    'folder': folder,
    'createdAt': createdAt,
  };
}
