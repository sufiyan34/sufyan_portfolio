import 'package:sufyan_portfolio/models/package_model.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

/// Firebase Realtime Database gateway for the `packages/` node.
class PackageRepository {
  PackageRepository._();
  static final PackageRepository instance = PackageRepository._();

  final _db = RealtimeDbService.instance;
  static const _path = 'packages';

  Future<List<PackageModel>> getAll() async {
    final data = await _db.readCollectionOnce(_path);
    final packages = data.entries
        .map((entry) => PackageModel.fromMap(entry.key, entry.value))
        .toList();
    packages.sort(_sortPackages);
    return packages;
  }

  Future<List<PackageModel>> getPublished() async {
    final all = await getAll();
    return all.where((package) => package.published).toList();
  }

  Future<PackageModel?> getById(String id) async {
    final data = await _db.readOnce('$_path/$id');
    if (data == null) return null;
    return PackageModel.fromMap(id, data);
  }

  /// Writes a deterministic demo/seed record at the package's existing id.
  /// Unlike [add], this does not generate a random Firebase push key, so the
  /// test-data page can be safely run again without creating duplicates.
  Future<void> seed(PackageModel package) async {
    final map = package.toMap();
    map['createdAt'] = _db.serverTimestamp;
    map['updatedAt'] = _db.serverTimestamp;
    await _db.set('$_path/${package.id}', map);
  }

  Future<PackageModel> add(PackageModel package) async {
    final map = package.toMap();
    map['createdAt'] = _db.serverTimestamp;
    map['updatedAt'] = _db.serverTimestamp;
    final id = await _db.push(_path, map);
    return package.copyWith(id: id);
  }

  Future<void> update(PackageModel package) {
    final map = package.toMap();
    map['updatedAt'] = _db.serverTimestamp;
    map.remove('createdAt');
    return _db.update('$_path/${package.id}', map);
  }

  Future<void> delete(String id) => _db.remove('$_path/$id');

  static int _sortPackages(PackageModel a, PackageModel b) {
    final featured = a.featured == b.featured ? 0 : (a.featured ? -1 : 1);
    if (featured != 0) return featured;

    final order = a.sortOrder.compareTo(b.sortOrder);
    if (order != 0) return order;

    final typeOrder = _typeRank(a.type).compareTo(_typeRank(b.type));
    if (typeOrder != 0) return typeOrder;

    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  static int _typeRank(String type) {
    switch (PackageTypes.normalize(type)) {
      case PackageTypes.silver:
        return 0;
      case PackageTypes.gold:
        return 1;
      case PackageTypes.platinum:
        return 2;
      case PackageTypes.custom:
      default:
        return 3;
    }
  }
}
