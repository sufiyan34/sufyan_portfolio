import 'package:sufyan_portfolio/models/experience_model.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

/// Firebase Realtime Database gateway for the `experiences/` node.
///
/// Data flow remains:
/// View -> GetX Controller -> Repository -> RealtimeDbService.
class ExperienceRepository {
  ExperienceRepository._();
  static final ExperienceRepository instance = ExperienceRepository._();

  final _db = RealtimeDbService.instance;
  static const _path = 'experiences';

  Future<List<ExperienceModel>> getAll() async {
    final data = await _db.readCollectionOnce(_path);
    final experiences = data.entries
        .map((entry) => ExperienceModel.fromMap(entry.key, entry.value))
        .toList();
    experiences.sort(_sortExperiences);
    return experiences;
  }

  Future<List<ExperienceModel>> getPublished() async {
    final all = await getAll();
    return all.where((experience) => experience.published).toList();
  }

  Future<ExperienceModel?> getById(String id) async {
    final data = await _db.readOnce('$_path/$id');
    if (data == null) return null;
    return ExperienceModel.fromMap(id, data);
  }

  Future<ExperienceModel> add(ExperienceModel experience) async {
    final map = experience.toMap();
    map['createdAt'] = _db.serverTimestamp;
    map['updatedAt'] = _db.serverTimestamp;
    final id = await _db.push(_path, map);
    return experience.copyWith(id: id);
  }

  /// Writes a deterministic demo/seed record at the experience's existing id.
  /// Re-running the developer seed updates the same record instead of creating duplicates.
  Future<void> seed(ExperienceModel experience) async {
    final map = experience.toMap();
    map['createdAt'] = _db.serverTimestamp;
    map['updatedAt'] = _db.serverTimestamp;
    await _db.set('$_path/${experience.id}', map);
  }

  Future<void> update(ExperienceModel experience) {
    final map = experience.toMap();
    map['updatedAt'] = _db.serverTimestamp;
    return _db.update('$_path/${experience.id}', map);
  }

  Future<void> delete(String id) => _db.remove('$_path/$id');

  static int _sortExperiences(ExperienceModel a, ExperienceModel b) {
    final order = a.sortOrder.compareTo(b.sortOrder);
    if (order != 0) return order;

    if (a.isCurrent != b.isCurrent) {
      return a.isCurrent ? -1 : 1;
    }

    return a.role.toLowerCase().compareTo(b.role.toLowerCase());
  }
}
