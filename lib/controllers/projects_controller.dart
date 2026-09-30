import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/project_model.dart';
import 'package:sufyan_portfolio/repositories/project_repository.dart';

const String kAllCategoriesFilter = 'All';

/// Backs the public Projects page — loads published projects and drives
/// the category filter row.
class ProjectsController extends GetxController {
  final _repo = ProjectRepository.instance;

  final RxList<ProjectModel> _projects = <ProjectModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedCategory = kAllCategoriesFilter.obs;

  List<ProjectModel> get filteredProjects {
    if (selectedCategory.value == kAllCategoriesFilter) return _projects;
    return _projects
        .where((p) => p.categoryIds.contains(selectedCategory.value))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  Future<void> loadProjects() async {
    isLoading.value = true;
    try {
      _projects.value = await _repo.getPublished();
    } catch (_) {
      _projects.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) => selectedCategory.value = category;
}
