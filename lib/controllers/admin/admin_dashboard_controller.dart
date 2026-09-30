import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/services/firebase_auth_service.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

class DashboardMetric {
  final String label;
  final String subtitle;
  final int value;
  final IconData icon;
  final String route;

  const DashboardMetric({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.route,
  });
}

class DashboardActivity {
  final String title;
  final String subtitle;
  final String timeLabel;
  final IconData icon;
  final String route;
  final int timestamp;

  const DashboardActivity({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.icon,
    required this.route,
    required this.timestamp,
  });
}

class AdminDashboardController extends GetxController {
  final RealtimeDbService _db = RealtimeDbService.instance;
  final FirebaseAuthService _auth = FirebaseAuthService.instance;

  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final errorMessage = RxnString();

  final metrics = <DashboardMetric>[].obs;
  final activities = <DashboardActivity>[].obs;

  String displayName = 'Administrator';
  String email = '';
  String role = 'superAdmin';

  @override
  void onInit() {
    super.onInit();
    _hydrateUser();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (!await ensureAdminAccess()) return;
    await loadDashboard();
  }

  Future<bool> ensureAdminAccess() async {
    if (!_auth.isLoggedIn) {
      Get.offAllNamed(AppRoutes.login);
      return false;
    }

    try {
      final profile = await _auth.loadProfile();
      final profileRole = profile?['role']?.toString().toLowerCase();
      final active = profile?['active'] == true ||
          profile?['active']?.toString().toLowerCase() == 'true';
      final allowed = active &&
          (profileRole == 'superadmin' || profileRole == 'admin');

      if (!allowed) {
        await _auth.signOut();
        Get.offAllNamed(AppRoutes.accessDeniedScreen);
        return false;
      }

      role = profile?['role']?.toString() ?? 'superAdmin';
      return true;
    } catch (e) {
      debugPrint('Admin access check failed: $e');
      await _auth.signOut();
      Get.offAllNamed(AppRoutes.login);
      return false;
    }
  }

  void _hydrateUser() {
    final user = _auth.currentUser;
    displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Administrator';
    email = user?.email ?? '';
  }

