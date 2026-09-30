import 'package:sufyan_portfolio/models/project_model.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

/// Sits between GetX controllers and [RealtimeDbService] for the
/// `projects/` node, per the View -> Controller -> Repository -> Service
/// flow in FIREBASE_DATA_STRUCTURE.md.
class ProjectRepository {
  ProjectRepository._();
  static final ProjectRepository instance = ProjectRepository._();

  final _db = RealtimeDbService.instance;
  static const _path = 'projects';

  /// Public site: only `published` projects, newest/sortOrder first.
  Future<List<ProjectModel>> getPublished() async {
    final all = await getAll();
    final published = all.where((p) => p.published).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return published;
  }

  /// Admin: every project regardless of published state.
  Future<List<ProjectModel>> getAll() async {
    final data = await _db.readCollectionOnce(_path);
    final projects = data.entries
        .map((e) => ProjectModel.fromMap(e.key, e.value))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return projects;
  }

  Future<ProjectModel?> getById(String id) async {
    final data = await _db.readOnce('$_path/$id');
    if (data == null) return null;
    return ProjectModel.fromMap(id, data);
  }

  /// Creates a new project and returns it with its generated id.
  Future<ProjectModel> add(ProjectModel project) async {
    final map = project.toMap();
    map['createdAt'] = _db.serverTimestamp;
    map['updatedAt'] = _db.serverTimestamp;
    final id = await _db.push(_path, map);
    return project.copyWith(id: id);
  }

  Future<void> update(ProjectModel project) {
    final map = project.toMap();
    map['updatedAt'] = _db.serverTimestamp;
    return _db.update('$_path/${project.id}', map);
  }

  /// Hard delete, per explicit admin action. (FIREBASE_DATA_STRUCTURE.md
  /// recommends soft-delete via `published = false` for routine hiding —
  /// call [update] with `published: false` for that instead; use this for
  /// an actual permanent removal, after a confirmation dialog.)
  Future<void> delete(String id) => _db.remove('$_path/$id');
}
