import 'package:sufyan_portfolio/models/about_content_model.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

/// Repository for the public `aboutContent/` Firebase RTDB node.
///
/// It intentionally exposes a small contract now so the future Admin Site
/// Management screen can update the same node without changing the client UI.
class AboutContentRepository {
  AboutContentRepository._();
  static final AboutContentRepository instance = AboutContentRepository._();

  final _db = RealtimeDbService.instance;
  static const _path = 'aboutContent';

  Future<AboutContentModel> getContent() async {
    try {
      final data = await _db.readOnce(_path);
      if (data == null) return AboutContentModel.fallback();
      return AboutContentModel.fromMap(data);
    } catch (_) {
      return AboutContentModel.fallback();
    }
  }

  Future<void> updateContent(AboutContentModel content) {
    final map = content.toMap();
    map['updatedAt'] = _db.serverTimestamp;
    return _db.update(_path, map);
  }
}