  Future<void> loadDashboard({bool refresh = false}) async {
    if (refresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    errorMessage.value = null;

    try {
      final results = await Future.wait([
        _safeCollection('projects'),
        _safeCollection('services'),
        _safeCollection('skills'),
        _safeCollection('packages'),
        _safeCollection('experiences'),
        _safeCollection('hireRequests'),
        _safeCollection('consultations'),
        _safeCollection('contactMessages'),
        _safeCollection('testimonials'),
      ]);

      final projects = results[0];
      final services = results[1];
      final skills = results[2];
      final packages = results[3];
      final experiences = results[4];
      final hireRequests = results[5];
      final consultations = results[6];
      final contactMessages = results[7];
      final testimonials = results[8];

      metrics.assignAll([
        DashboardMetric(
          label: 'Projects',
          subtitle: 'Published work',
          value: _publishedCount(projects),
          icon: Icons.grid_view_rounded,
          route: AppRoutes.projectManagement,
        ),
        DashboardMetric(
          label: 'Services',
          subtitle: 'Active offerings',
          value: _publishedCount(services),
          icon: Icons.design_services_rounded,
          route: AppRoutes.serviceManagement,
        ),
        DashboardMetric(
          label: 'Skills',
          subtitle: 'Listed capabilities',
          value: _publishedCount(skills),
          icon: Icons.auto_awesome_rounded,
          route: AppRoutes.skillManagement,
        ),
        DashboardMetric(
          label: 'Packages',
          subtitle: 'Visible plans',
          value: _publishedCount(packages),
          icon: Icons.sell_rounded,
          route: AppRoutes.packageManagement,
        ),
        DashboardMetric(
          label: 'Experiences',
          subtitle: 'Career entries',
          value: _publishedCount(experiences),
          icon: Icons.timeline_rounded,
          route: AppRoutes.experienceManagement,
        ),
        DashboardMetric(
          label: 'Messages',
          subtitle: 'Contact inbox',
          value: contactMessages.length,
          icon: Icons.mail_outline_rounded,
          route: AppRoutes.contactMessageManagement,
        ),
        DashboardMetric(
          label: 'Hire Requests',
          subtitle: 'Client enquiries',
          value: hireRequests.length,
          icon: Icons.work_outline_rounded,
          route: AppRoutes.hireRequestManagement,
        ),
        DashboardMetric(
          label: 'Consultations',
          subtitle: 'Booked interest',
          value: consultations.length,
          icon: Icons.event_available_outlined,
          route: AppRoutes.consultationManagement,
        ),
        DashboardMetric(
          label: 'Testimonials',
          subtitle: 'Social proof',
          value: _publishedCount(testimonials),
          icon: Icons.format_quote_rounded,
          route: AppRoutes.testimonialManagement,
        ),
      ]);

      final allActivities = <DashboardActivity>[];
      _appendActivities(
        allActivities,
        hireRequests,
        titleKey: 'name',
        fallbackTitle: 'New hire request',
        typeLabel: 'Hire request',
        icon: Icons.work_outline_rounded,
        route: AppRoutes.hireRequestManagement,
      );
      _appendActivities(
        allActivities,
        consultations,
        titleKey: 'name',
        fallbackTitle: 'New consultation',
        typeLabel: 'Consultation',
        icon: Icons.event_available_outlined,
        route: AppRoutes.consultationManagement,
      );
      _appendActivities(
        allActivities,
        contactMessages,
        titleKey: 'name',
        fallbackTitle: 'New contact message',
        typeLabel: 'Contact message',
        icon: Icons.mail_outline_rounded,
        route: AppRoutes.contactMessageManagement,
      );
      _appendActivities(
        allActivities,
        projects,
        titleKey: 'title',
        fallbackTitle: 'Project updated',
        typeLabel: 'Project',
        icon: Icons.grid_view_rounded,
        route: AppRoutes.projectManagement,
      );

      allActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      activities.assignAll(allActivities.take(7));
    } catch (e) {
      errorMessage.value = 'Unable to load dashboard data right now.';
      debugPrint('Dashboard load error: $e');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<Map<String, Map<dynamic, dynamic>>> _safeCollection(String path) async {
    try {
      return await _db.readCollectionOnce(path);
    } catch (e) {
      debugPrint('Dashboard read failed for $path: $e');
      return {};
    }
  }

  int _publishedCount(Map<String, Map<dynamic, dynamic>> data) {
    if (data.isEmpty) return 0;
    return data.values.where((item) {
      final published = item['published'];
      if (published == null) return true;
      return published == true || published.toString().toLowerCase() == 'true';
    }).length;
  }

  void _appendActivities(
    List<DashboardActivity> target,
    Map<String, Map<dynamic, dynamic>> data, {
    required String titleKey,
    required String fallbackTitle,
    required String typeLabel,
    required IconData icon,
    required String route,
  }) {
    for (final item in data.entries) {
      final map = item.value;
      final timestamp = _timestampOf(map['updatedAt'] ?? map['createdAt']);
      final title = (map[titleKey]?.toString().trim().isNotEmpty == true)
          ? map[titleKey].toString().trim()
          : (map['email']?.toString().trim().isNotEmpty == true
                ? map['email'].toString().trim()
                : fallbackTitle);

      target.add(
        DashboardActivity(
          title: title,
          subtitle: typeLabel,
          timeLabel: _relativeTime(timestamp),
          icon: icon,
          route: route,
          timestamp: timestamp,
        ),
      );
    }
  }

  int _timestampOf(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final number = int.tryParse(value);
      if (number != null) return number;
      final parsed = DateTime.tryParse(value)?.millisecondsSinceEpoch;
      if (parsed != null) return parsed;
    }
    if (value is Map && value['.sv'] != null) return 0;
    return 0;
  }

  String _relativeTime(int timestamp) {
    if (timestamp <= 0) return 'Recently';

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
