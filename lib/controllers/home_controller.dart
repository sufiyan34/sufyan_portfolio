import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/home_content_model.dart';
import 'package:sufyan_portfolio/repositories/home_content_repository.dart';

/// Backs the public Home screen (currently just the Hero section; more
/// sections will read from this same controller as they're built).
class HomeController extends GetxController {
  final _repo = HomeContentRepository.instance;

  /// Starts pre-filled with the fallback copy so the hero renders
  /// immediately — [content] is swapped for live data once it loads.
  final Rx<HomeContentModel> content = HomeContentModel.fallback().obs;
  final RxList<HomeStatModel> stats = HomeStatModel.fallback().obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    final results = await Future.wait([
      _repo.getHomeContent(),
      _repo.getStats(),
    ]);
    content.value = results[0] as HomeContentModel;
    stats.value = results[1] as List<HomeStatModel>;
    isLoading.value = false;
  }

  Future<void> refresh() => _load();
}
