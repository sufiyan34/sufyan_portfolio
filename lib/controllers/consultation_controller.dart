import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sufyan_portfolio/controllers/home_controller.dart';
import 'package:sufyan_portfolio/models/consultation_request_model.dart';
import 'package:sufyan_portfolio/repositories/consultation_repository.dart';
import 'package:sufyan_portfolio/repositories/home_content_repository.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_config.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_exception.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_file_picker.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_media_helper.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_models.dart';
import 'package:sufyan_portfolio/services/cloudinary/cloudinary_service.dart';

enum AttachmentStatus { pending, uploading, uploaded, failed }

/// A file the visitor picked/dropped. It is only uploaded to Cloudinary when
/// the request is submitted, so abandoned forms never leave orphan assets.
class PendingAttachment {
  PendingAttachment({
    required this.id,
    required this.file,
    required this.bytes,
  });

  final String id;
  final XFile file;
  final int bytes;

  final Rx<AttachmentStatus> status = AttachmentStatus.pending.obs;
  final RxDouble progress = 0.0.obs;
  final RxString error = ''.obs;

  CloudinaryUploadResult? result;

  String get name => file.name;
}

class ConsultationController extends GetxController {
  final _repo = ConsultationRepository.instance;

  static const maxFiles = 5;
  static const maxFileBytes = 10 * 1024 * 1024; // 10 MB per file
  static const uploadFolder = 'portfolio/consultations';

  /// Public visitors can upload here, so executable/script types are refused.
  static const blockedExtensions = {
    'exe',
    'bat',
    'cmd',
    'com',
    'msi',
    'scr',
    'sh',
    'apk',
    'dmg',
    'jar',
    'js',
    'vbs',
    'ps1',
    'app',
    'pkg',
  };

  static const consultationTypes = [
    'Project Planning',
    'Technical Consultation',
    'Architecture Review',
    'Career Guidance',
    'Other',
  ];

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

  final RxString selectedType = ''.obs;
  final Rxn<DateTime> preferredDate = Rxn<DateTime>();
  final RxString preferredTime = ''.obs;

  final RxList<PendingAttachment> attachments = <PendingAttachment>[].obs;
  final RxBool isDragging = false.obs;
  final RxString fileError = ''.obs;

  final RxBool isSubmitting = false.obs;
  final RxBool submitted = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString referenceId = ''.obs;

  final RxString heroImageUrl = ''.obs;

  int _idSeed = 0;

  @override
  void onInit() {
    super.onInit();
    _loadHeroImage();
  }

  // ---------------------------------------------------------------------------
  // HERO IMAGE — reuses the Home hero image, no new content node needed.
  // ---------------------------------------------------------------------------

  Future<void> _loadHeroImage() async {
    if (Get.isRegistered<HomeController>()) {
      heroImageUrl.value =
          Get.find<HomeController>().content.value.heroImageUrl;
      if (heroImageUrl.value.isNotEmpty) return;
    }
    try {
      final home = await HomeContentRepository.instance.getHomeContent();
      heroImageUrl.value = home.heroImageUrl;
    } catch (_) {
      // The page still looks fine without the photo.
    }
  }

  // ---------------------------------------------------------------------------
  // FORM SELECTIONS
  // ---------------------------------------------------------------------------

  void selectType(String value) => selectedType.value = value;

  void setDate(DateTime value) => preferredDate.value = value;

  void setTime(String label) => preferredTime.value = label;

  String get preferredDateLabel {
    final date = preferredDate.value;
    return date == null ? '' : DateFormat('dd MMM yyyy').format(date);
  }

  // ---------------------------------------------------------------------------
  // FILES (drop / browse)
  // ---------------------------------------------------------------------------

  Future<void> browseFiles() async {
    try {
      final files = await CloudinaryFilePicker.pickAnyFiles(multiple: true);
      await addFiles(files);
    } catch (_) {
      fileError.value = 'Unable to open the file picker. Please try again.';
    }
  }

  Future<void> addFiles(List<XFile> files) async {
    if (files.isEmpty || isSubmitting.value) return;

    final problems = <String>[];

    for (final file in files) {
      if (attachments.length >= maxFiles) {
        problems.add('You can attach up to $maxFiles files.');
        break;
      }

      final extension = CloudinaryMediaHelper.extensionOf(file.name);
      if (extension.isEmpty || blockedExtensions.contains(extension)) {
        problems.add('${file.name}: this file type can’t be attached.');
        continue;
      }

      int size;
      try {
        size = await file.length();
      } catch (_) {
        problems.add('${file.name}: unable to read this file.');
        continue;
      }

      if (size == 0) {
        problems.add('${file.name}: the file is empty.');
        continue;
      }

      if (size > maxFileBytes) {
        problems.add(
          '${file.name} is larger than '
          '${CloudinaryMediaHelper.formatBytes(maxFileBytes)}.',
        );
        continue;
      }

      final duplicate = attachments.any(
        (item) => item.name == file.name && item.bytes == size,
      );
      if (duplicate) continue;

      attachments.add(
        PendingAttachment(id: 'file_${_idSeed++}', file: file, bytes: size),
      );
    }

    fileError.value = problems.toSet().join('\n');
  }

