import 'package:sufyan_portfolio/models/consultation_request_model.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

/// Firebase Realtime Database gateway for `consultations/`.
class ConsultationRepository {
  ConsultationRepository._();
  static final ConsultationRepository instance = ConsultationRepository._();

  final _db = RealtimeDbService.instance;
  static const _path = 'consultations';

  /// Creates a new consultation request and returns its generated key.
  Future<String> create(ConsultationRequestModel request) {
    final data = request.toMap();
    data['status'] = 'new';
    data['createdAt'] = _db.serverTimestamp;
    data['updatedAt'] = _db.serverTimestamp;
    return _db.push(_path, data);
  }

  // ---------------------------------------------------------------------------
  // ADMIN
  // ---------------------------------------------------------------------------

  /// Newest first.
  Future<List<ConsultationRequestModel>> getAll() async {
    final data = await _db.readCollectionOnce(_path);
    final items = data.entries
        .map((e) => ConsultationRequestModel.fromMap(e.key, e.value))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> updateStatus(String id, String status) {
    return _db.update('$_path/$id', {
      'status': ConsultationStatuses.normalize(status),
      'updatedAt': _db.serverTimestamp,
    });
  }

  Future<void> updateAdminNotes(String id, String notes) {
    return _db.update('$_path/$id', {
      'adminNotes': notes.trim(),
      'updatedAt': _db.serverTimestamp,
    });
  }

  Future<void> delete(String id) => _db.remove('$_path/$id');
}
