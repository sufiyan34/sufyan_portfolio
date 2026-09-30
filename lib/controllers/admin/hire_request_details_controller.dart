import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/hire_request_model.dart';
import 'package:sufyan_portfolio/repositories/hire_request_repository.dart';

class HireRequestDetailsController extends GetxController {
  final _repo = HireRequestRepository.instance;

  final Rx<HireRequestModel?> request = Rx<HireRequestModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  final replyController = TextEditingController();
  final notesController = TextEditingController();
  final offerMessageController = TextEditingController();
  final offerAmountController = TextEditingController();
  final offerDeliveryDaysController = TextEditingController();
  final offerCurrency = 'PKR'.obs;
  final selectedStatus = HireRequestStatuses.newRequest.obs;

  String get requestId {
    final arguments = Get.arguments;
    if (arguments is Map) {
      return arguments['id']?.toString() ?? '';
    }
    return arguments?.toString() ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final id = requestId.trim();
      if (id.isEmpty) {
        throw StateError('Missing hire request id.');
      }

      final value = await _repo.getById(id);
      if (value == null) {
        throw StateError('Hire request not found.');
      }

      request.value = value;
      selectedStatus.value = HireRequestStatuses.normalize(value.status);
      replyController.text = value.replyMessage;
      notesController.text = value.adminNotes;
      offerMessageController.text = value.offerMessage;
      offerAmountController.text = value.offerAmount > 0
          ? _formatAmount(value.offerAmount)
          : '';
      offerDeliveryDaysController.text = value.offerDeliveryDays > 0
          ? value.offerDeliveryDays.toString()
          : '';
      offerCurrency.value = value.offerCurrency.isEmpty
          ? 'PKR'
          : value.offerCurrency;
    } catch (error) {
      errorMessage.value = error is StateError
          ? error.message
          : 'Unable to load this hire request.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> save({bool sendOffer = false}) async {
    final current = request.value;
    if (current == null || isSaving.value) return false;

    isSaving.value = true;
    errorMessage.value = '';

    final amount = double.tryParse(offerAmountController.text.trim()) ?? 0;
    final days = int.tryParse(offerDeliveryDaysController.text.trim()) ?? 0;

    try {
      final status = sendOffer
          ? HireRequestStatuses.proposalSent
          : selectedStatus.value;

      await _repo.updateResponse(
        id: current.id,
        replyMessage: replyController.text,
        adminNotes: notesController.text,
        offerAmount: amount,
        offerCurrency: offerCurrency.value,
        offerDeliveryDays: days,
        offerMessage: offerMessageController.text,
        offerSent: sendOffer,
        status: status,
      );

      await load();
      return true;
    } catch (_) {
      errorMessage.value = 'Unable to save the request response.';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  String buildEmailBody() {
    final current = request.value;
    if (current == null) return '';

    final reply = replyController.text.trim();
    final offer = offerMessageController.text.trim();
    final amount = offerAmountController.text.trim();
    final days = offerDeliveryDaysController.text.trim();

    return [
      'Hello ${current.name},',
      '',
      if (reply.isNotEmpty) reply,
      if (offer.isNotEmpty) ...[
        '',
        'Proposal:',
        offer,
      ],
      if (amount.isNotEmpty)
        'Estimated offer: ${offerCurrency.value} $amount',
      if (days.isNotEmpty) 'Estimated delivery: $days days',
      '',
      'Regards,',
      'Muhammad Sufyan',
    ].join('\n');
  }

  String _formatAmount(double value) {
    return value % 1 == 0
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }

  @override
  void onClose() {
    replyController.dispose();
    notesController.dispose();
    offerMessageController.dispose();
    offerAmountController.dispose();
    offerDeliveryDaysController.dispose();
    super.onClose();
  }
}
