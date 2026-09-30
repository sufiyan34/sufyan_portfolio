import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/models/hire_request_model.dart';
import 'package:sufyan_portfolio/models/package_model.dart';
import 'package:sufyan_portfolio/models/service_model.dart';
import 'package:sufyan_portfolio/repositories/hire_request_repository.dart';
import 'package:sufyan_portfolio/repositories/package_repository.dart';
import 'package:sufyan_portfolio/repositories/service_repository.dart';

class HireRequestController extends GetxController {
  final _hireRepo = HireRequestRepository.instance;
  final _serviceRepo = ServiceRepository.instance;
  final _packageRepo = PackageRepository.instance;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final companyController = TextEditingController();
  final phoneController = TextEditingController();
  final projectNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final referenceLinksController = TextEditingController();

  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxList<PackageModel> packages = <PackageModel>[].obs;
  final RxBool isLoadingOptions = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString selectedProjectType = ''.obs;
  final RxString selectedServiceId = ''.obs;
  final RxString selectedPackageId = ''.obs;
  final RxString selectedBudget = ''.obs;
  final RxString selectedTimeline = ''.obs;
  final RxString selectedPlatform = ''.obs;
  final RxString selectedContactMethod = ''.obs;

  static const projectTypes = [
    'Mobile App',
    'Web App',
    'Business System',
    'E-Commerce',
    'API Integration',
    'Firebase / Backend',
    'UI / UX Implementation',
    'Maintenance / Existing App',
    'Other',
  ];

  static const budgetRanges = [
    'Under PKR 50K',
    'PKR 50K–100K',
    'PKR 100K–250K',
    'PKR 250K–500K',
    'PKR 500K+',
    'Custom / Discuss',
  ];

  static const timelines = [
    'ASAP',
    '1–2 weeks',
    '2–4 weeks',
    '1–2 months',
    '2–3 months',
    'Flexible',
  ];

  static const platforms = [
    'Android',
    'iOS',
    'Android + iOS',
    'Web',
    'Mobile + Web',
    'Desktop',
    'Cross-platform / Discuss',
  ];

  static const contactMethods = [
    'Email',
    'WhatsApp',
    'Phone Call',
    'Video Call',
  ];

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    loadOptions();
  }

  void _readArguments() {
    final raw = Get.arguments;

    if (raw is Map) {
      selectedPackageId.value = raw['packageId']?.toString() ?? '';
      selectedServiceId.value = raw['serviceId']?.toString() ?? '';
      return;
    }

    if (raw is String && raw.trim().isNotEmpty) {
      selectedPackageId.value = raw.trim();
    }
  }

  Future<void> loadOptions() async {
    isLoadingOptions.value = true;

    try {
      final result = await Future.wait([
        _serviceRepo.getPublished(),
        _packageRepo.getPublished(),
      ]);

      services.assignAll(result[0] as List<ServiceModel>);
      packages.assignAll(result[1] as List<PackageModel>);

      _normalizeSelections();
    } catch (_) {
      services.clear();
      packages.clear();
      _normalizeSelections();
    } finally {
      isLoadingOptions.value = false;
    }
  }

  void _normalizeSelections() {
    if (selectedServiceId.value.isNotEmpty &&
        !services.any((item) => item.id == selectedServiceId.value)) {
      selectedServiceId.value = '';
    }

    if (selectedPackageId.value.isNotEmpty &&
        !packages.any((item) => item.id == selectedPackageId.value)) {
      selectedPackageId.value = '';
    }
  }

  void selectProjectType(String value) => selectedProjectType.value = value;
  void selectService(String value) => selectedServiceId.value = value;
  void selectPackage(String value) => selectedPackageId.value = value;
  void selectBudget(String value) => selectedBudget.value = value;
  void selectTimeline(String value) => selectedTimeline.value = value;
  void selectPlatform(String value) => selectedPlatform.value = value;
  void selectContactMethod(String value) => selectedContactMethod.value = value;

  Future<void> submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    errorMessage.value = '';

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final missing = <String>[];
    if (selectedProjectType.value.isEmpty) missing.add('Project type');
    if (selectedBudget.value.isEmpty) missing.add('Budget range');
    if (selectedTimeline.value.isEmpty) missing.add('Timeline');
    if (selectedPlatform.value.isEmpty) missing.add('Preferred platform');

    if (missing.isNotEmpty) {
      errorMessage.value = 'Please select: ${missing.join(', ')}.';
      return;
    }

    isSubmitting.value = true;

    try {
      final service = _findService(selectedServiceId.value);
      final package = _findPackage(selectedPackageId.value);

      final request = HireRequestModel.empty().copyWith(
        name: nameController.text.trim(),
        company: companyController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        projectName: projectNameController.text.trim(),
        projectType: selectedProjectType.value,
        serviceId: service?.id ?? '',
        serviceTitle: service?.title ?? '',
        packageId: package?.id ?? '',
        packageTitle: package?.title ?? '',
        budgetRange: selectedBudget.value,
        timeline: selectedTimeline.value,
        preferredPlatform: selectedPlatform.value,
        preferredContact: selectedContactMethod.value,
        description: descriptionController.text.trim(),
        referenceLinks: _parseLinks(referenceLinksController.text),
      );

      final requestId = await _hireRepo.create(request);

      Get.offNamed(
        AppRoutes.requestSuccess,
        arguments: {
          'requestId': requestId,
          'projectName': request.projectName,
        },
      );
    } catch (_) {
      errorMessage.value =
          'Unable to submit your request right now. Please try again.';
    } finally {
      isSubmitting.value = false;
    }
  }

  ServiceModel? _findService(String id) {
    if (id.isEmpty) return null;
    for (final service in services) {
      if (service.id == id) return service;
    }
    return null;
  }

  PackageModel? _findPackage(String id) {
    if (id.isEmpty) return null;
    for (final package in packages) {
      if (package.id == id) return package;
    }
    return null;
  }

  List<String> _parseLinks(String raw) {
    return raw
        .split(RegExp(r'[\n,]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    companyController.dispose();
    phoneController.dispose();
    projectNameController.dispose();
    descriptionController.dispose();
    referenceLinksController.dispose();
    super.onClose();
  }
}
