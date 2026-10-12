import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:sufyan_portfolio/models/about_content_model.dart';
import 'package:sufyan_portfolio/models/contact_content_model.dart';
import 'package:sufyan_portfolio/models/home_content_model.dart';
import 'package:sufyan_portfolio/repositories/about_content_repository.dart';
import 'package:sufyan_portfolio/repositories/contact_repository.dart';
import 'package:sufyan_portfolio/repositories/home_content_repository.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';

/// Admin controller behind Site Management. Edits the three public content
/// nodes: `homeContent`, `aboutContent` and `contactContent`.
class SiteManagementController extends GetxController {
  final _homeRepo = HomeContentRepository.instance;
  final _aboutRepo = AboutContentRepository.instance;
  final _contactRepo = ContactRepository.instance;

  final Rxn<HomeContentModel> home = Rxn<HomeContentModel>();
  final RxList<HomeStatModel> stats = <HomeStatModel>[].obs;
  final Rxn<AboutContentModel> about = Rxn<AboutContentModel>();
  final Rxn<ContactContentModel> contact = Rxn<ContactContentModel>();

  final RxBool isLoading = true.obs;
  final RxBool loadFailed = false.obs;

  /// Which section is currently saving: `hero`, `stats`, `about`, `contact`.
  final RxString saving = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    loadFailed.value = false;
    try {
      final results = await Future.wait([
        _homeRepo.getHomeContent(),
        _homeRepo.getAllStats(),
        _aboutRepo.getContent(),
        _contactRepo.getContent(),
      ]);
      home.value = results[0] as HomeContentModel;
      stats.value = results[1] as List<HomeStatModel>;
      about.value = results[2] as AboutContentModel;
      contact.value = results[3] as ContactContentModel;
    } catch (e) {
      loadFailed.value = true;
      adminSnack('Couldn\'t load site content', _friendly(e), error: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveHome(HomeContentModel content) async {
    return _run('hero', () async {
      await _homeRepo.updateHomeContent(content);
      home.value = content;
    }, 'Hero section saved');
  }

  /// Replaces the stored stats with [edited]: removed rows are deleted,
  /// the rest are written with their new order.
  Future<bool> saveStats(List<HomeStatModel> edited) async {
    return _run('stats', () async {
      final keepIds = edited.map((s) => s.id).toSet();
      for (final old in stats) {
        if (!keepIds.contains(old.id)) await _homeRepo.deleteStat(old.id);
      }
      for (final stat in edited) {
        await _homeRepo.upsertStat(stat);
      }
      stats.value = edited;
    }, 'Hero stats saved');
  }

  Future<bool> saveAbout(AboutContentModel content) async {
    return _run('about', () async {
      await _aboutRepo.updateContent(content);
      about.value = content;
    }, 'About page saved');
  }

  Future<bool> saveContact(ContactContentModel content) async {
    return _run('contact', () async {
      await _contactRepo.saveContent(content);
      contact.value = content;
    }, 'Contact details saved');
  }

  Future<bool> _run(
    String section,
    Future<void> Function() action,
    String successMessage,
  ) async {
    saving.value = section;
    try {
      await action();
      adminSnack(successMessage, 'Live on the public site now.');
      return true;
    } catch (e) {
      adminSnack('Couldn\'t save changes', _friendly(e), error: true);
      return false;
    } finally {
      saving.value = '';
    }
  }

  String _friendly(Object e) =>
      kDebugMode ? e.toString() : 'Please check your connection and try again.';
}
