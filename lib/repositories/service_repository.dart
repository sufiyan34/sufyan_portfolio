import 'package:sufyan_portfolio/models/service_model.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

/// Firebase Realtime Database gateway for the `services/` node.
///
/// Data flow: View -> GetX Controller -> Repository -> RealtimeDbService.
class ServiceRepository {
  ServiceRepository._();
  static final ServiceRepository instance = ServiceRepository._();

  final _db = RealtimeDbService.instance;
  static const _path = 'services';

  Future<List<ServiceModel>> getAll() async {
    final data = await _db.readCollectionOnce(_path);
    final services = data.entries
        .map((entry) => ServiceModel.fromMap(entry.key, entry.value))
        .toList();
    services.sort(_sortServices);
    return services;
  }

  Future<List<ServiceModel>> getPublished() async {
    final all = await getAll();
    return all.where((service) => service.published).toList();
  }

  Future<ServiceModel?> getById(String id) async {
    final data = await _db.readOnce('$_path/$id');
    if (data == null) return null;
    return ServiceModel.fromMap(id, data);
  }

  Future<ServiceModel> add(ServiceModel service) async {
    final map = service.toMap();
    map['createdAt'] = _db.serverTimestamp;
    map['updatedAt'] = _db.serverTimestamp;
    final id = await _db.push(_path, map);
    return service.copyWith(id: id);
  }

  /// Writes a deterministic demo/seed record at the service's existing id.
  /// Running the test-data seeder again updates the same demo records instead
  /// of creating duplicate Firebase push-key records.
  Future<void> seed(ServiceModel service) async {
    final map = service.toMap();
    map['createdAt'] = _db.serverTimestamp;
    map['updatedAt'] = _db.serverTimestamp;
    await _db.set('$_path/${service.id}', map);
  }

  Future<void> update(ServiceModel service) {
    final map = service.toMap();
    map['updatedAt'] = _db.serverTimestamp;
    return _db.update('$_path/${service.id}', map);
  }

  Future<void> delete(String id) => _db.remove('$_path/$id');

  static int _sortServices(ServiceModel a, ServiceModel b) {
    final featured = a.featured == b.featured ? 0 : (a.featured ? -1 : 1);
    if (featured != 0) return featured;

    final order = a.sortOrder.compareTo(b.sortOrder);
    if (order != 0) return order;

    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }
}
