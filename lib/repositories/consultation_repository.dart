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
}
