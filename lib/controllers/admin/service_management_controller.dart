import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/models/service_model.dart';
import 'package:sufyan_portfolio/repositories/service_repository.dart';

/// Admin CRUD controller for portfolio services.
class ServiceManagementController extends GetxController {
  final _repo = ServiceRepository.instance;
  static final _dangerTint = AppColors.danger.withValues(alpha: 0.12);

  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  List<String> get categories {
    final values = services
        .map((service) => service.category.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...values];
  }

  List<ServiceModel> get filteredServices {
    final query = searchQuery.value.trim().toLowerCase();
    final category = selectedCategory.value;

    return services.where((service) {
      final searchable = [
        service.title,
        service.category,
        service.shortDescription,
        service.description,
        ...service.features,
        ...service.technologies,
      ].join(' ').toLowerCase();

      final matchesQuery = query.isEmpty || searchable.contains(query);
      final matchesCategory = category == 'All' || service.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices() async {
    isLoading.value = true;
    try {
      services.value = await _repo.getAll();
    } catch (e) {
      Get.snackbar(
        'Couldn\'t load services',
        _friendlyError(e),
        backgroundColor: _dangerTint,
        colorText: AppColors.danger,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveService(ServiceModel draft) async {
    isSaving.value = true;
    try {
      final isNew = draft.id.isEmpty;

      if (isNew) {
        final created = await _repo.add(draft);
        services.add(created);
      } else {
        await _repo.update(draft);
        final index = services.indexWhere((item) => item.id == draft.id);
        if (index != -1) services[index] = draft;
      }

      services.sort(_sortServices);
      services.refresh();

      Get.snackbar(
        isNew ? 'Service added' : 'Service updated',
        draft.title,
        backgroundColor: AppColors.primarySoft,
        colorText: AppColors.primary,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Couldn\'t save the service',
        _friendlyError(e),
        backgroundColor: _dangerTint,
        colorText: AppColors.danger,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteService(ServiceModel service) async {
    try {
      await _repo.delete(service.id);
      services.removeWhere((item) => item.id == service.id);

      if (!categories.contains(selectedCategory.value)) {
        selectedCategory.value = 'All';
      }

      Get.snackbar(
        'Service deleted',
        service.title,
        backgroundColor: AppColors.surfaceMuted,
        colorText: AppColors.textPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Couldn\'t delete the service',
        _friendlyError(e),
        backgroundColor: _dangerTint,
        colorText: AppColors.danger,
      );
    }
  }

  void setSearch(String value) => searchQuery.value = value;
  void selectCategory(String value) => selectedCategory.value = value;

  static int _sortServices(ServiceModel a, ServiceModel b) {
    final featured = a.featured == b.featured ? 0 : (a.featured ? -1 : 1);
    if (featured != 0) return featured;

    final order = a.sortOrder.compareTo(b.sortOrder);
    if (order != 0) return order;

    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  String _friendlyError(Object error) => kDebugMode
      ? error.toString()
      : 'Please check your connection and try again.';
}
