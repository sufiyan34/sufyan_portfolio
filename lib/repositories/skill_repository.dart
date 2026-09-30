import 'package:sufyan_portfolio/models/skill_model.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

/// Firebase Realtime Database gateway for the `skills/` node.
///
/// Data flow remains: View -> GetX Controller -> Repository -> Service.
class SkillRepository {
  SkillRepository._();
  static final SkillRepository instance = SkillRepository._();

  final _db = RealtimeDbService.instance;
  static const _path = 'skills';

  Future<List<SkillModel>> getAll() async {
    final data = await _db.readCollectionOnce(_path);
    final skills = data.entries
        .map((e) => SkillModel.fromMap(e.key, e.value))
        .toList();
    skills.sort(_sortSkills);
    return skills;
  }

  Future<List<SkillModel>> getPublished() async {
    final skills = await getAll();
    return skills.where((skill) => skill.published).toList();
  }

  Future<SkillModel?> getById(String id) async {
    final data = await _db.readOnce('$_path/$id');
    if (data == null) return null;
    return SkillModel.fromMap(id, data);
  }

  Future<SkillModel> add(SkillModel skill) async {
    final map = skill.toMap();
    map['createdAt'] = _db.serverTimestamp;
    map['updatedAt'] = _db.serverTimestamp;
    final id = await _db.push(_path, map);
    return skill.copyWith(id: id);
  }

  Future<void> update(SkillModel skill) {
    final map = skill.toMap();
    map['updatedAt'] = _db.serverTimestamp;
    return _db.update('$_path/${skill.id}', map);
  }

  Future<void> delete(String id) => _db.remove('$_path/$id');

  static int _sortSkills(SkillModel a, SkillModel b) {
    final order = a.sortOrder.compareTo(b.sortOrder);
    if (order != 0) return order;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
