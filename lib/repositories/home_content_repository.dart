import 'package:sufyan_portfolio/models/home_content_model.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

/// Sits between GetX controllers and [RealtimeDbService] for the
/// `homeContent/` node (hero copy + stats), per the View -> Controller ->
/// Repository -> Service flow in FIREBASE_DATA_STRUCTURE.md.
class HomeContentRepository {
  HomeContentRepository._();
  static final HomeContentRepository instance = HomeContentRepository._();

  final _db = RealtimeDbService.instance;

  static const _path = 'homeContent';
  static const _statsPath = 'homeContent/stats';

  /// Public site: one-time read, with fallback copy if the node is empty
  /// or the read fails (offline, rules not yet deployed, etc.).
  Future<HomeContentModel> getHomeContent() async {
    try {
      final data = await _db.readOnce(_path);
      if (data == null) return HomeContentModel.fallback();
      return HomeContentModel.fromMap(data);
    } catch (_) {
      return HomeContentModel.fallback();
    }
  }

  Future<List<HomeStatModel>> getStats() async {
    try {
      final data = await _db.readCollectionOnce(_statsPath);
      if (data.isEmpty) return HomeStatModel.fallback();
      final stats =
          data.entries
              .map((e) => HomeStatModel.fromMap(e.key, e.value))
              .where((s) => s.active)
              .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return stats;
    } catch (_) {
      return HomeStatModel.fallback();
    }
  }

  /// Admin: overwrite the hero copy fields (stats are edited separately,
  /// per stat, since they're a child collection).
  Future<void> updateHomeContent(HomeContentModel content) {
    final map = content.toMap();
    map['updatedAt'] = _db.serverTimestamp;
    return _db.update(_path, map);
  }

  Future<void> upsertStat(HomeStatModel stat) {
    return _db.update('$_statsPath/${stat.id}', stat.toMap());
  }

  Future<void> deleteStat(String id) => _db.remove('$_statsPath/$id');
}
