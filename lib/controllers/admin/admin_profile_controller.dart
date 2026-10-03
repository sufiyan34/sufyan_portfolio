import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/models/admin_profile_model.dart';
import 'package:sufyan_portfolio/repositories/admin_profile_repository.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_config.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_exception.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_file_picker.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_models.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_service.dart';
import 'package:sufyan_portfolio/services/firebase_auth_service.dart';

class AdminProfileController extends GetxController {
  final _auth = FirebaseAuthService.instance;
  final _repo = AdminProfileRepository.instance;

  static const avatarFolder = 'portfolio/admin/avatars';
  static const maxAvatarBytes = 5 * 1024 * 1024;

  // ---- profile form ---------------------------------------------------------
  final profileFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final jobTitleController = TextEditingController();
  final phoneController = TextEditingController();

  // ---- password form --------------------------------------------------------
  final passwordFormKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ---- state ----------------------------------------------------------------
  final Rxn<AdminProfileModel> profile = Rxn<AdminProfileModel>();
  final RxBool isLoading = true.obs;
  final RxString loadError = ''.obs;

  final RxBool isSavingProfile = false.obs;
  final RxBool isUploadingPhoto = false.obs;
  final RxString profileError = ''.obs;

  final RxBool isChangingPassword = false.obs;
  final RxBool isSendingReset = false.obs;
  final RxString passwordError = ''.obs;

  final RxBool obscureCurrent = true.obs;
  final RxBool obscureNew = true.obs;
  final RxBool obscureConfirm = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  // ---------------------------------------------------------------------------
  // LOAD
  // ---------------------------------------------------------------------------

  Future<void> load() async {
    isLoading.value = true;
    loadError.value = '';

    final user = _auth.currentUser;
    if (user == null) {
      loadError.value = 'Your session has expired. Please sign in again.';
      isLoading.value = false;
      return;
    }

    try {
      final loaded = await _repo.getProfile(
        uid: user.uid,
        fallbackEmail: user.email ?? '',
        fallbackName: user.displayName ?? '',
      );
      profile.value = loaded;
      _fillForm(loaded);
    } catch (_) {
      // Fall back to what Firebase Auth already knows so the page still works.
      final fallback = AdminProfileModel.empty(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
      );
      profile.value = fallback;
      _fillForm(fallback);
      loadError.value = 'Some profile details couldn’t be loaded. You can still edit and save.';
    } finally {
      isLoading.value = false;
    }
  }

  void _fillForm(AdminProfileModel p) {
    nameController.text = p.displayName;
    jobTitleController.text = p.jobTitle;
    phoneController.text = p.phone;
  }

  // ---------------------------------------------------------------------------
  // ACCOUNT FACTS (straight from Firebase Auth)
  // ---------------------------------------------------------------------------

  String get email => _auth.currentUser?.email ?? profile.value?.email ?? '';
  String get uid => _auth.currentUser?.uid ?? profile.value?.uid ?? '';
  bool get emailVerified => _auth.currentUser?.emailVerified ?? false;

  String get createdLabel =>
      _dateLabel(_auth.currentUser?.metadata.creationTime);
  String get lastSignInLabel =>
      _dateLabel(_auth.currentUser?.metadata.lastSignInTime);

  String _dateLabel(DateTime? value) {
    if (value == null) return '—';
    return DateFormat('dd MMM yyyy, hh:mm a').format(value.toLocal());
  }

  // ---------------------------------------------------------------------------
  // SAVE PROFILE
  // ---------------------------------------------------------------------------

  Future<void> saveProfile() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (isSavingProfile.value) return;

    profileError.value = '';
    if (!(profileFormKey.currentState?.validate() ?? false)) return;

    final current = profile.value;
    if (current == null) return;

