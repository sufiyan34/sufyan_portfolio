import 'package:get/get.dart';
import 'package:sufyan_portfolio/controllers/home_controller.dart';
import 'package:sufyan_portfolio/models/about_content_model.dart';
import 'package:sufyan_portfolio/repositories/about_content_repository.dart';

class AboutController extends GetxController {
  final _repo = AboutContentRepository.instance;

  final Rx<AboutContentModel> content = AboutContentModel.fallback().obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  /// Home already has a reusable hero image source, so About can gracefully
  /// fall back to it when `aboutContent/imageUrl` has not been configured yet.
  String get fallbackImageUrl =>
      Get.isRegistered<HomeController>()
          ? Get.find<HomeController>().content.value.heroImageUrl
          : '';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      content.value = await _repo.getContent();
    } catch (_) {
      hasError.value = true;
      content.value = AboutContentModel.fallback();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => load();
}
