import 'package:sufyan_portfolio/models/testimonial_model.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

/// Firebase Realtime Database gateway for the `testimonials/` node.
class TestimonialRepository {
  TestimonialRepository._();
  static final TestimonialRepository instance = TestimonialRepository._();

  final _db = RealtimeDbService.instance;
  static const _path = 'testimonials';

  Future<List<TestimonialModel>> getAll() async {
    final data = await _db.readCollectionOnce(_path);
    final items = data.entries
        .map((e) => TestimonialModel.fromMap(e.key, e.value))
        .toList()
      ..sort(_sort);
    return items;
  }

  /// For the public site: only published testimonials.
  Future<List<TestimonialModel>> getPublished() async {
    final all = await getAll();
    return all.where((t) => t.published).toList();
  }

  Future<TestimonialModel> add(TestimonialModel item) async {
    final map = item.toMap();
    map['createdAt'] = _db.serverTimestamp;
    map['updatedAt'] = _db.serverTimestamp;
    final id = await _db.push(_path, map);
    return item.copyWith(id: id);
  }

  Future<void> update(TestimonialModel item) {
    final map = item.toMap();
    map.remove('createdAt');
    map['updatedAt'] = _db.serverTimestamp;
    return _db.update('$_path/${item.id}', map);
  }

  Future<void> setPublished(String id, bool published) {
    return _db.update('$_path/$id', {
      'published': published,
      'updatedAt': _db.serverTimestamp,
    });
  }

  Future<void> delete(String id) => _db.remove('$_path/$id');

  static int _sort(TestimonialModel a, TestimonialModel b) {
    final order = a.sortOrder.compareTo(b.sortOrder);
    if (order != 0) return order;
    return a.clientName.toLowerCase().compareTo(b.clientName.toLowerCase());
  }
}
