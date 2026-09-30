import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/project_model.dart';
import 'package:sufyan_portfolio/repositories/project_repository.dart';

class ProjectDetailsController extends GetxController {
  final _repo = ProjectRepository.instance;

  final Rxn<ProjectModel> project = Rxn<ProjectModel>();
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  String get identifier => (Get.arguments?.toString() ?? '').trim();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final key = identifier;
      if (key.isEmpty) {
        errorMessage.value = 'Project could not be identified.';
        project.value = null;
        return;
      }

      // Public project cards currently pass the project slug. We also accept
      // an id so the route can be deep-linked later without another UI change.
      final all = await _repo.getAll();
      ProjectModel? result;
      for (final item in all) {
        if (item.slug == key || item.id == key) {
          result = item;
          break;
        }
      }

      if (result == null || !result.published || result.visibility == 'private') {
        project.value = null;
        errorMessage.value = 'This project is not available.';
      } else {
        project.value = result;
      }
    } catch (_) {
      project.value = null;
      errorMessage.value = 'Unable to load this project right now.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => load();
}
