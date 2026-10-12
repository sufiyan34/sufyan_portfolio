import 'package:sufyan_portfolio/models/contact_content_model.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

class ContactRepository {
  ContactRepository._();
  static final ContactRepository instance = ContactRepository._();

  final _db = RealtimeDbService.instance;
  static const _contentPath = 'contactContent';
  static const _messagesPath = 'contactMessages';

  Future<ContactContentModel> getContent() async {
    try {
      final data = await _db.readOnce(_contentPath);
      if (data == null) return ContactContentModel.fallback();
      return ContactContentModel.fromMap(data);
    } catch (_) {
      return ContactContentModel.fallback();
    }
  }

  Future<String> sendMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    final now = _db.serverTimestamp;
    return _db.push(_messagesPath, {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'subject': subject.trim(),
      'message': message.trim(),
      'status': 'new',
      'source': 'public_contact_form',
      'createdAt': now,
      'updatedAt': now,
    });
  }

  // ---------------------------------------------------------------------------
  // ADMIN
  // ---------------------------------------------------------------------------

  /// Admin: save the public Contact page / footer details.
  Future<void> saveContent(ContactContentModel content) {
    return _db.update(_contentPath, {
      ...content.toMap(),
      'updatedAt': _db.serverTimestamp,
    });
  }

  /// Admin: all inbox messages, newest first.
  Future<List<ContactMessageModel>> getMessages() async {
    final data = await _db.readCollectionOnce(_messagesPath);
    final items = data.entries
        .map((e) => ContactMessageModel.fromMap(e.key, e.value))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> updateMessageStatus(String id, String status) {
    return _db.update('$_messagesPath/$id', {
      'status': ContactMessageStatuses.normalize(status),
      'updatedAt': _db.serverTimestamp,
    });
  }

  Future<void> deleteMessage(String id) => _db.remove('$_messagesPath/$id');
}
