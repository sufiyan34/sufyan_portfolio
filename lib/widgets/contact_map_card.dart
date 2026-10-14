import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:sufyan_portfolio/constant/app_colors.dart';
import 'package:sufyan_portfolio/constant/app_text_styles.dart';
import 'package:sufyan_portfolio/widgets/contact_social_links.dart'
    show openExternalLink;

/// Interactive OpenStreetMap card for the public Contact page.
///
/// * animated pin with a pulsing ring (tap it to zoom in)
/// * smooth animated zoom in / zoom out / re-center buttons
/// * "Open in Maps" link to Google Maps
///
/// Mouse-wheel zoom is deliberately off so the page keeps scrolling when the
/// cursor passes over the map; on touch devices one-finger drags also stay
/// with the page (pinch with two fingers to zoom the map).
class ContactMapCard extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final String label;

  const ContactMapCard({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.zoom,
    required this.label,
  });

  @override
  State<ContactMapCard> createState() => _ContactMapCardState();
}

class _ContactMapCardState extends State<ContactMapCard>
    with SingleTickerProviderStateMixin {
  static const double _minZoom = 3;
  static const double _maxZoom = 18;

  final MapController _map = MapController();
  late final AnimationController _anim;
  late final LatLng _home;
  late final double _homeZoom;

  bool _ready = false;
  LatLng _from = LatLng(0, 0);
  LatLng _to = LatLng(0, 0);
  double _fromZoom = 0;
  double _toZoom = 0;

  @override
  void initState() {
    super.initState();
    _home = LatLng(widget.latitude, widget.longitude);
    _homeZoom = widget.zoom.clamp(_minZoom, _maxZoom).toDouble();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..addListener(_tick);
  }

  @override
  void dispose() {
    _anim.dispose();
    _map.dispose();
    super.dispose();
  }

  void _tick() {
    final t = Curves.easeInOutCubic.transform(_anim.value);
    _map.move(
      LatLng(
        _from.latitude + (_to.latitude - _from.latitude) * t,
        _from.longitude + (_to.longitude - _from.longitude) * t,
      ),
      _fromZoom + (_toZoom - _fromZoom) * t,
    );
  }

  void _animateTo(LatLng center, double zoom) {
    if (!_ready) return;
    final camera = _map.camera;
    _from = camera.center;
    _fromZoom = camera.zoom;
    _to = center;
    _toZoom = zoom.clamp(_minZoom, _maxZoom).toDouble();
    _anim.forward(from: 0);
  }

  void _zoomBy(double delta) {
    if (!_ready) return;
    _animateTo(_map.camera.center, _map.camera.zoom + delta);
  }

  Future<void> _openInMaps() {
    return openExternalLink(
      'https://www.google.com/maps/search/?api=1'
      '&query=${widget.latitude},${widget.longitude}',
    ).then((_) {});
  }

  bool get _isTouch =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    final flags = _isTouch
        ? InteractiveFlag.pinchZoom |
              InteractiveFlag.pinchMove |
              InteractiveFlag.doubleTapZoom
        : InteractiveFlag.drag |
              InteractiveFlag.flingAnimation |
              InteractiveFlag.pinchZoom |
              InteractiveFlag.pinchMove |
              InteractiveFlag.doubleTapZoom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 600.0;
        final height = (width / 1.9).clamp(250.0, 360.0);

        return SizedBox(
          width: double.infinity,
          height: height,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(22.r),
              boxShadow: AppColors.cardShadow,
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: _home,
                    initialZoom: _homeZoom,
                    minZoom: _minZoom,
                    maxZoom: _maxZoom,
                    backgroundColor: AppColors.surfaceSoft,
                    interactionOptions: InteractionOptions(flags: flags),
                    onMapReady: () => _ready = true,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.sufyan.portfolio',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _home,
                          width: 64,
                          height: 74,
                          alignment: Alignment.topCenter,
                          child: _MapPin(
                            onTap: () => _animateTo(
                              _home,
                              math.max(_ready ? _map.camera.zoom : 0, 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    RichAttributionWidget(
                      alignment: AttributionAlignment.bottomRight,
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () => openExternalLink(
                            'https://www.openstreetmap.org/copyright',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Column(
                    children: [
                      _MapButton(
                        icon: Icons.add_rounded,
                        tooltip: 'Zoom in',
                        onTap: () => _zoomBy(1),
                      ),
                      const SizedBox(height: 8),
                      _MapButton(
                        icon: Icons.remove_rounded,
                        tooltip: 'Zoom out',
                        onTap: () => _zoomBy(-1),
                      ),
                      const SizedBox(height: 8),
                      _MapButton(
                        icon: Icons.my_location_rounded,
                        tooltip: 'Back to my location',
                        onTap: () => _animateTo(_home, _homeZoom),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: math.max(160, width - 90),
                    ),
                    child: _InfoCard(label: widget.label, onOpen: _openInMaps)
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 400.ms)
                        .slideY(begin: .3, end: 0, curve: Curves.easeOutCubic),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: .04, end: 0);
      },
    );
  }
}

class _MapPin extends StatelessWidget {
  final VoidCallback onTap;
  const _MapPin({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // Pulsing ring centred on the exact map point (bottom of the box).
            Positioned(
              bottom: -9,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.28),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(3.2, 3.2),
                    duration: 1800.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeOut(duration: 1800.ms),
            ),
            Positioned(
              bottom: 2,
              child: const Icon(
                Icons.location_on_rounded,
                size: 50,
                color: AppColors.primary,
                shadows: [
                  Shadow(
                    color: Color(0x44000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 250.ms)
                  .slideY(
                    begin: -1.4,
                    end: 0,
                    duration: 900.ms,
                    curve: Curves.bounceOut,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_MapButton> createState() => _MapButtonState();
}

class _MapButtonState extends State<_MapButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 160),
            scale: _hover ? 1.1 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _hover ? AppColors.primary : AppColors.surface,
                border: Border.all(
                  color: _hover ? AppColors.primary : AppColors.border,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: 19,
                color: _hover ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatefulWidget {
  final String label;
  final VoidCallback onOpen;
  const _InfoCard({required this.label, required this.onOpen});

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 8.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 18.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Find me here', style: AppTextStyles.small()),
                Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium().copyWith(fontSize: 13.sp),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hover = true),
            onExit: (_) => setState(() => _hover = false),
            child: GestureDetector(
              onTap: widget.onOpen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: _hover ? AppColors.primary : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Open in Maps',
                      style: AppTextStyles.small(
                        color: _hover ? Colors.white : AppColors.primary,
                      ).copyWith(fontWeight: FontWeight.w800, fontSize: 11.sp),
                    ),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 220),
                      offset: Offset(_hover ? 0.15 : 0, _hover ? -0.15 : 0),
                      child: Icon(
                        Icons.arrow_outward_rounded,
                        size: 14.sp,
                        color: _hover ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
