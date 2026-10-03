import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/contact_content_model.dart';
import 'package:sufyan_portfolio/repositories/contact_repository.dart';
import 'package:sufyan_portfolio/repositories/newsletter_repository.dart';

/// Shared by every [AppFooter]. Registered once as `permanent`, so contact
/// details and social links are fetched a single time and reused on each page
/// instead of hitting Firebase on every navigation.
class FooterController extends GetxController {
  final _contactRepo = ContactRepository.instance;
  final _newsletterRepo = NewsletterRepository.instance;

  final Rx<ContactContentModel> content = ContactContentModel.fallback().obs;

  final RxBool isSubscribing = false.obs;
  final RxString feedback = ''.obs;
  final RxBool feedbackIsError = false.obs;

  static final _emailPattern = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$',
  );

  static final _placeholder = ContactContentModel.fallback();

  @override
  void onInit() {
    super.onInit();
    _loadContent();
  }

  Future<void> _loadContent() async {
    content.value = await _contactRepo.getContent();
  }

  // The contact node falls back to demo values when nothing is saved yet.
  // Those must never be shown in a public footer.
  bool get hasEmail => content.value.email != _placeholder.email;
  bool get hasPhone => content.value.phone != _placeholder.phone;
  bool get hasLocation => content.value.location != _placeholder.location;

  void clearFeedback() {
    if (feedback.value.isNotEmpty) feedback.value = '';
  }

  /// Returns `true` when the address was saved.
  Future<bool> subscribe(String rawEmail) async {
    if (isSubscribing.value) return false;

    final email = rawEmail.trim();
    if (email.isEmpty) {
      _setFeedback('Enter your email address.', error: true);
      return false;
    }
    if (!_emailPattern.hasMatch(email)) {
      _setFeedback('That email doesn’t look right.', error: true);
      return false;
    }

    isSubscribing.value = true;
    feedback.value = '';

    try {
      await _newsletterRepo.subscribe(email);
      _setFeedback('You’re in! Thanks for subscribing.', error: false);
      return true;
    } catch (_) {
      _setFeedback(
        'Couldn’t subscribe right now. Please try again.',
        error: true,
      );
      return false;
    } finally {
      isSubscribing.value = false;
    }
  }

  void _setFeedback(String message, {required bool error}) {
    feedbackIsError.value = error;
    feedback.value = message;
  }
}
