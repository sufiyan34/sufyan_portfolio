import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/skill_model.dart';
import 'package:sufyan_portfolio/repositories/skill_repository.dart';

const String kAllSkillsFilter = 'All';

/// Public skills controller — published skills only.
class SkillsController extends GetxController {
  final _repo = SkillRepository.instance;

  final RxList<SkillModel> skills = <SkillModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedCategory = kAllSkillsFilter.obs;

  List<String> get categories {
    final values = skills
        .map((skill) => skill.category.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return [kAllSkillsFilter, ...values];
  }

  List<SkillModel> get filteredSkills {
    final category = selectedCategory.value;
    if (category == kAllSkillsFilter) return skills.toList();
    return skills.where((skill) => skill.category == category).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadSkills();
  }

  Future<void> loadSkills() async {
    isLoading.value = true;
    try {
      skills.value = await _repo.getPublished();
      if (!categories.contains(selectedCategory.value)) {
        selectedCategory.value = kAllSkillsFilter;
      }
    } catch (_) {
      skills.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) => selectedCategory.value = category;
}
