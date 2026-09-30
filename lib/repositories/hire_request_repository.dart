import 'package:sufyan_portfolio/models/hire_request_model.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

/// Firebase Realtime Database gateway for `hireRequests/`.
class HireRequestRepository {
  HireRequestRepository._();
  static final HireRequestRepository instance = HireRequestRepository._();

  final _db = RealtimeDbService.instance;
  static const _path = 'hireRequests';

  Future<List<HireRequestModel>> getAll() async {
    final data = await _db.readCollectionOnce(_path);
    final requests = data.entries
        .map((entry) => HireRequestModel.fromMap(entry.key, entry.value))
        .toList();

    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return requests;
  }

  Future<HireRequestModel?> getById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;

    final data = await _db.readOnce('$_path/$normalizedId');
    if (data == null) return null;

    return HireRequestModel.fromMap(normalizedId, data);
  }

  Future<String> create(HireRequestModel request) async {
    final data = request.toMap();
    data['status'] = HireRequestStatuses.newRequest;
    data['priority'] = HireRequestPriorities.normal;
    data['createdAt'] = _db.serverTimestamp;
    data['updatedAt'] = _db.serverTimestamp;
    data['respondedAt'] = 0;
    data['offerSentAt'] = 0;

    return _db.push(_path, data);
  }

  Future<void> updateResponse({
    required String id,
    required String replyMessage,
    required String adminNotes,
    required double offerAmount,
    required String offerCurrency,
    required int offerDeliveryDays,
    required String offerMessage,
    required bool offerSent,
    required String status,
  }) {
    final data = <String, dynamic>{
      'replyMessage': replyMessage.trim(),
      'adminNotes': adminNotes.trim(),
      'offerAmount': offerAmount,
      'offerCurrency': offerCurrency.trim().isEmpty ? 'PKR' : offerCurrency.trim().toUpperCase(),
      'offerDeliveryDays': offerDeliveryDays,
      'offerMessage': offerMessage.trim(),
      'status': HireRequestStatuses.normalize(status),
      'updatedAt': _db.serverTimestamp,
      'respondedAt': _db.serverTimestamp,
    };

    if (offerSent) {
      data['offerSentAt'] = _db.serverTimestamp;
    }

    return _db.update('$_path/$id', data);
  }

  Future<void> updateStatus({
    required String id,
    required String status,
  }) {
    return _db.update('$_path/$id', {
      'status': HireRequestStatuses.normalize(status),
      'updatedAt': _db.serverTimestamp,
    });
  }
}
