import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/models/project_model.dart';
import 'package:sufyan_portfolio/repositories/project_repository.dart';

/// Backs the admin Project Management screen — list + add/edit/delete.
class ProjectManagementController extends GetxController {
  final _repo = ProjectRepository.instance;
  static final _dangerTint = AppColors.danger.withValues(alpha: 0.12);

  final RxList<ProjectModel> projects = <ProjectModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  Future<void> loadProjects() async {
    isLoading.value = true;
    try {
      projects.value = await _repo.getAll();
    } catch (e) {
      Get.snackbar(
        'Couldn\'t load projects',
        _friendlyError(e),
        backgroundColor: _dangerTint,
        colorText: AppColors.danger,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Adds a new project (draft.id is empty) or updates an existing one.
  Future<bool> saveProject(ProjectModel draft) async {
    isSaving.value = true;
    try {
      if (draft.id.isEmpty) {
        final created = await _repo.add(draft);
        projects.add(created);
      } else {
        await _repo.update(draft);
        final index = projects.indexWhere((p) => p.id == draft.id);
        if (index != -1) projects[index] = draft;
      }
      projects.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      Get.snackbar(
        draft.id.isEmpty ? 'Project added' : 'Project updated',
        draft.title,
        backgroundColor: AppColors.primarySoft,
        colorText: AppColors.primary,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Couldn\'t save the project',
        _friendlyError(e),
        backgroundColor: _dangerTint,
        colorText: AppColors.danger,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteProject(ProjectModel project) async {
    try {
      await _repo.delete(project.id);
      projects.removeWhere((p) => p.id == project.id);
      Get.snackbar(
        'Project deleted',
        project.title,
        backgroundColor: AppColors.surfaceMuted,
        colorText: AppColors.textPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Couldn\'t delete the project',
        _friendlyError(e),
        backgroundColor: _dangerTint,
        colorText: AppColors.danger,
      );
    }
  }

  String _friendlyError(Object e) =>
      kDebugMode ? e.toString() : 'Please check your connection and try again.';
}
