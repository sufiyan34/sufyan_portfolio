import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/contact_content_model.dart';
import 'package:sufyan_portfolio/repositories/contact_repository.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';

/// Admin inbox controller for the `contactMessages/` node.
class ContactMessageManagementController extends GetxController {
  final _repo = ContactRepository.instance;

  final RxList<ContactMessageModel> messages = <ContactMessageModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;

  int countOf(String status) => messages.where((m) => m.status == status).length;

  List<ContactMessageModel> get filtered {
    final query = searchQuery.value.trim().toLowerCase();
    final status = statusFilter.value;
    return messages.where((m) {
      final matchesStatus = status == 'all'
          ? m.status != ContactMessageStatuses.archived
          : m.status == status;
      final matchesQuery =
          query.isEmpty ||
          m.name.toLowerCase().contains(query) ||
          m.email.toLowerCase().contains(query) ||
          m.subject.toLowerCase().contains(query) ||
          m.message.toLowerCase().contains(query);
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
      messages.value = await _repo.getMessages();
    } catch (e) {
      adminSnack('Couldn\'t load messages', _friendly(e), error: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setStatus(
    ContactMessageModel message,
    String status, {
    bool silent = false,
  }) async {
    if (message.status == status) return;
    try {
      await _repo.updateMessageStatus(message.id, status);
      final index = messages.indexWhere((m) => m.id == message.id);
      if (index != -1) messages[index] = message.copyWith(status: status);
      if (!silent) adminSnack('Marked ${ContactMessageStatuses.label(status).toLowerCase()}', message.subject);
    } catch (e) {
      if (!silent) adminSnack('Couldn\'t update message', _friendly(e), error: true);
    }
  }

  /// Opening a message marks a `new` one as read.
  Future<void> markOpened(ContactMessageModel message) async {
    if (message.status == ContactMessageStatuses.newMessage) {
      await setStatus(message, ContactMessageStatuses.read, silent: true);
    }
  }

  Future<bool> delete(ContactMessageModel message) async {
    try {
      await _repo.deleteMessage(message.id);
      messages.removeWhere((m) => m.id == message.id);
      adminSnack('Message deleted', message.subject);
      return true;
    } catch (e) {
      adminSnack('Couldn\'t delete message', _friendly(e), error: true);
      return false;
    }
  }

  void setSearch(String value) => searchQuery.value = value;
  void setStatusFilter(String value) => statusFilter.value = value;

  String _friendly(Object e) =>
      kDebugMode ? e.toString() : 'Please check your connection and try again.';
}
