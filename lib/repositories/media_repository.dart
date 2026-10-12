import 'package:sufyan_portfolio/models/media_asset_model.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

/// Firebase Realtime Database gateway for the `mediaLibrary/` node.
class MediaRepository {
  MediaRepository._();
  static final MediaRepository instance = MediaRepository._();

  final _db = RealtimeDbService.instance;
  static const _path = 'mediaLibrary';

  /// Newest first.
  Future<List<MediaAssetModel>> getAll() async {
    final data = await _db.readCollectionOnce(_path);
    final items = data.entries
        .map((e) => MediaAssetModel.fromMap(e.key, e.value))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<String> add(MediaAssetModel asset) {
    final map = asset.toMap();
    map['createdAt'] = _db.serverTimestamp;
    return _db.push(_path, map);
  }

  /// Removes the library record only. The file itself stays on Cloudinary
  /// (deleting there needs a signed server-side call).
  Future<void> delete(String id) => _db.remove('$_path/$id');
}
