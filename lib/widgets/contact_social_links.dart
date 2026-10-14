import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [raw] in a new browser tab / external app.
///
/// Forgiving about what the admin typed: `github.com/me` gets `https://`
/// added, a bare phone number for WhatsApp becomes a `wa.me` link, and
/// `mailto:` / `tel:` values pass through untouched.
Future<bool> openExternalLink(String raw, {String? network}) async {
  var value = raw.trim();
  if (value.isEmpty) return false;

  if (network == 'whatsapp') {
    final looksLikeNumber = RegExp(r'^\+?[\d\s\-()]+$').hasMatch(value);
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (looksLikeNumber && digits.isNotEmpty) value = 'https://wa.me/$digits';
  }

  final hasScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.\-]*:').hasMatch(value);
  if (!hasScheme) value = 'https://$value';

  final uri = Uri.tryParse(value);
  if (uri == null) return false;

  try {
    return await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  } catch (_) {
    return false;
  }
}

/// Display order + icon + label for every network the admin can fill in
/// (Site Management > Contact & social). Same keys the footer uses.
const Map<String, (FaIconData, String)> _networks = {
  'github': (FontAwesomeIcons.github, 'GitHub'),
  'linkedin': (FontAwesomeIcons.linkedinIn, 'LinkedIn'),
  'x': (FontAwesomeIcons.xTwitter, 'X'),
  'instagram': (FontAwesomeIcons.instagram, 'Instagram'),
  'facebook': (FontAwesomeIcons.facebookF, 'Facebook'),
  'whatsapp': (FontAwesomeIcons.whatsapp, 'WhatsApp'),
  'website': (FontAwesomeIcons.globe, 'Website'),
};

/// "Follow Me" heading plus animated social pills. Only networks that have a
/// saved link are shown; with none saved the whole section hides itself.
class ContactSocialLinks extends StatelessWidget {
  final Map<String, String> links;
  const ContactSocialLinks({super.key, required this.links});

  @override
  Widget build(BuildContext context) {
    final entries = [
      for (final network in _networks.entries)
        if ((links[network.key] ?? '').trim().isNotEmpty)
          (key: network.key, icon: network.value.$1, label: network.value.$2),
    ];
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 22.h),
        Text('Follow Me', style: AppTextStyles.h3().copyWith(fontSize: 18.sp))
            .animate()
            .fadeIn(duration: 350.ms),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            for (var i = 0; i < entries.length; i++)
              _SocialPill(
                icon: entries[i].icon,
                label: entries[i].label,
                onTap: () => _open(context, entries[i].key, links),
              )
                  .animate()
                  .fadeIn(delay: (90 * i).ms, duration: 380.ms)
                  .slideY(
                    begin: .45,
                    end: 0,
                    delay: (90 * i).ms,
                    duration: 480.ms,
                    curve: Curves.easeOutBack,
                  ),
          ],
        ),
      ],
    );
  }

  Future<void> _open(
    BuildContext context,
    String key,
    Map<String, String> links,
  ) async {
    final ok = await openExternalLink(links[key] ?? '', network: key);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t open that link.')),
      );
    }
  }
}

class _SocialPill extends StatefulWidget {
  final FaIconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SocialPill> createState() => _SocialPillState();
}

class _SocialPillState extends State<_SocialPill> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = _hover || _pressed;

    return Semantics(
      button: true,
      label: 'Open ${widget.label}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() {
          _hover = false;
          _pressed = false;
        }),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            offset: Offset(0, _hover && !_pressed ? -0.1 : 0),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              scale: _pressed ? 0.95 : (_hover ? 1.04 : 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.border,
                  ),
                  boxShadow: _hover
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : const [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutBack,
                      scale: _hover ? 1.2 : 1,
                      child: FaIcon(
                        widget.icon,
                        size: 15.sp,
                        color: active ? Colors.white : AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 240),
                      style: AppTextStyles.small(
                        color: active ? Colors.white : AppColors.textPrimary,
                      ).copyWith(fontWeight: FontWeight.w700),
                      child: Text(widget.label),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
