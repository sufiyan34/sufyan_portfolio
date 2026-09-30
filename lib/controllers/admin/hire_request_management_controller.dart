import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/hire_request_model.dart';
import 'package:sufyan_portfolio/repositories/hire_request_repository.dart';

const String kAllHireRequestsFilter = 'all';

class HireRequestManagementController extends GetxController {
  final _repo = HireRequestRepository.instance;

  final RxList<HireRequestModel> requests = <HireRequestModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString search = ''.obs;
  final RxString selectedStatus = kAllHireRequestsFilter.obs;

  List<String> get filters => [
        kAllHireRequestsFilter,
        ...HireRequestStatuses.all,
      ];

  List<HireRequestModel> get filteredRequests {
    final query = search.value.trim().toLowerCase();
    final status = selectedStatus.value;

    return requests.where((item) {
      final statusMatches =
          status == kAllHireRequestsFilter || item.status == status;

      if (!statusMatches) return false;
      if (query.isEmpty) return true;

      final haystack = [
        item.name,
        item.company,
        item.email,
        item.projectName,
        item.projectType,
        item.serviceTitle,
        item.packageTitle,
      ].join(' ').toLowerCase();

      return haystack.contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadRequests();
  }

  Future<void> loadRequests() async {
    isLoading.value = true;
    try {
      requests.assignAll(await _repo.getAll());
    } catch (_) {
      requests.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void setSearch(String value) => search.value = value;

  void selectStatus(String value) => selectedStatus.value = value;
}