  void removeFile(PendingAttachment item) {
    if (isSubmitting.value) return;
    attachments.remove(item);
    fileError.value = '';
  }

  // ---------------------------------------------------------------------------
  // SUBMIT
  // ---------------------------------------------------------------------------

  Future<void> submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (isSubmitting.value) return;

    errorMessage.value = '';

    if (!(formKey.currentState?.validate() ?? false)) return;

    isSubmitting.value = true;

    try {
      final uploaded = await _uploadAttachments();
      if (uploaded == null) return; // errorMessage already set

      final request = ConsultationRequestModel(
        id: '',
        name: nameController.text.trim(),
        email: emailController.text.trim().toLowerCase(),
        consultationType: selectedType.value,
        message: messageController.text.trim(),
        preferredDate: preferredDate.value == null
            ? ''
            : DateFormat('yyyy-MM-dd').format(preferredDate.value!),
        preferredTime: preferredTime.value,
        attachments: uploaded,
        status: 'new',
        createdAt: 0,
        updatedAt: 0,
      );

      referenceId.value = await _repo.create(request);
      submitted.value = true;
      _resetForm();
    } catch (_) {
      errorMessage.value =
          'Unable to submit your request right now. Please try again.';
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Uploads every pending file. Returns `null` (with [errorMessage] set) when
  /// anything fails, so the request is never saved with missing references.
  /// Files that already uploaded are kept, so a retry only re-sends failures.
  Future<List<ConsultationAttachment>?> _uploadAttachments() async {
    if (attachments.isEmpty) return const [];

    final service = _cloudinary();
    if (service == null) {
      errorMessage.value = 'File uploads aren’t available right now. Remove the files or try again later.';
      return null;
    }

    var anyFailed = false;

    for (final item in attachments.toList()) {
      if (item.status.value == AttachmentStatus.uploaded &&
          item.result != null) {
        continue;
      }

      item.status.value = AttachmentStatus.uploading;
      item.progress.value = 0;
      item.error.value = '';

      try {
        final kind = _kindFor(item.name);
        final result = await service.upload(
          item.file,
          kind: kind,
          options: CloudinaryUploadOptions(
            folder: uploadFolder,
            maxBytes: maxFileBytes,
            // Keep the original so the file can be reviewed as sent.
            compressImage: false,
          ),
          onSendProgress: (sent, total) {
            if (total > 0) item.progress.value = (sent / total).clamp(0.0, 1.0);
          },
        );

        item.result = result;
        item.progress.value = 1;
        item.status.value = AttachmentStatus.uploaded;
      } catch (error) {
        anyFailed = true;
        item.status.value = AttachmentStatus.failed;
        item.error.value = error is CloudinaryException
            ? error.message
            : 'Upload failed. Please try again.';
      }
    }

    if (anyFailed) {
      errorMessage.value = 'Some files couldn’t be uploaded. Remove them or press submit again to retry.';
      return null;
    }

    return [
      for (final item in attachments)
        if (item.result != null)
          ConsultationAttachment(
            name: item.name,
            url: item.result!.secureUrl,
            publicId: item.result!.publicId,
            resourceType: item.result!.resourceType,
            format: item.result!.format,
            bytes: item.result!.bytes,
          ),
    ];
  }

  /// Images/videos keep their native Cloudinary type; everything else
  /// (PDF, docs, zip, Figma exports…) is stored as a raw file. 3D/zip kinds
  /// are deliberately not used here — Cloudinary would treat a zip as an image.
  CloudinaryMediaKind _kindFor(String name) {
    final kind = CloudinaryMediaHelper.kindFromExtension(name);
    if (kind == CloudinaryMediaKind.image ||
        kind == CloudinaryMediaKind.video) {
      return kind;
    }
    return CloudinaryMediaKind.file;
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
  // RESET
  // ---------------------------------------------------------------------------

  void _resetForm() {
    nameController.clear();
    emailController.clear();
    messageController.clear();
    selectedType.value = '';
    preferredDate.value = null;
    preferredTime.value = '';
    attachments.clear();
    fileError.value = '';
  }

  void startAnotherRequest() {
    submitted.value = false;
    referenceId.value = '';
    errorMessage.value = '';
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
