import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/repositories/contact_repository.dart';
import 'package:sufyan_portfolio/widgets/app_footer.dart';
import 'package:sufyan_portfolio/widgets/public_navbar.dart';

/// ✏️ Update this whenever you change the policy text below.
const String kPrivacyLastUpdated = '15 October 2026';

/// Plain-language privacy policy for the portfolio.
///
/// The contact email is read from Site Management > Contact details, so it
/// always matches the rest of the site. Review the wording below and make sure
/// it matches what you actually do (analytics, cookies, retention) — see the
/// sections list at the bottom of this file.
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final _scroll = ScrollController();
  late final List<GlobalKey> _keys;
  String _email = 'the email address on the Contact page';
  int _active = 0;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(_sections.length, (_) => GlobalKey());
    _loadEmail();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadEmail() async {
    try {
      final content = await ContactRepository.instance.getContent();
      if (content.email.trim().isNotEmpty && mounted) {
        setState(() => _email = content.email.trim());
      }
    } catch (_) {
      // Keep the generic wording.
    }
  }

  void _jumpTo(int index) {
    setState(() => _active = index);
    final context = _keys[index].currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
      alignment: 0.04,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 1000;
    final horizontal = wide ? 64.w : 20.w;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PublicNavbar(activeRoute: AppRoutes.privacyPolicy),
      body: SingleChildScrollView(
        controller: _scroll,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(horizontal, wide ? 54.h : 36.h, horizontal, 70.h),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1240.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(wide: wide),
                      SizedBox(height: 30.h),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 270.w,
                              child: _Toc(active: _active, onTap: _jumpTo),
                            ),
                            SizedBox(width: 34.w),
                            Expanded(child: _body()),
                          ],
                        )
                      else ...[
                        _Toc(active: _active, onTap: _jumpTo),
                        SizedBox(height: 22.h),
                        _body(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [
        for (var i = 0; i < _sections.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _SectionCard(
              key: _keys[i],
              number: i + 1,
              section: _sections[i],
              email: _email,
            )
                .animate()
                .fadeIn(delay: (70 * i).ms, duration: 400.ms)
                .slideY(begin: .05, end: 0, delay: (70 * i).ms),
          ),
        SizedBox(height: 4.h),
        _QuestionsCard(email: _email),
      ],
    );
  }
}

// =============================================================================
// Pieces
// =============================================================================

