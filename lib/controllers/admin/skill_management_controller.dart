import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/models/skill_model.dart';
import 'package:sufyan_portfolio/repositories/skill_repository.dart';

/// Admin CRUD controller for portfolio skills.
class SkillManagementController extends GetxController {
  final _repo = SkillRepository.instance;
  static final _dangerTint = AppColors.danger.withValues(alpha: 0.12);

  final RxList<SkillModel> skills = <SkillModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  List<String> get categories {
    final values = skills
        .map((skill) => skill.category.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...values];
  }

  List<SkillModel> get filteredSkills {
    final query = searchQuery.value.trim().toLowerCase();
    final category = selectedCategory.value;

    return skills.where((skill) {
      final matchesQuery = query.isEmpty ||
          skill.name.toLowerCase().contains(query) ||
          skill.category.toLowerCase().contains(query) ||
          skill.description.toLowerCase().contains(query);
      final matchesCategory = category == 'All' || skill.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadSkills();
  }

  Future<void> loadSkills() async {
    isLoading.value = true;
    try {
      skills.value = await _repo.getAll();
    } catch (e) {
      Get.snackbar(
        'Couldn\'t load skills',
        _friendlyError(e),
        backgroundColor: _dangerTint,
        colorText: AppColors.danger,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveSkill(SkillModel draft) async {
    isSaving.value = true;
    try {
      if (draft.id.isEmpty) {
        final created = await _repo.add(draft);
        skills.add(created);
      } else {
        await _repo.update(draft);
        final index = skills.indexWhere((skill) => skill.id == draft.id);
        if (index != -1) skills[index] = draft;
      }
      skills.sort(_sortSkills);
      skills.refresh();

      Get.snackbar(
        draft.id.isEmpty ? 'Skill added' : 'Skill updated',
        draft.name,
        backgroundColor: AppColors.primarySoft,
        colorText: AppColors.primary,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Couldn\'t save the skill',
        _friendlyError(e),
        backgroundColor: _dangerTint,
        colorText: AppColors.danger,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteSkill(SkillModel skill) async {
    try {
      await _repo.delete(skill.id);
      skills.removeWhere((item) => item.id == skill.id);
      if (!categories.contains(selectedCategory.value)) {
        selectedCategory.value = 'All';
      }
      Get.snackbar(
        'Skill deleted',
        skill.name,
        backgroundColor: AppColors.surfaceMuted,
        colorText: AppColors.textPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Couldn\'t delete the skill',
        _friendlyError(e),
        backgroundColor: _dangerTint,
        colorText: AppColors.danger,
      );
    }
  }

  void setSearch(String value) => searchQuery.value = value;
  void selectCategory(String value) => selectedCategory.value = value;

  static int _sortSkills(SkillModel a, SkillModel b) {
    final order = a.sortOrder.compareTo(b.sortOrder);
    if (order != 0) return order;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  String _friendlyError(Object e) =>
      kDebugMode ? e.toString() : 'Please check your connection and try again.';
}
