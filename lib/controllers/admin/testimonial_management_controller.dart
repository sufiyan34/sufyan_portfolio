import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/testimonial_model.dart';
import 'package:sufyan_portfolio/repositories/testimonial_repository.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';

/// Admin CRUD controller for client testimonials.
class TestimonialManagementController extends GetxController {
  final _repo = TestimonialRepository.instance;

  final RxList<TestimonialModel> items = <TestimonialModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString searchQuery = ''.obs;

  /// all | published | hidden | featured
  final RxString filter = 'all'.obs;

  int get publishedCount => items.where((t) => t.published).length;
  int get featuredCount => items.where((t) => t.featured).length;
  String get averageRating {
    if (items.isEmpty) return '–';
    final avg = items.fold<int>(0, (sum, t) => sum + t.rating) / items.length;
    return avg.toStringAsFixed(1);
  }

  List<TestimonialModel> get filtered {
    final query = searchQuery.value.trim().toLowerCase();
    return items.where((t) {
      final matchesFilter = switch (filter.value) {
        'published' => t.published,
        'hidden' => !t.published,
        'featured' => t.featured,
        _ => true,
      };
      final matchesQuery =
          query.isEmpty ||
          t.clientName.toLowerCase().contains(query) ||
          t.company.toLowerCase().contains(query) ||
          t.projectName.toLowerCase().contains(query) ||
          t.quote.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
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
      adminSnack('Couldn\'t load testimonials', _friendly(e), error: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> save(TestimonialModel draft) async {
    isSaving.value = true;
    try {
      if (draft.id.isEmpty) {
        items.add(await _repo.add(draft));
      } else {
        await _repo.update(draft);
        final index = items.indexWhere((t) => t.id == draft.id);
        if (index != -1) items[index] = draft;
      }
      items.sort(_sort);
      items.refresh();
      adminSnack(
        draft.id.isEmpty ? 'Testimonial added' : 'Testimonial updated',
        draft.clientName,
      );
      return true;
    } catch (e) {
      adminSnack('Couldn\'t save testimonial', _friendly(e), error: true);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> togglePublished(TestimonialModel item) async {
    final next = !item.published;
    try {
      await _repo.setPublished(item.id, next);
      final index = items.indexWhere((t) => t.id == item.id);
      if (index != -1) items[index] = item.copyWith(published: next);
      adminSnack(
        next ? 'Published' : 'Hidden from site',
        item.clientName,
      );
    } catch (e) {
      adminSnack('Couldn\'t update visibility', _friendly(e), error: true);
    }
  }

  Future<void> delete(TestimonialModel item) async {
    try {
      await _repo.delete(item.id);
      items.removeWhere((t) => t.id == item.id);
      adminSnack('Testimonial deleted', item.clientName);
    } catch (e) {
      adminSnack('Couldn\'t delete testimonial', _friendly(e), error: true);
    }
  }

  void setSearch(String value) => searchQuery.value = value;
  void setFilter(String value) => filter.value = value;

  static int _sort(TestimonialModel a, TestimonialModel b) {
    final order = a.sortOrder.compareTo(b.sortOrder);
    if (order != 0) return order;
    return a.clientName.toLowerCase().compareTo(b.clientName.toLowerCase());
  }

  String _friendly(Object e) =>
      kDebugMode ? e.toString() : 'Please check your connection and try again.';
}
