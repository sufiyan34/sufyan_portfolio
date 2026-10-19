import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/models/testimonial_invite_model.dart';
import 'package:sufyan_portfolio/models/testimonial_model.dart';
import 'package:sufyan_portfolio/models/testimonial_submission_model.dart';
import 'package:sufyan_portfolio/repositories/testimonial_repository.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';

/// Admin controller for testimonials: the public list, client submissions
/// waiting for review, and the private invite links.
class TestimonialManagementController extends GetxController {
  final _repo = TestimonialRepository.instance;

  final RxList<TestimonialModel> items = <TestimonialModel>[].obs;
  final RxList<TestimonialSubmissionModel> submissions =
      <TestimonialSubmissionModel>[].obs;
  final RxList<TestimonialInviteModel> invites = <TestimonialInviteModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;

  /// testimonials | submissions | invites
  final RxString view = 'testimonials'.obs;

  /// all | published | hidden | featured  (testimonials view)
  final RxString filter = 'all'.obs;

  /// pending | approved | rejected | all  (submissions view)
  final RxString submissionFilter = 'pending'.obs;

  // --------------------------- derived values --------------------------------

  int get publishedCount => items.where((t) => t.published).length;
  int get featuredCount => items.where((t) => t.featured).length;
  int get pendingCount => submissions.where((s) => s.isPending).length;
  int get activeInviteCount => invites.where((i) => i.status == 'active').length;

  String get averageRating {
    if (items.isEmpty) return '–';
    final avg = items.fold<int>(0, (sum, t) => sum + t.rating) / items.length;
    return avg.toStringAsFixed(1);
  }

