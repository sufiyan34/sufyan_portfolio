import 'dart:math';

import 'package:sufyan_portfolio/models/testimonial_invite_model.dart';
import 'package:sufyan_portfolio/models/testimonial_model.dart';
import 'package:sufyan_portfolio/models/testimonial_submission_model.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

/// Firebase Realtime Database gateway for testimonials:
///
/// * `testimonials/`            public, what the site displays
/// * `testimonialInvites/`      private invite links (key = secret token)
/// * `testimonialSubmissions/`  what clients submitted, awaiting review
class TestimonialRepository {
  TestimonialRepository._();
  static final TestimonialRepository instance = TestimonialRepository._();

  final _db = RealtimeDbService.instance;
  static const _path = 'testimonials';
  static const _invites = 'testimonialInvites';
  static const _submissions = 'testimonialSubmissions';

  // ---------------------------------------------------------------------------
  // PUBLIC TESTIMONIALS
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // INVITES (admin)
  // ---------------------------------------------------------------------------

  Future<TestimonialInviteModel> createInvite({
    String clientName = '',
    String projectName = '',
    int validDays = 30,
  }) async {
    final token = _randomToken(24);
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = now + Duration(days: validDays).inMilliseconds;

    await _db.set('$_invites/$token', {
      'clientName': clientName.trim(),
      'projectName': projectName.trim(),
      'createdAt': now,
      'expiresAt': expiresAt,
      'used': false,
    });

    return TestimonialInviteModel(
      token: token,
      clientName: clientName.trim(),
      projectName: projectName.trim(),
      createdAt: now,
      expiresAt: expiresAt,
      used: false,
      usedAt: 0,
    );
  }

  Future<List<TestimonialInviteModel>> getInvites() async {
    final data = await _db.readCollectionOnce(_invites);
    return data.entries
        .map((e) => TestimonialInviteModel.fromMap(e.key, e.value))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> deleteInvite(String token) => _db.remove('$_invites/$token');

  // ---------------------------------------------------------------------------
  // CLIENT SUBMISSION (public)
  // ---------------------------------------------------------------------------

  /// Reads a single invite by its secret token. Null when it doesn't exist.
  Future<TestimonialInviteModel?> getInvite(String token) async {
    final map = await _db.readOnce('$_invites/$token');
    return map == null ? null : TestimonialInviteModel.fromMap(token, map);
  }

  /// Saves the client's testimonial as `pending` AND marks the invite used in
  /// one atomic write, so a link can only ever be used once.
  Future<void> submitReview({
    required String token,
    required String clientName,
    required String clientRole,
    required String company,
    required String projectName,
    required String quote,
    required int rating,
  }) {
    final id = 'sub_${DateTime.now().millisecondsSinceEpoch}_${_randomToken(6)}';

    return _db.updateMulti({
      '$_submissions/$id': {
        'inviteToken': token,
        'clientName': clientName.trim(),
        'clientRole': clientRole.trim(),
        'company': company.trim(),
        'projectName': projectName.trim(),
        'quote': quote.trim(),
        'rating': rating,
        'consent': true,
        'status': SubmissionStatuses.pending,
        'createdAt': _db.serverTimestamp,
      },
      '$_invites/$token/used': true,
      '$_invites/$token/usedAt': _db.serverTimestamp,
    });
  }

  // ---------------------------------------------------------------------------
  // SUBMISSIONS (admin)
  // ---------------------------------------------------------------------------

  Future<List<TestimonialSubmissionModel>> getSubmissions() async {
    final data = await _db.readCollectionOnce(_submissions);
    return data.entries
        .map((e) => TestimonialSubmissionModel.fromMap(e.key, e.value))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Publishes [testimonial] (the admin's reviewed version) and marks the
  /// submission approved, atomically. Returns the saved testimonial.
  Future<TestimonialModel> approveSubmission(
    TestimonialSubmissionModel submission,
    TestimonialModel testimonial,
  ) async {
    final newId = _db.ref(_path).push().key!;
    final map = testimonial.toMap();
    map['createdAt'] = _db.serverTimestamp;
    map['updatedAt'] = _db.serverTimestamp;

    await _db.updateMulti({
      '$_path/$newId': map,
      '$_submissions/${submission.id}/status': SubmissionStatuses.approved,
      '$_submissions/${submission.id}/testimonialId': newId,
      '$_submissions/${submission.id}/reviewedAt': _db.serverTimestamp,
    });
    return testimonial.copyWith(id: newId);
  }

  Future<void> rejectSubmission(String id) {
    return _db.update('$_submissions/$id', {
      'status': SubmissionStatuses.rejected,
      'reviewedAt': _db.serverTimestamp,
    });
  }

  Future<void> deleteSubmission(String id) => _db.remove('$_submissions/$id');

  // ---------------------------------------------------------------------------

  static String _randomToken(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static int _sort(TestimonialModel a, TestimonialModel b) {
    final order = a.sortOrder.compareTo(b.sortOrder);
    if (order != 0) return order;
    return a.clientName.toLowerCase().compareTo(b.clientName.toLowerCase());
  }
}