    isSavingProfile.value = true;
    try {
      final updated = current.copyWith(
        displayName: nameController.text.trim(),
        jobTitle: jobTitleController.text.trim(),
        phone: phoneController.text.trim(),
      );

      await _repo.updateProfile(updated);

      // Keep the Auth display name in sync so the admin top bar matches.
      // A failure here shouldn't undo the saved profile.
      try {
        await _auth.updateDisplayName(updated.displayName);
      } catch (_) {}

      profile.value = updated;
      _toast('Profile updated', 'Your changes have been saved.');
    } catch (_) {
      profileError.value = 'Unable to save your profile. Please try again.';
    } finally {
      isSavingProfile.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // PROFILE PHOTO
  // ---------------------------------------------------------------------------

  Future<void> changePhoto() async {
    if (isUploadingPhoto.value) return;
    final current = profile.value;
    if (current == null) return;

    profileError.value = '';

    try {
      final files = await CloudinaryFilePicker.pickImages(multiple: false);
      if (files.isEmpty) return;

      final service = _cloudinary();
      if (service == null) {
        profileError.value = 'Photo uploads aren’t configured yet. Add the Cloudinary --dart-define values.';
        return;
      }

      isUploadingPhoto.value = true;

      final result = await service.uploadImage(
        files.first,
        options: const CloudinaryUploadOptions(
          folder: avatarFolder,
          maxBytes: maxAvatarBytes,
          imageMaxWidth: 800,
          imageMaxHeight: 800,
        ),
      );

      // Always store the optimised delivery URL, never the raw upload.
      final deliveryUrl = service.imageUrl(
        result.publicId,
        width: 400,
        height: 400,
        crop: 'fill',
      );

      final updated = current.copyWith(
        photoUrl: deliveryUrl,
        photoPublicId: result.publicId,
      );

      await _repo.updateProfile(updated);
      profile.value = updated;
      _toast('Photo updated', 'Your profile photo has been changed.');
    } on CloudinaryException catch (e) {
      profileError.value = e.message;
    } catch (_) {
      profileError.value = 'Unable to update your photo. Please try again.';
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<void> removePhoto() async {
    if (isUploadingPhoto.value) return;
    final current = profile.value;
    if (current == null || current.photoUrl.isEmpty) return;

    isUploadingPhoto.value = true;
    profileError.value = '';
    try {
      final updated = current.copyWith(photoUrl: '', photoPublicId: '');
      await _repo.updateProfile(updated);
      profile.value = updated;
      _toast('Photo removed', 'Your profile photo has been removed.');
    } catch (_) {
      profileError.value = 'Unable to remove your photo. Please try again.';
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  /// `CloudinaryService` isn't registered anywhere in the app yet, so build it
  /// on first use from the same `--dart-define` values the config expects.
  CloudinaryService? _cloudinary() {
    if (Get.isRegistered<CloudinaryService>()) {
      return Get.find<CloudinaryService>();
    }
    try {
      return Get.put<CloudinaryService>(
        CloudinaryService(config: CloudinaryConfig.fromEnvironment()),
        permanent: true,
      );
    } on CloudinaryConfigException {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // PASSWORD
  // ---------------------------------------------------------------------------

  Future<void> changePassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (isChangingPassword.value) return;

    passwordError.value = '';
    if (!(passwordFormKey.currentState?.validate() ?? false)) return;

    isChangingPassword.value = true;
    try {
      await _auth.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      passwordFormKey.currentState?.reset();

      _toast('Password changed', 'Your password has been updated.');
    } on AuthException catch (e) {
      passwordError.value = e.message;
    } catch (_) {
      passwordError.value = 'Unable to change the password. Please try again.';
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> sendResetLink() async {
    if (isSendingReset.value) return;

    passwordError.value = '';
    isSendingReset.value = true;
    try {
      await _auth.sendPasswordReset();
      _toast('Reset link sent', 'Check $email for the password reset link.');
    } on AuthException catch (e) {
      passwordError.value = e.message;
    } catch (_) {
      passwordError.value = 'Unable to send the reset link. Please try again.';
    } finally {
      isSendingReset.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // SESSION
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.login);
  }

  // ---------------------------------------------------------------------------

  void _toast(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      maxWidth: 420,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    jobTitleController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
