import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/models/experience_model.dart';
import 'package:sufyan_portfolio/repositories/experience_repository.dart';

/// Admin CRUD controller for portfolio experience entries.
class ExperienceManagementController extends GetxController {
  final _repo = ExperienceRepository.instance;
  static final _dangerTint = AppColors.danger.withValues(alpha: 0.12);

  final RxList<ExperienceModel> experiences = <ExperienceModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedType = 'All'.obs;

  List<String> get types {
    final values = experiences
        .map((experience) => experience.employmentType.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...values];
  }

  List<ExperienceModel> get filteredExperiences {
    final query = searchQuery.value.trim().toLowerCase();
    final type = selectedType.value;

    return experiences.where((experience) {
      final searchable = [
        experience.role,
        experience.company,
        experience.employmentType,
        experience.location,
        experience.description,
        ...experience.achievements,
        ...experience.technologies,
      ].join(' ').toLowerCase();

      final matchesQuery = query.isEmpty || searchable.contains(query);
      final matchesType = type == 'All' || experience.employmentType == type;
      return matchesQuery && matchesType;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadExperiences();
  }

  Future<void> loadExperiences() async {
    isLoading.value = true;
    try {
      experiences.value = await _repo.getAll();
    } catch (e) {
      Get.snackbar(
        'Couldn\'t load experience',
        _friendlyError(e),
        backgroundColor: _dangerTint,
        colorText: AppColors.danger,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveExperience(ExperienceModel draft) async {
    isSaving.value = true;
    try {
      final isNew = draft.id.isEmpty;

      if (isNew) {
        final created = await _repo.add(draft);
        experiences.add(created);
      } else {
        await _repo.update(draft);
        final index = experiences.indexWhere((item) => item.id == draft.id);
        if (index != -1) {
          experiences[index] = draft;
        }
      }

      experiences.sort(_sortExperiences);
      experiences.refresh();

      Get.snackbar(
        isNew ? 'Experience added' : 'Experience updated',
        draft.role,
        backgroundColor: AppColors.primarySoft,
        colorText: AppColors.primary,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Couldn\'t save experience',
        _friendlyError(e),
        backgroundColor: _dangerTint,
        colorText: AppColors.danger,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteExperience(ExperienceModel experience) async {
    try {
      await _repo.delete(experience.id);
      experiences.removeWhere((item) => item.id == experience.id);

      if (!types.contains(selectedType.value)) {
        selectedType.value = 'All';
      }

      Get.snackbar(
        'Experience deleted',
        experience.role,
        backgroundColor: AppColors.surfaceMuted,
        colorText: AppColors.textPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Couldn\'t delete the experience',
        _friendlyError(e),
        backgroundColor: _dangerTint,
        colorText: AppColors.danger,
      );
    }
  }

  void setSearch(String value) => searchQuery.value = value;
  void selectType(String value) => selectedType.value = value;

  static int _sortExperiences(ExperienceModel a, ExperienceModel b) {
    final order = a.sortOrder.compareTo(b.sortOrder);
    if (order != 0) return order;

    if (a.isCurrent != b.isCurrent) {
      return a.isCurrent ? -1 : 1;
    }

    return a.role.toLowerCase().compareTo(b.role.toLowerCase());
  }

  String _friendlyError(Object error) => kDebugMode
      ? error.toString()
      : 'Please check your connection and try again.';
}
