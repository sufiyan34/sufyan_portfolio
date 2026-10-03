import 'package:sufyan_portfolio/models/admin_profile_model.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

/// Firebase Realtime Database gateway for the signed-in admin's own
/// `users/{uid}` record.
class AdminProfileRepository {
  AdminProfileRepository._();
  static final AdminProfileRepository instance = AdminProfileRepository._();

  final _db = RealtimeDbService.instance;

  Future<AdminProfileModel> getProfile({
    required String uid,
    String fallbackEmail = '',
    String fallbackName = '',
  }) async {
    final data = await _db.readOnce('users/$uid');
    if (data == null) {
      return AdminProfileModel.empty(
        uid: uid,
        email: fallbackEmail,
        displayName: fallbackName,
      );
    }
    return AdminProfileModel.fromMap(
      uid,
      data,
      fallbackEmail: fallbackEmail,
      fallbackName: fallbackName,
    );
  }

  /// Merges only the editable fields into `users/{uid}`. `role`, `active`,
  /// `email` and `uid` are never touched.
  Future<void> updateProfile(AdminProfileModel profile) {
    final data = profile.toEditableMap();
    data['updatedAt'] = _db.serverTimestamp;
    return _db.update('users/${profile.uid}', data);
  }
}
