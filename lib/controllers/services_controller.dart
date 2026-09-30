import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/service_model.dart';
import 'package:sufyan_portfolio/repositories/service_repository.dart';

const String kAllServicesFilter = 'All';

/// Public services controller — published services only.
class ServicesController extends GetxController {
  final _repo = ServiceRepository.instance;

  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedCategory = kAllServicesFilter.obs;

  List<String> get categories {
    final values = services
        .map((service) => service.category.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return [kAllServicesFilter, ...values];
  }

  List<ServiceModel> get filteredServices {
    final category = selectedCategory.value;
    if (category == kAllServicesFilter) return services.toList();
    return services.where((service) => service.category == category).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices() async {
    isLoading.value = true;
    try {
      services.value = await _repo.getPublished();
      if (!categories.contains(selectedCategory.value)) {
        selectedCategory.value = kAllServicesFilter;
      }
    } catch (_) {
      services.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) => selectedCategory.value = category;
}
