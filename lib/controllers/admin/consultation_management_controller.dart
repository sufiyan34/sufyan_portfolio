import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/consultation_request_model.dart';
import 'package:sufyan_portfolio/repositories/consultation_repository.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';

/// Admin controller for the `consultations/` node.
class ConsultationManagementController extends GetxController {
  final _repo = ConsultationRepository.instance;

  final RxList<ConsultationRequestModel> items =
      <ConsultationRequestModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;

  int get total => items.length;
  int countOf(String status) => items.where((e) => e.status == status).length;

  List<ConsultationRequestModel> get filtered {
    final query = searchQuery.value.trim().toLowerCase();
    final status = statusFilter.value;
    return items.where((item) {
      final matchesStatus = status == 'all' || item.status == status;
      final matchesQuery =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.email.toLowerCase().contains(query) ||
          item.consultationType.toLowerCase().contains(query) ||
          item.message.toLowerCase().contains(query);
      return matchesStatus && matchesQuery;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      items.value = await _repo.getAll();
    } catch (e) {
      adminSnack('Couldn\'t load consultations', _friendly(e), error: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setStatus(ConsultationRequestModel item, String status) async {
    if (item.status == status) return;
    try {
      await _repo.updateStatus(item.id, status);
      _replace(item.copyWith(status: status));
      adminSnack('Status updated', ConsultationStatuses.label(status));
    } catch (e) {
      adminSnack('Couldn\'t update status', _friendly(e), error: true);
    }
  }

  Future<bool> saveNotes(ConsultationRequestModel item, String notes) async {
    isSaving.value = true;
    try {
      await _repo.updateAdminNotes(item.id, notes);
      _replace(item.copyWith(adminNotes: notes.trim()));
      adminSnack('Notes saved', item.name);
      return true;
    } catch (e) {
      adminSnack('Couldn\'t save notes', _friendly(e), error: true);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> delete(ConsultationRequestModel item) async {
    try {
      await _repo.delete(item.id);
      items.removeWhere((e) => e.id == item.id);
      adminSnack('Consultation deleted', item.name);
      return true;
    } catch (e) {
      adminSnack('Couldn\'t delete', _friendly(e), error: true);
      return false;
    }
  }

  void _replace(ConsultationRequestModel updated) {
    final index = items.indexWhere((e) => e.id == updated.id);
    if (index != -1) items[index] = updated;
  }

  void setSearch(String value) => searchQuery.value = value;
  void setStatusFilter(String value) => statusFilter.value = value;

  String _friendly(Object e) =>
      kDebugMode ? e.toString() : 'Please check your connection and try again.';
}
