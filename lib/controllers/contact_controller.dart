import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/contact_content_model.dart';
import 'package:sufyan_portfolio/repositories/contact_repository.dart';

class ContactController extends GetxController {
  final _repo = ContactRepository.instance;

  final Rx<ContactContentModel> content = ContactContentModel.fallback().obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool submitted = false.obs;
  final RxString errorMessage = ''.obs;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      content.value = await _repo.getContent();
    } catch (_) {
      content.value = ContactContentModel.fallback();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => load();

  Future<void> submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isSubmitting.value) return;

    isSubmitting.value = true;
    errorMessage.value = '';
    try {
      await _repo.sendMessage(
        name: nameController.text,
        email: emailController.text,
        subject: subjectController.text,
        message: messageController.text,
      );
      submitted.value = true;
      nameController.clear();
      emailController.clear();
      subjectController.clear();
      messageController.clear();
    } catch (_) {
      errorMessage.value = 'Unable to send your message right now. Please try again.';
    } finally {
      isSubmitting.value = false;
    }
  }

  void startAnotherMessage() => submitted.value = false;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
