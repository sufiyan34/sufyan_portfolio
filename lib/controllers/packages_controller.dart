import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/package_model.dart';
import 'package:sufyan_portfolio/repositories/package_repository.dart';

const String kAllPackagesFilter = 'all';

/// Public packages controller — published packages only.
class PackagesController extends GetxController {
  final _repo = PackageRepository.instance;

  final RxList<PackageModel> packages = <PackageModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedType = kAllPackagesFilter.obs;

  List<String> get filters => [
        kAllPackagesFilter,
        ...PackageTypes.all,
      ];

  List<PackageModel> get filteredPackages {
    final selected = PackageTypes.normalize(selectedType.value);
    if (selectedType.value == kAllPackagesFilter) return packages.toList();
    return packages.where((item) => PackageTypes.normalize(item.type) == selected).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadPackages();
  }

  Future<void> loadPackages() async {
    isLoading.value = true;
    try {
      packages.value = await _repo.getPublished();
      if (selectedType.value != kAllPackagesFilter &&
          !filters.contains(selectedType.value)) {
        selectedType.value = kAllPackagesFilter;
      }
    } catch (_) {
      packages.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void selectType(String type) => selectedType.value = type;
}