  List<TestimonialModel> get filtered {
    final query = searchQuery.value.trim().toLowerCase();
    return items.where((t) {
      final matchesFilter = switch (filter.value) {
        'published' => t.published,
        'hidden' => !t.published,
        'featured' => t.featured,
        _ => true,
      };
      final matchesQuery =
          query.isEmpty ||
          t.clientName.toLowerCase().contains(query) ||
          t.company.toLowerCase().contains(query) ||
          t.projectName.toLowerCase().contains(query) ||
          t.quote.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  List<TestimonialSubmissionModel> get filteredSubmissions {
    final status = submissionFilter.value;
    return submissions
        .where((s) => status == 'all' || s.status == status)
        .toList();
  }

  // ------------------------------- loading -----------------------------------

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      items.value = await _repo.getAll();
    } catch (e) {
      adminSnack('Couldn\'t load testimonials', _friendly(e), error: true);
    }

    // Submissions / invites are loaded separately so a problem with one of
    // them never hides the main list.
    try {
      submissions.value = await _repo.getSubmissions();
    } catch (e) {
      adminSnack('Couldn\'t load submissions', _friendly(e), error: true);
    }
    try {
      invites.value = await _repo.getInvites();
    } catch (e) {
      adminSnack('Couldn\'t load invites', _friendly(e), error: true);
    }
    isLoading.value = false;
  }

  // ------------------------- public testimonials -----------------------------

  Future<bool> save(TestimonialModel draft) async {
    isSaving.value = true;
    try {
      if (draft.id.isEmpty) {
        items.add(await _repo.add(draft));
      } else {
        await _repo.update(draft);
        final index = items.indexWhere((t) => t.id == draft.id);
        if (index != -1) items[index] = draft;
      }
      items.sort(_sort);
      items.refresh();
      adminSnack(
        draft.id.isEmpty ? 'Testimonial added' : 'Testimonial updated',
        draft.clientName,
      );
      return true;
    } catch (e) {
      adminSnack('Couldn\'t save testimonial', _friendly(e), error: true);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> togglePublished(TestimonialModel item) async {
    final next = !item.published;
    try {
      await _repo.setPublished(item.id, next);
      final index = items.indexWhere((t) => t.id == item.id);
      if (index != -1) items[index] = item.copyWith(published: next);
      adminSnack(next ? 'Published' : 'Hidden from site', item.clientName);
    } catch (e) {
      adminSnack('Couldn\'t update visibility', _friendly(e), error: true);
    }
  }

  Future<void> delete(TestimonialModel item) async {
    try {
      await _repo.delete(item.id);
      items.removeWhere((t) => t.id == item.id);
      adminSnack('Testimonial deleted', item.clientName);
    } catch (e) {
      adminSnack('Couldn\'t delete testimonial', _friendly(e), error: true);
    }
  }

  // ------------------------------ submissions --------------------------------

  /// Publishes the reviewed [draft] and marks [submission] approved.
  Future<bool> approve(
    TestimonialSubmissionModel submission,
    TestimonialModel draft,
  ) async {
    isSaving.value = true;
    try {
      final saved = await _repo.approveSubmission(submission, draft);
      items.add(saved);
      items.sort(_sort);
      final index = submissions.indexWhere((s) => s.id == submission.id);
      if (index != -1) {
        submissions[index] = submission.copyWith(
          status: SubmissionStatuses.approved,
          testimonialId: saved.id,
        );
      }
      adminSnack(
        draft.published ? 'Approved and published' : 'Approved (hidden)',
        submission.clientName,
      );
      return true;
    } catch (e) {
      adminSnack('Couldn\'t approve', _friendly(e), error: true);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> reject(TestimonialSubmissionModel submission) async {
    try {
      await _repo.rejectSubmission(submission.id);
      final index = submissions.indexWhere((s) => s.id == submission.id);
      if (index != -1) {
        submissions[index] = submission.copyWith(
          status: SubmissionStatuses.rejected,
        );
      }
      adminSnack('Submission rejected', submission.clientName);
    } catch (e) {
      adminSnack('Couldn\'t reject', _friendly(e), error: true);
    }
  }

  Future<void> deleteSubmission(TestimonialSubmissionModel submission) async {
    try {
      await _repo.deleteSubmission(submission.id);
      submissions.removeWhere((s) => s.id == submission.id);
      adminSnack('Submission deleted', submission.clientName);
    } catch (e) {
      adminSnack('Couldn\'t delete submission', _friendly(e), error: true);
    }
  }

  // -------------------------------- invites ----------------------------------

  Future<TestimonialInviteModel?> createInvite({
    String clientName = '',
    String projectName = '',
    int validDays = 30,
  }) async {
    try {
      final invite = await _repo.createInvite(
        clientName: clientName,
        projectName: projectName,
        validDays: validDays,
      );
      invites.insert(0, invite);
      return invite;
    } catch (e) {
      adminSnack('Couldn\'t create invite', _friendly(e), error: true);
      return null;
    }
  }

  Future<void> deleteInvite(TestimonialInviteModel invite) async {
    try {
      await _repo.deleteInvite(invite.token);
      invites.removeWhere((i) => i.token == invite.token);
      adminSnack('Invite link revoked', 'It will no longer work.');
    } catch (e) {
      adminSnack('Couldn\'t revoke invite', _friendly(e), error: true);
    }
  }

  /// Full private link for [token], on whatever domain the admin is using.
  String inviteLink(String token) =>
      '${Uri.base.origin}${AppRoutes.leaveReview}?t=$token';

  /// Ready-to-send message containing the link.
  String inviteMessage(TestimonialInviteModel invite) {
    final name = invite.clientName.trim();
    final project = invite.projectName.trim();
    return 'Hi${name.isEmpty ? '' : ' $name'},\n\n'
        'Thank you for the chance to work together${project.isEmpty ? '' : ' on $project'}. '
        'If you have a couple of minutes, I\'d really value a few honest words about the experience. '
        'You can leave them here (a private link, it only works once):\n\n'
        '${inviteLink(invite.token)}\n\n'
        'Thanks again!\nSufyan';
  }

  // -------------------------------- misc -------------------------------------

  void setSearch(String value) => searchQuery.value = value;
  void setFilter(String value) => filter.value = value;
  void setSubmissionFilter(String value) => submissionFilter.value = value;
  void setView(String value) => view.value = value;

  static int _sort(TestimonialModel a, TestimonialModel b) {
    final order = a.sortOrder.compareTo(b.sortOrder);
    if (order != 0) return order;
    return a.clientName.toLowerCase().compareTo(b.clientName.toLowerCase());
  }

  String _friendly(Object e) =>
      kDebugMode ? e.toString() : 'Please check your connection and try again.';
}
