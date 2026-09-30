import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/experience_model.dart';
import 'package:sufyan_portfolio/repositories/experience_repository.dart';

/// Public experience controller — published timeline entries only.
class ExperienceController extends GetxController {
  final _repo = ExperienceRepository.instance;

  final RxList<ExperienceModel> experiences = <ExperienceModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadExperiences();
  }

  Future<void> loadExperiences() async {
    isLoading.value = true;
    try {
      experiences.value = await _repo.getPublished();
    } catch (_) {
      experiences.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