class _Header extends StatelessWidget {
  final bool wide;
  const _Header({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(wide ? 34.w : 24.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(26.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LEGAL', style: AppTextStyles.overline(color: AppColors.accentGold)),
                SizedBox(height: 10.h),
                Text(
                  'Privacy Policy',
                  style: AppTextStyles.h1(color: Colors.white).copyWith(fontSize: wide ? 46.sp : 34.sp),
                ),
                SizedBox(height: 10.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 640.w),
                  child: Text(
                    'What I collect when you use this site, why I collect it, and the choices you have. Short and in plain language.',
                    style: AppTextStyles.body(color: Colors.white.withValues(alpha: .78)),
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Last updated: $kPrivacyLastUpdated',
                    style: AppTextStyles.small(color: Colors.white).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          if (wide) ...[
            SizedBox(width: 30.w),
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .08),
              ),
              child: Icon(Icons.shield_outlined, size: 56.sp, color: AppColors.accentGold),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: -6, end: 6, duration: 2400.ms, curve: Curves.easeInOut),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: .03, end: 0);
  }
}

class _Toc extends StatelessWidget {
  final int active;
  final ValueChanged<int> onTap;
  const _Toc({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 10.h),
            child: Text('ON THIS PAGE', style: AppTextStyles.overline()),
          ),
          for (var i = 0; i < _sections.length; i++)
            _TocItem(
              label: '${i + 1}. ${_sections[i].title}',
              active: active == i,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _TocItem extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TocItem({required this.label, required this.active, required this.onTap});

  @override
  State<_TocItem> createState() => _TocItemState();
}

class _TocItemState extends State<_TocItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final highlight = widget.active || _hover;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: widget.active
                ? AppColors.primarySoft
                : (_hover ? AppColors.surfaceSoft : Colors.transparent),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.small(
              color: highlight ? AppColors.primary : AppColors.textSecondary,
            ).copyWith(
              fontWeight: widget.active ? FontWeight.w800 : FontWeight.w600,
              fontSize: 12.5.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final int number;
  final _Section section;
  final String email;
  const _SectionCard({
    super.key,
    required this.number,
    required this.section,
    required this.email,
  });

  String _fill(String text) => text.replaceAll('{email}', email);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(section.icon, size: 19.sp, color: AppColors.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  '$number. ${section.title}',
                  style: AppTextStyles.h3().copyWith(fontSize: 20.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          for (final block in section.blocks)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: block.bullets.isEmpty
                  ? Text(
                      _fill(block.text),
                      style: AppTextStyles.body().copyWith(height: 1.7, fontSize: 14.5.sp),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (block.text.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Text(
                              _fill(block.text),
                              style: AppTextStyles.body().copyWith(height: 1.7, fontSize: 14.5.sp),
                            ),
                          ),
                        for (final bullet in block.bullets)
                          Padding(
                            padding: EdgeInsets.only(bottom: 6.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 8.h, right: 10.w),
                                  child: Container(
                                    width: 6.w,
                                    height: 6.w,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.accentGold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _fill(bullet),
                                    style: AppTextStyles.body().copyWith(height: 1.65, fontSize: 14.5.sp),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}

class _QuestionsCard extends StatelessWidget {
  final String email;
  const _QuestionsCard({required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Questions about your data?', style: AppTextStyles.h3().copyWith(fontSize: 19.sp)),
                SizedBox(height: 4.h),
                Text(
                  'Write to $email and I’ll reply personally.',
                  style: AppTextStyles.body(),
                ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.contactUs),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: const Text('Contact me'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// POLICY TEXT — edit the content below
// =============================================================================

class _Block {
  final String text;
  final List<String> bullets;
  const _Block(this.text, {this.bullets = const []});
}

class _Section {
  final String title;
  final IconData icon;
  final List<_Block> blocks;
  const _Section(this.title, this.icon, this.blocks);
}

const List<_Section> _sections = [
  _Section('Who I am', Icons.person_outline_rounded, [
    _Block(
      'This website is my personal portfolio. I’m the person responsible for the information you share through it. You can reach me at {email}.',
    ),
  ]),
  _Section('What I collect', Icons.inventory_2_outlined, [
    _Block(
      'I only collect what you choose to send me through the forms on this site:',
      bullets: [
        'Hire Me form: your name, company, email, phone, project details, budget, timeline, preferred platform and contact method, reference links and any files you attach.',
        'Consultation form: your name, email, consultation topic, message, preferred date and time, and any files you attach.',
        'Contact form: your name, email, subject and message.',
        'Newsletter: your email address.',
      ],
    ),
    _Block(
      'I don’t ask for payment details, ID numbers or other sensitive information through this site, and I’d ask you not to send them.',
    ),
  ]),
  _Section('How I use it', Icons.tune_rounded, [
    _Block(
      'Your information is used only to:',
      bullets: [
        'reply to your message, quote or consultation request;',
        'plan and deliver work if we decide to work together;',
        'send newsletter updates, if you subscribed (you can unsubscribe at any time);',
        'keep this site secure and working properly.',
      ],
    ),
    _Block('I don’t sell or rent your personal information, and I don’t use it for advertising.'),
  ]),
  _Section('Who else handles your data', Icons.cloud_outlined, [
    _Block('To run this site I rely on a few service providers who process data on my behalf:'),
    _Block(
      '',
      bullets: [
        'Google Firebase stores form submissions and site content, and handles admin sign-in.',
        'Cloudinary stores images and files that are uploaded through the site, such as reference attachments.',
        'Your own email app opens when you choose to email me from a link.',
      ],
    ),
    _Block(
      'These providers may process data in countries other than your own. They are bound by their own privacy and security commitments.',
    ),
  ]),
  _Section('How long I keep it', Icons.schedule_rounded, [
    _Block(
      'I keep messages and project details for as long as they’re needed to respond to you and to deliver and support any work we do together, and afterwards only for as long as I have a genuine reason (for example, a record of what was agreed). Newsletter emails are kept until you unsubscribe.',
    ),
  ]),
  _Section('Cookies and local storage', Icons.cookie_outlined, [
    _Block(
      'This site doesn’t use advertising or cross-site tracking cookies. Your browser may store small technical data, such as remembering a preference, so the site works smoothly. You can clear it at any time in your browser settings.',
    ),
  ]),
  _Section('Your choices', Icons.how_to_reg_outlined, [
    _Block(
      'Depending on where you live, you may have the right to:',
      bullets: [
        'ask what personal information I hold about you;',
        'ask me to correct it;',
        'ask me to delete it;',
        'withdraw consent, for example by unsubscribing from the newsletter.',
      ],
    ),
    _Block('Email {email} with your request and I’ll respond as soon as I can.'),
  ]),
  _Section('Security', Icons.lock_outline_rounded, [
    _Block(
      'The site is served over HTTPS and access to submissions is limited to my admin account. No system is perfectly secure, but I take reasonable steps to protect what you send me.',
    ),
  ]),
  _Section('Children', Icons.child_care_outlined, [
    _Block(
      'This site is meant for people who are 16 or older and isn’t aimed at children. If you believe a child has sent me personal information, please tell me and I’ll delete it.',
    ),
  ]),
  _Section('Changes to this policy', Icons.update_rounded, [
    _Block(
      'If I change how I handle information, I’ll update this page and the “last updated” date at the top. Please check back occasionally.',
    ),
  ]),
];
