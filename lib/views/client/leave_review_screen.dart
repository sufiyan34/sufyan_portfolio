import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_routes.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/models/testimonial_invite_model.dart';
import 'package:sufyan_portfolio/repositories/testimonial_repository.dart';
import 'package:sufyan_portfolio/widgets/app_footer.dart';
import 'package:sufyan_portfolio/widgets/public_navbar.dart';

enum _Phase { loading, ready, invalid, used, expired, error, done }

/// Public page a client reaches through their private invite link
/// (`/leave-a-review?t=<token>`). It validates the invite, lets them write a
/// testimonial, and saves it as *pending* for the admin to review. Nothing
/// they write is shown on the site until it is approved.
class LeaveReviewScreen extends StatefulWidget {
  const LeaveReviewScreen({super.key});

  @override
  State<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  final _repo = TestimonialRepository.instance;
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _role = TextEditingController();
  final _company = TextEditingController();
  final _project = TextEditingController();
  final _quote = TextEditingController();

  static const _minQuote = 30;
  static const _maxQuote = 600;

  late final String _token;
  _Phase _phase = _Phase.loading;
  int _rating = 0;
  bool _consent = false;
  bool _submitting = false;
  String? _formError;
  String _submittedName = '';

  @override
  void initState() {
    super.initState();
    _token = (Get.parameters['t'] ?? Uri.base.queryParameters['t'] ?? '').trim();
    _loadInvite();
  }

  @override
  void dispose() {
    for (final c in [_name, _role, _company, _project, _quote]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInvite() async {
    if (_token.length < 16) {
      setState(() => _phase = _Phase.invalid);
      return;
    }
    setState(() => _phase = _Phase.loading);
    try {
      final TestimonialInviteModel? invite = await _repo.getInvite(_token);
      if (!mounted) return;
      if (invite == null) {
        setState(() => _phase = _Phase.invalid);
      } else if (invite.used) {
        setState(() => _phase = _Phase.used);
      } else if (invite.expired) {
        setState(() => _phase = _Phase.expired);
      } else {
        _name.text = invite.clientName;
        _project.text = invite.projectName;
        setState(() => _phase = _Phase.ready);
      }
    } catch (_) {
      if (mounted) setState(() => _phase = _Phase.error);
    }
  }

  Future<void> _submit() async {
    setState(() => _formError = null);
    final valid = _formKey.currentState!.validate();
    if (_rating == 0) {
      setState(() => _formError = 'Please choose a star rating.');
      return;
    }
    if (!valid) return;
    if (!_consent) {
      setState(() => _formError = 'Please tick the box to confirm you’re happy for this to be shown publicly.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await _repo.submitReview(
        token: _token,
        clientName: _name.text,
        clientRole: _role.text,
        company: _company.text,
        projectName: _project.text,
        quote: _quote.text,
        rating: _rating,
      );
      if (!mounted) return;
      setState(() {
        _submittedName = _name.text.trim();
        _phase = _Phase.done;
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _formError =
            'Couldn’t send your testimonial. The link may have expired or already been used, or your connection dropped. Please try again, or ask for a new link.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PublicNavbar(activeRoute: AppRoutes.leaveReview),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                wide ? 64.w : 20.w,
                wide ? 54.h : 36.h,
                wide ? 64.w : 20.w,
                70.h,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 780.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(wide: wide),
                      SizedBox(height: 22.h),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutCubic,
                        child: KeyedSubtree(
                          key: ValueKey(_phase),
                          child: _body(),
                        ),
                      ),
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
    switch (_phase) {
      case _Phase.loading:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 70.h),
          child: const Center(child: CircularProgressIndicator()),
        );
      case _Phase.ready:
        return _form();
      case _Phase.done:
        return _StateCard(
          icon: Icons.check_rounded,
          iconColor: AppColors.success,
          title: _submittedName.isEmpty ? 'Thank you!' : 'Thank you, $_submittedName!',
          message:
              'Your testimonial is on its way to me for review. It will appear on the site once I’ve approved it. I really appreciate you taking the time.',
          primaryLabel: 'Back to Home',
          onPrimary: () => Get.offAllNamed(AppRoutes.home),
          celebrate: true,
        );
      case _Phase.used:
        return _StateCard(
          icon: Icons.task_alt_rounded,
          iconColor: AppColors.primary,
          title: 'This link has already been used',
          message:
              'A testimonial was already sent with this link. If you’d like to add or change something, just get in touch and I’ll send you a new one.',
          primaryLabel: 'Contact me',
          onPrimary: () => Get.toNamed(AppRoutes.contactUs),
        );
      case _Phase.expired:
        return _StateCard(
          icon: Icons.schedule_rounded,
          iconColor: AppColors.warning,
          title: 'This link has expired',
          message:
              'Invite links only stay valid for a limited time. Message me and I’ll happily send you a fresh one.',
          primaryLabel: 'Contact me',
          onPrimary: () => Get.toNamed(AppRoutes.contactUs),
        );
      case _Phase.error:
        return _StateCard(
          icon: Icons.wifi_off_rounded,
          iconColor: AppColors.danger,
          title: 'Couldn’t check your link',
          message: 'Something went wrong while loading. Please check your connection and try again.',
          primaryLabel: 'Try again',
          onPrimary: _loadInvite,
        );
      case _Phase.invalid:
        return _StateCard(
          icon: Icons.link_off_rounded,
          iconColor: AppColors.danger,
          title: 'This link doesn’t look right',
          message:
              'It may have been copied incompletely or revoked. Please use the full link from my message, or ask me for a new one.',
          primaryLabel: 'Back to Home',
          onPrimary: () => Get.offAllNamed(AppRoutes.home),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // FORM
  // ---------------------------------------------------------------------------

  Widget _form() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How would you rate the experience?', style: AppTextStyles.bodyMedium().copyWith(fontSize: 15.sp)),
            SizedBox(height: 10.h),
            _StarPicker(
              rating: _rating,
              onChanged: (v) => setState(() {
                _rating = v;
                _formError = null;
              }),
            ),
            SizedBox(height: 24.h),
            _TwoCol(
              left: _field(_name, 'Your name *', required: true, max: 80),
              right: _field(_role, 'Your role', hint: 'e.g. Product Manager', max: 80),
            ),
            SizedBox(height: 14.h),
            _TwoCol(
              left: _field(_company, 'Company', max: 80),
              right: _field(_project, 'Project we worked on', max: 100),
            ),
            SizedBox(height: 14.h),
            TextFormField(
              controller: _quote,
              maxLines: 6,
              maxLength: _maxQuote,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
              decoration: _decoration(
                'Your testimonial *',
                hint: 'What was it like working together? What stood out, and what did you get out of it?',
              ),
              validator: (value) {
                final length = (value ?? '').trim().length;
                if (length == 0) return 'Please write a few words';
                if (length < _minQuote) return 'A little more, please (at least $_minQuote characters)';
                return null;
              },
            ),
            SizedBox(height: 10.h),
            InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () => setState(() {
                _consent = !_consent;
                _formError = null;
              }),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _consent,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() {
                        _consent = v ?? false;
                        _formError = null;
                      }),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: Text(
                          'I’m happy for Sufyan to show my testimonial, name, role and company publicly on this website.',
                          style: AppTextStyles.small(color: AppColors.textSecondary).copyWith(height: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_formError != null)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(_formError!, style: AppTextStyles.small(color: AppColors.danger)),
              ).animate().fadeIn(duration: 250.ms).shake(hz: 3, duration: 400.ms),
            SizedBox(height: 18.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: _submitting
                    ? SizedBox(
                        width: 20.sp,
                        height: 20.sp,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Send my testimonial', style: AppTextStyles.bodyMedium(color: Colors.white)),
              ),
            ),
            SizedBox(height: 10.h),
            Center(
              child: Text(
                'Nothing goes live until I’ve reviewed it.',
                style: AppTextStyles.small(),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: .03, end: 0);
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    bool required = false,
    int max = 80,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: max,
      buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
      style: AppTextStyles.bodyMedium().copyWith(fontSize: 14.sp),
      decoration: _decoration(label, hint: hint),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null
          : null,
    );
  }

  InputDecoration _decoration(String label, {String? hint}) {
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: color, width: width),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: true,
      labelStyle: AppTextStyles.small(color: AppColors.textSecondary),
      hintStyle: AppTextStyles.small(),
      filled: true,
      fillColor: AppColors.surfaceSoft,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.primary, 1.3),
      errorBorder: border(AppColors.danger),
      focusedErrorBorder: border(AppColors.danger, 1.3),
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
                Text('SHARE YOUR EXPERIENCE', style: AppTextStyles.overline(color: AppColors.accentGold)),
                SizedBox(height: 10.h),
                Text(
                  'How was it working together?',
                  style: AppTextStyles.h1(color: Colors.white).copyWith(fontSize: wide ? 40.sp : 30.sp, height: 1.1),
                ),
                SizedBox(height: 10.h),
                Text(
                  'A few honest words from you help other people decide whether we’re a good fit. It takes about two minutes.',
                  style: AppTextStyles.body(color: Colors.white.withValues(alpha: .78)),
                ),
              ],
            ),
          ),
          if (wide) ...[
            SizedBox(width: 26.w),
            Icon(Icons.format_quote_rounded, size: 84.sp, color: AppColors.accentGold.withValues(alpha: .9))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: -6, end: 6, duration: 2400.ms, curve: Curves.easeInOut),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: .03, end: 0);
  }
}

