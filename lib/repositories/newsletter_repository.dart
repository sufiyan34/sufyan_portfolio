import 'package:sufyan_portfolio/services/realtime_db_service.dart';

/// Firebase Realtime Database gateway for the footer newsletter signup.
///
/// Each address is stored once under `subscribers/{encodedEmail}`, so signing
/// up twice just refreshes the same record instead of creating duplicates.
class NewsletterRepository {
  NewsletterRepository._();
  static final NewsletterRepository instance = NewsletterRepository._();

  final _db = RealtimeDbService.instance;
  static const _path = 'subscribers';

  /// Realtime Database keys can't contain `.`, so it is swapped for `,`.
  static String keyFor(String email) =>
      email.trim().toLowerCase().replaceAll('.', ',');

  Future<void> subscribe(String email, {String source = 'footer'}) {
    final clean = email.trim().toLowerCase();
    return _db.set('$_path/${keyFor(clean)}', {
      'email': clean,
      'source': source,
      'status': 'active',
      'createdAt': _db.serverTimestamp,
    });
  }
}
