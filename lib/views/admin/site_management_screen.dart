import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/controllers/admin/site_management_controller.dart';
import 'package:sufyan_portfolio/models/about_content_model.dart';
import 'package:sufyan_portfolio/models/contact_content_model.dart';
import 'package:sufyan_portfolio/models/home_content_model.dart';
import 'package:sufyan_portfolio/widgets/admin_file_field.dart';
import 'package:sufyan_portfolio/widgets/admin_image_field.dart';
import 'package:sufyan_portfolio/widgets/admin_shell.dart';
import 'package:sufyan_portfolio/widgets/admin_ui.dart';

/// Admin > Site Management. Edits the copy and media shown on the public
/// Home hero, About page and Contact page / footer.
class SiteManagementScreen extends StatelessWidget {
  const SiteManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SiteManagementController());

    return AdminShell(
      title: 'Site Management',
      eyebrow: 'Public content',
      trailing: IconButton(
        tooltip: 'Reload from Firebase',
        onPressed: controller.load,
        icon: const Icon(Iconsax.refresh, size: 19),
      ),
      // Only isLoading / loadFailed are read here, so saving a section never
      // rebuilds the tabs (and never wipes what the admin is typing).
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.loadFailed.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Couldn\'t load the site content.', style: AppTextStyles.body()),
                SizedBox(height: 12.h),
                AdminPrimaryButton(label: 'Try again', onPressed: controller.load),
              ],
            ),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    dividerColor: Colors.transparent,
                    labelStyle: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
                    tabs: const [
                      Tab(text: 'Home hero & stats'),
                      Tab(text: 'About page'),
                      Tab(text: 'Contact & social'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _HeroTab(controller: controller),
                    _AboutTab(controller: controller),
                    _ContactTab(controller: controller),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// =============================================================================
// Shared bits
// =============================================================================

class _TabScroll extends StatelessWidget {
  final List<Widget> children;
  const _TabScroll({required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(22.w, 20.h, 22.w, 36.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 960.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _SaveRow extends StatelessWidget {
  final SiteManagementController controller;
  final String section;
  final String label;
  final VoidCallback onSave;

  const _SaveRow({
    required this.controller,
    required this.section,
    required this.label,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Obx(
        () => AdminPrimaryButton(
          label: label,
          icon: Iconsax.tick_circle,
          loading: controller.saving.value == section,
          onPressed: controller.saving.value.isEmpty ? onSave : null,
        ),
      ),
    );
  }
}

SizedBox get _gap => SizedBox(height: 14.h);
SizedBox get _sectionGap => SizedBox(height: 18.h);

// =============================================================================
// HERO + STATS
// =============================================================================

class _StatDraft {
  final String id;
  final TextEditingController label;
  final TextEditingController value;
  String icon;
  bool active;

  _StatDraft({
    required this.id,
    required String label,
    required String value,
    required this.icon,
    required this.active,
  }) : label = TextEditingController(text: label),
       value = TextEditingController(text: value);

  void dispose() {
    label.dispose();
    value.dispose();
  }
}

class _HeroTab extends StatefulWidget {
  final SiteManagementController controller;
  const _HeroTab({required this.controller});

  @override
  State<_HeroTab> createState() => _HeroTabState();
}

class _HeroTabState extends State<_HeroTab> with AutomaticKeepAliveClientMixin {
  static const _iconKeys = ['calendar', 'briefcase', 'code', 'heart', 'star', 'users'];

  final _formKey = GlobalKey<FormState>();
  late final HomeContentModel _home;
  late final TextEditingController _eyebrow;
  late final TextEditingController _headline;
  late final TextEditingController _subHeadline;
  late final TextEditingController _description;
  late final TextEditingController _primaryText;
  late final TextEditingController _primaryRoute;
  late final TextEditingController _secondaryText;
  late final TextEditingController _secondaryRoute;
  late final TextEditingController _image;
  late final TextEditingController _video;
  final List<_StatDraft> _stats = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final h = _home = widget.controller.home.value!;
    _eyebrow = TextEditingController(text: h.eyebrow);
    _headline = TextEditingController(text: h.headline);
    _subHeadline = TextEditingController(text: h.subHeadline);
    _description = TextEditingController(text: h.description);
    _primaryText = TextEditingController(text: h.primaryButtonText);
    _primaryRoute = TextEditingController(text: h.primaryButtonRoute);
    _secondaryText = TextEditingController(text: h.secondaryButtonText);
    _secondaryRoute = TextEditingController(text: h.secondaryButtonRoute);
    _image = TextEditingController(text: h.heroImageUrl);
    _video = TextEditingController(text: h.heroVideoUrl);
    for (final s in widget.controller.stats) {
      _stats.add(
        _StatDraft(id: s.id, label: s.label, value: s.value, icon: s.icon, active: s.active),
      );
    }
  }

  @override
  void dispose() {
    for (final c in [
      _eyebrow, _headline, _subHeadline, _description, _primaryText,
      _primaryRoute, _secondaryText, _secondaryRoute, _image, _video,
    ]) {
      c.dispose();
    }
    for (final s in _stats) {
      s.dispose();
    }
    super.dispose();
  }

  Future<void> _saveHero() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.controller.saveHome(
      HomeContentModel(
        eyebrow: _eyebrow.text.trim(),
        headline: _headline.text.trim(),
        subHeadline: _subHeadline.text.trim(),
        description: _description.text.trim(),
        primaryButtonText: _primaryText.text.trim(),
        primaryButtonRoute: _primaryRoute.text.trim(),
        secondaryButtonText: _secondaryText.text.trim(),
        secondaryButtonRoute: _secondaryRoute.text.trim(),
        heroImageUrl: _image.text.trim(),
        heroVideoUrl: _video.text.trim(),
        updatedAt: _home.updatedAt,
      ),
    );
  }

  Future<void> _saveStats() async {
    final cleaned = <HomeStatModel>[];
    for (var i = 0; i < _stats.length; i++) {
      final d = _stats[i];
      if (d.label.text.trim().isEmpty || d.value.text.trim().isEmpty) {
        adminSnack('Stat ${i + 1} is incomplete', 'Give every stat a label and a value.', error: true);
        return;
      }
      cleaned.add(
        HomeStatModel(
          id: d.id,
          label: d.label.text.trim(),
          value: d.value.text.trim(),
          icon: d.icon,
          sortOrder: i + 1,
          active: d.active,
        ),
      );
    }
    await widget.controller.saveStats(cleaned);
  }

  void _addStat() {
    setState(() {
      _stats.add(
        _StatDraft(
          id: 'stat_${DateTime.now().millisecondsSinceEpoch}',
          label: '',
          value: '',
          icon: 'star',
          active: true,
        ),
      );
    });
  }

  void _removeStat(int index) {
    late final _StatDraft removed;
    setState(() => removed = _stats.removeAt(index));
    // Dispose after the frame so the removed row's fields have detached.
    WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
  }

  void _moveStat(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= _stats.length) return;
    setState(() {
      final item = _stats.removeAt(index);
      _stats.insert(target, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return _TabScroll(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminCard(
                title: 'Hero copy',
                subtitle: 'The first thing visitors read on the home page.',
                child: Column(
                  children: [
                    AdminTwoCol(
                      left: AdminTextField(controller: _eyebrow, label: 'Eyebrow', hint: "Hi, I'm"),
                      right: AdminTextField(controller: _headline, label: 'Headline', required: true),
                    ),
                    _gap,
                    AdminTextField(controller: _subHeadline, label: 'Sub-headline'),
                    _gap,
                    AdminTextField(controller: _description, label: 'Description', maxLines: 4),
                  ],
                ),
              ),
              _sectionGap,
              AdminCard(
                title: 'Call-to-action buttons',
                subtitle: 'Routes are in-app paths such as /hire-us or /projects.',
                child: Column(
                  children: [
                    AdminTwoCol(
                      left: AdminTextField(controller: _primaryText, label: 'Primary button text'),
                      right: AdminTextField(controller: _primaryRoute, label: 'Primary button route'),
                    ),
                    _gap,
                    AdminTwoCol(
                      left: AdminTextField(controller: _secondaryText, label: 'Secondary button text'),
                      right: AdminTextField(controller: _secondaryRoute, label: 'Secondary button route'),
                    ),
                  ],
                ),
              ),
              _sectionGap,
              AdminCard(
                title: 'Hero media',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdminImageField(
                      label: 'Hero image',
                      controller: _image,
                      folder: 'portfolio/site/hero',
                    ),
                    _gap,
                    AdminTextField(
                      controller: _video,
                      label: 'Hero video URL (optional)',
                      hint: 'https://…',
                    ),
                  ],
                ),
              ),
              _sectionGap,
              _SaveRow(
                controller: widget.controller,
                section: 'hero',
                label: 'Save hero section',
                onSave: _saveHero,
              ),
            ],
          ),
        ),
        SizedBox(height: 28.h),
        AdminCard(
          title: 'Hero stats',
          subtitle: 'The home hero shows the first 4 active stats, in this order.',
          trailing: AdminOutlineButton(label: 'Add stat', icon: Icons.add_rounded, onPressed: _addStat),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_stats.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    'No stats saved yet — the site is showing its built-in defaults. Add stats to replace them.',
                    style: AppTextStyles.body(),
                  ),
                ),
              for (var i = 0; i < _stats.length; i++)
                Padding(
                  key: ValueKey(_stats[i].id),
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        AdminTwoCol(
                          left: AdminTextField(controller: _stats[i].label, label: 'Label', hint: 'Projects Completed'),
                          right: AdminTextField(controller: _stats[i].value, label: 'Value', hint: '15+'),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            SizedBox(
                              width: 160.w,
                              child: DropdownButtonFormField<String>(
                                initialValue: _iconKeys.contains(_stats[i].icon) ? _stats[i].icon : 'star',
                                items: [
                                  for (final key in _iconKeys)
                                    DropdownMenuItem(value: key, child: Text(key)),
                                ],
                                onChanged: (v) => _stats[i].icon = v ?? 'star',
                                decoration: adminInputDecoration('Icon'),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text('Active', style: AppTextStyles.small()),
                            Switch.adaptive(
                              value: _stats[i].active,
                              activeThumbColor: AppColors.primary,
                              onChanged: (v) => setState(() => _stats[i].active = v),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'Move up',
                              onPressed: i == 0 ? null : () => _moveStat(i, -1),
                              icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                            ),
                            IconButton(
                              tooltip: 'Move down',
                              onPressed: i == _stats.length - 1 ? null : () => _moveStat(i, 1),
                              icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                            ),
                            IconButton(
                              tooltip: 'Remove',
                              onPressed: () => _removeStat(i),
                              icon: Icon(Iconsax.trash, size: 18.sp, color: AppColors.danger),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              _gap,
              _SaveRow(
                controller: widget.controller,
                section: 'stats',
                label: 'Save stats',
                onSave: _saveStats,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// ABOUT
// =============================================================================

class _JourneyDraft {
  final TextEditingController title;
  final TextEditingController period;
  final TextEditingController description;

  _JourneyDraft({required String title, required String period, required String description})
    : title = TextEditingController(text: title),
      period = TextEditingController(text: period),
      description = TextEditingController(text: description);

  void dispose() {
    title.dispose();
    period.dispose();
    description.dispose();
  }
}

class _AboutTab extends StatefulWidget {
  final SiteManagementController controller;
  const _AboutTab({required this.controller});

  @override
  State<_AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<_AboutTab> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  late final AboutContentModel _about;
  late final TextEditingController _eyebrow;
  late final TextEditingController _title;
  late final TextEditingController _subtitle;
  late final TextEditingController _description;
  late final TextEditingController _signature;
  late final TextEditingController _availability;
  late final TextEditingController _image;
  late final TextEditingController _resume;
  late final TextEditingController _traits;
  late final TextEditingController _capabilities;
  final List<_JourneyDraft> _journey = [];

  /// Journey titles become Firebase keys, which can't contain these.
  static final _illegalKeyChars = RegExp(r'[.$#\[\]/]');

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final a = _about = widget.controller.about.value!;
    _eyebrow = TextEditingController(text: a.eyebrow);
    _title = TextEditingController(text: a.title);
    _subtitle = TextEditingController(text: a.subtitle);
    _description = TextEditingController(text: a.description);
    _signature = TextEditingController(text: a.signature);
    _availability = TextEditingController(text: a.availabilityLabel);
    _image = TextEditingController(text: a.imageUrl);
    _resume = TextEditingController(text: a.resumeUrl);
    _traits = TextEditingController(text: a.traits.join('\n'));
    _capabilities = TextEditingController(text: a.capabilities.join('\n'));
    for (final j in a.journey) {
      _journey.add(_JourneyDraft(title: j.title, period: j.period, description: j.description));
    }
  }

  @override
  void dispose() {
    for (final c in [
      _eyebrow, _title, _subtitle, _description, _signature,
      _availability, _image, _resume, _traits, _capabilities,
    ]) {
      c.dispose();
    }
    for (final j in _journey) {
      j.dispose();
    }
    super.dispose();
  }

  List<String> _lines(TextEditingController c) => c.text
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final seen = <String>{};
    final journey = <AboutJourneyItem>[];
    for (var i = 0; i < _journey.length; i++) {
      final d = _journey[i];
      final title = d.title.text.trim();
      if (title.isEmpty) {
        adminSnack('Journey step ${i + 1} needs a title', 'Fill it in or remove the step.', error: true);
        return;
      }
      if (_illegalKeyChars.hasMatch(title)) {
        adminSnack(
          'Step “$title” has a character Firebase can\'t store',
          'Titles can\'t contain  .  \$  #  [  ]  /',
          error: true,
        );
        return;
      }
      if (!seen.add(title.toLowerCase())) {
        adminSnack('Duplicate journey title', '“$title” is used twice — titles must be unique.', error: true);
        return;
      }
      journey.add(
        AboutJourneyItem(
          title: title,
          period: d.period.text.trim(),
          description: d.description.text.trim(),
          sortOrder: i + 1,
        ),
      );
    }

    await widget.controller.saveAbout(
      _about.copyWith(
        eyebrow: _eyebrow.text.trim(),
        title: _title.text.trim(),
        subtitle: _subtitle.text.trim(),
        description: _description.text.trim(),
        signature: _signature.text.trim(),
        availabilityLabel: _availability.text.trim(),
        imageUrl: _image.text.trim(),
        resumeUrl: _resume.text.trim(),
        traits: _lines(_traits),
        capabilities: _lines(_capabilities),
        journey: journey,
      ),
    );
  }

  void _removeStep(int index) {
    late final _JourneyDraft removed;
    setState(() => removed = _journey.removeAt(index));
    WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
  }

  void _moveStep(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= _journey.length) return;
    setState(() {
      final item = _journey.removeAt(index);
      _journey.insert(target, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return _TabScroll(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminCard(
                title: 'Intro',
                child: Column(
                  children: [
                    AdminTwoCol(
                      left: AdminTextField(controller: _eyebrow, label: 'Eyebrow', hint: 'ABOUT ME'),
                      right: AdminTextField(controller: _title, label: 'Title', required: true),
                    ),
                    _gap,
                    AdminTextField(controller: _subtitle, label: 'Subtitle'),
                    _gap,
                    AdminTextField(controller: _description, label: 'About text', maxLines: 6),
                    _gap,
                    AdminTwoCol(
                      left: AdminTextField(controller: _signature, label: 'Signature', hint: 'Sufyan'),
                      right: AdminTextField(
                        controller: _availability,
                        label: 'Availability badge',
                        hint: 'Available for Opportunities',
                      ),
                    ),
                  ],
                ),
              ),
              _sectionGap,
              AdminCard(
                title: 'Portrait',
                child: AdminImageField(
                  label: 'About image',
                  controller: _image,
                  folder: 'portfolio/site/about',
                ),
              ),
              _sectionGap,
              AdminCard(
                title: 'Resume (PDF)',
                subtitle:
                    'Powers the "Download Resume" button on the About page. Leave empty to hide the button.',
                child: AdminFileField(
                  label: 'Resume URL',
                  controller: _resume,
                  folder: 'portfolio/site/resume',
                ),
              ),
              _sectionGap,
              AdminCard(
                title: 'Traits & capabilities',
                subtitle: 'One item per line.',
                child: Column(
                  children: [
                    AdminTextField(controller: _traits, label: 'Traits', maxLines: 5, hint: 'Clean Code\nProblem Solver'),
                    _gap,
                    AdminTextField(
                      controller: _capabilities,
                      label: 'Capabilities',
                      maxLines: 7,
                      hint: 'Mobile App Development (Flutter)\nAPI Integration',
                    ),
                  ],
                ),
              ),
              _sectionGap,
              AdminCard(
                title: 'My journey',
                subtitle: 'Shown as a timeline, in this order.',
                trailing: AdminOutlineButton(
                  label: 'Add step',
                  icon: Icons.add_rounded,
                  onPressed: () => setState(
                    () => _journey.add(_JourneyDraft(title: '', period: '', description: '')),
                  ),
                ),
                child: Column(
                  children: [
                    if (_journey.isEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('No steps yet.', style: AppTextStyles.body()),
                      ),
                    for (var i = 0; i < _journey.length; i++)
                      Padding(
                        key: ObjectKey(_journey[i]),
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSoft,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              AdminTwoCol(
                                left: AdminTextField(controller: _journey[i].title, label: 'Title'),
                                right: AdminTextField(controller: _journey[i].period, label: 'Period', hint: '2024 — Present'),
                              ),
                              SizedBox(height: 10.h),
                              AdminTextField(controller: _journey[i].description, label: 'Description', maxLines: 2),
                              SizedBox(height: 6.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    tooltip: 'Move up',
                                    onPressed: i == 0 ? null : () => _moveStep(i, -1),
                                    icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                                  ),
                                  IconButton(
                                    tooltip: 'Move down',
                                    onPressed: i == _journey.length - 1 ? null : () => _moveStep(i, 1),
                                    icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                                  ),
                                  IconButton(
                                    tooltip: 'Remove',
                                    onPressed: () => _removeStep(i),
                                    icon: Icon(Iconsax.trash, size: 18.sp, color: AppColors.danger),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _sectionGap,
              _SaveRow(
                controller: widget.controller,
                section: 'about',
                label: 'Save About page',
                onSave: _save,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CONTACT + SOCIAL
// =============================================================================

class _ContactTab extends StatefulWidget {
  final SiteManagementController controller;
  const _ContactTab({required this.controller});

  @override
  State<_ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<_ContactTab> with AutomaticKeepAliveClientMixin {
  /// Keys the public Contact page and footer already understand.
  static const _socials = <String, String>{
    'github': 'GitHub',
    'linkedin': 'LinkedIn',
    'x': 'X (Twitter)',
    'instagram': 'Instagram',
    'facebook': 'Facebook',
    'whatsapp': 'WhatsApp',
    'website': 'Website',
  };

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _eyebrow;
  late final TextEditingController _title;
  late final TextEditingController _subtitle;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _location;
  late final TextEditingController _hours;
  late final String _imageUrl;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  late final TextEditingController _zoom;
  final Map<String, TextEditingController> _links = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final c = widget.controller.contact.value!;
    _eyebrow = TextEditingController(text: c.eyebrow);
    _title = TextEditingController(text: c.title);
    _subtitle = TextEditingController(text: c.subtitle);
    _email = TextEditingController(text: c.email);
    _phone = TextEditingController(text: c.phone);
    _location = TextEditingController(text: c.location);
    _hours = TextEditingController(text: c.workingHours);
    _imageUrl = c.imageUrl;
    _lat = TextEditingController(text: c.latitude.toString());
    _lng = TextEditingController(text: c.longitude.toString());
    _zoom = TextEditingController(text: c.mapZoom.toString());
    for (final key in _socials.keys) {
      _links[key] = TextEditingController(text: c.socialLinks[key] ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in [_eyebrow, _title, _subtitle, _email, _phone, _location, _hours, _lat, _lng, _zoom]) {
      c.dispose();
    }
    for (final c in _links.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final lat = double.tryParse(_lat.text.trim());
    final lng = double.tryParse(_lng.text.trim());
    final zoom = double.tryParse(_zoom.text.trim());
    if (lat == null || lat < -90 || lat > 90) {
      adminSnack('Check the latitude', 'Use a number between -90 and 90, e.g. 31.5204', error: true);
      return;
    }
    if (lng == null || lng < -180 || lng > 180) {
      adminSnack('Check the longitude', 'Use a number between -180 and 180, e.g. 74.3587', error: true);
      return;
    }
    if (zoom == null || zoom < 3 || zoom > 18) {
      adminSnack('Check the map zoom', 'Use a number between 3 (world) and 18 (street).', error: true);
      return;
    }

    final links = <String, String>{
      for (final entry in _links.entries)
        if (entry.value.text.trim().isNotEmpty) entry.key: entry.value.text.trim(),
    };

    await widget.controller.saveContact(
      ContactContentModel(
        eyebrow: _eyebrow.text.trim(),
        title: _title.text.trim(),
        subtitle: _subtitle.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        location: _location.text.trim(),
        workingHours: _hours.text.trim(),
        imageUrl: _imageUrl,
        latitude: lat,
        longitude: lng,
        mapZoom: zoom,
        socialLinks: links,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return _TabScroll(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminCard(
                title: 'Contact page heading',
                child: Column(
                  children: [
                    AdminTwoCol(
                      left: AdminTextField(controller: _eyebrow, label: 'Eyebrow', hint: 'GET IN TOUCH'),
                      right: AdminTextField(controller: _title, label: 'Title', required: true),
                    ),
                    _gap,
                    AdminTextField(controller: _subtitle, label: 'Subtitle', maxLines: 3),
                  ],
                ),
              ),
              _sectionGap,
              AdminCard(
                title: 'Contact details',
                subtitle: 'Also used in the site footer.',
                child: Column(
                  children: [
                    AdminTwoCol(
                      left: AdminTextField(
                        controller: _email,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        required: true,
                      ),
                      right: AdminTextField(
                        controller: _phone,
                        label: 'Phone',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    _gap,
                    AdminTwoCol(
                      left: AdminTextField(controller: _location, label: 'Location'),
                      right: AdminTextField(controller: _hours, label: 'Working hours'),
                    ),
                  ],
                ),
              ),
              _sectionGap,
              AdminCard(
                title: 'Map location',
                subtitle:
                    'Shown as an interactive map on the Contact page. In Google Maps, right-click your spot and click the coordinates to copy them.',
                child: Column(
                  children: [
                    AdminTwoCol(
                      left: AdminTextField(
                        controller: _lat,
                        label: 'Latitude',
                        hint: '31.5204',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                      right: AdminTextField(
                        controller: _lng,
                        label: 'Longitude',
                        hint: '74.3587',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                    _gap,
                    AdminTextField(
                      controller: _zoom,
                      label: 'Zoom (3 = world, 18 = street)',
                      hint: '13',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
              _sectionGap,
              AdminCard(
                title: 'Social links',
                subtitle: 'Leave a field empty to hide that icon.',
                child: Column(
                  children: [
                    for (final entry in _socials.entries)
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: AdminTextField(
                          controller: _links[entry.key]!,
                          label: entry.value,
                          hint: 'https://…',
                          keyboardType: TextInputType.url,
                        ),
                      ),
                  ],
                ),
              ),
              _sectionGap,
              _SaveRow(
                controller: widget.controller,
                section: 'contact',
                label: 'Save contact details',
                onSave: _save,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
