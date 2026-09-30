import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/package_model.dart';
import 'package:sufyan_portfolio/repositories/package_repository.dart';

const String kAllAdminPackagesFilter = 'all';

class PackageManagementController extends GetxController {
  final _repo = PackageRepository.instance;

  final RxList<PackageModel> packages = <PackageModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedType = kAllAdminPackagesFilter.obs;

  List<String> get types => [kAllAdminPackagesFilter, ...PackageTypes.all];

  List<PackageModel> get filteredPackages {
    final query = searchQuery.value.trim().toLowerCase();
    final type = selectedType.value;

    return packages.where((package) {
      final matchesType = type == kAllAdminPackagesFilter ||
          PackageTypes.normalize(package.type) == type;
      final searchable = [
        package.title,
        package.type,
        package.shortDescription,
        package.description,
        package.features.join(' '),
      ].join(' ').toLowerCase();
      final matchesQuery = query.isEmpty || searchable.contains(query);
      return matchesType && matchesQuery;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadPackages();
  }

  Future<void> loadPackages() async {
    isLoading.value = true;
    try {
      packages.value = await _repo.getAll();
    } catch (_) {
      packages.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void setSearch(String value) => searchQuery.value = value;

  void selectType(String type) => selectedType.value = type;

  Future<bool> savePackage(PackageModel draft) async {
    isSaving.value = true;
    try {
      if (draft.id.isEmpty) {
        await _repo.add(draft);
      } else {
        await _repo.update(draft);
      }
      await loadPackages();
      return true;
    } catch (_) {
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deletePackage(PackageModel package) async {
    isSaving.value = true;
    try {
      await _repo.delete(package.id);
      packages.removeWhere((item) => item.id == package.id);
      return true;
    } catch (_) {
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