class _TwoCol extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _TwoCol({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(children: [left, SizedBox(height: 14.h), right]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: 14.w),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class _StarPicker extends StatefulWidget {
  final int rating;
  final ValueChanged<int> onChanged;
  const _StarPicker({required this.rating, required this.onChanged});

  @override
  State<_StarPicker> createState() => _StarPickerState();
}

class _StarPickerState extends State<_StarPicker> {
  int _hover = 0;

  static const _labels = ['', 'Poor', 'Fair', 'Good', 'Very good', 'Excellent'];

  @override
  Widget build(BuildContext context) {
    final shown = _hover > 0 ? _hover : widget.rating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            final value = i + 1;
            final filled = value <= shown;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hover = value),
              onExit: (_) => setState(() => _hover = 0),
              child: GestureDetector(
                onTap: () => widget.onChanged(value),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutBack,
                  scale: _hover == value ? 1.2 : 1,
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 40.sp,
                      color: filled ? AppColors.accentGold : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 4.h),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            shown == 0 ? 'Tap a star' : _labels[shown],
            key: ValueKey(shown),
            style: AppTextStyles.small(
              color: shown == 0 ? AppColors.textMuted : AppColors.primary,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _StateCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final bool celebrate;

  const _StateCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.celebrate = false,
  });

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: 84.w,
      height: 84.w,
      decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withValues(alpha: .12)),
      child: Icon(icon, size: 42.sp, color: iconColor),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 44.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          celebrate
              ? badge
                  .animate()
                  .scale(begin: const Offset(.4, .4), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 250.ms)
              : badge.animate().fadeIn(duration: 300.ms),
          SizedBox(height: 20.h),
          Text(title, textAlign: TextAlign.center, style: AppTextStyles.h2().copyWith(fontSize: 26.sp)),
          SizedBox(height: 10.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 520.w),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body().copyWith(height: 1.65),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: onPrimary,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 15.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text(primaryLabel),
          ),
        ],
      ),
    );
  }
}
