import 'package:sufyan_portfolio/constant/app_images.dart';

/// Mirrors the `homeContent/` node in FIREBASE_DATA_STRUCTURE.md section 8.
class HomeContentModel {
  final String eyebrow;
  final String headline;
  final String subHeadline;
  final String description;
  final String primaryButtonText;
  final String primaryButtonRoute;
  final String secondaryButtonText;
  final String secondaryButtonRoute;
  final String heroImageUrl;
  final String heroVideoUrl;
  final int updatedAt;

  const HomeContentModel({
    required this.eyebrow,
    required this.headline,
    required this.subHeadline,
    required this.description,
    required this.primaryButtonText,
    required this.primaryButtonRoute,
    required this.secondaryButtonText,
    required this.secondaryButtonRoute,
    required this.heroImageUrl,
    required this.heroVideoUrl,
    required this.updatedAt,
  });

  /// Copy currently hard-coded into HeroSection — used until the
  /// `homeContent` node has real data (or if the read fails), so the hero
  /// never shows a blank/loading state on first paint.
  factory HomeContentModel.fallback() => const HomeContentModel(
    eyebrow: "Hi, I'm",
    headline: 'Muhammad Sufyan',
    subHeadline: 'Flutter Developer & Software Engineer',
    description:
        'I build modern, scalable and high-performance mobile, web '
        'and business applications. Turning ideas into real products.',
    primaryButtonText: 'Hire Me',
    primaryButtonRoute: '/hire-us',
    secondaryButtonText: 'View My Work',
    secondaryButtonRoute: '/projects',
    heroImageUrl: AppImages.heroImage,
    heroVideoUrl: '',
    updatedAt: 0,
  );

  factory HomeContentModel.fromMap(Map<dynamic, dynamic> map) {
    final fallback = HomeContentModel.fallback();
    return HomeContentModel(
      eyebrow: map['eyebrow'] as String? ?? fallback.eyebrow,
      headline: map['headline'] as String? ?? fallback.headline,
      subHeadline: map['subHeadline'] as String? ?? fallback.subHeadline,
      description: map['description'] as String? ?? fallback.description,
      primaryButtonText:
          map['primaryButtonText'] as String? ?? fallback.primaryButtonText,
      primaryButtonRoute:
          map['primaryButtonRoute'] as String? ?? fallback.primaryButtonRoute,
      secondaryButtonText:
          map['secondaryButtonText'] as String? ?? fallback.secondaryButtonText,
      secondaryButtonRoute:
          map['secondaryButtonRoute'] as String? ??
          fallback.secondaryButtonRoute,
      heroImageUrl: map['heroImageUrl'] as String? ?? '',
      heroVideoUrl: map['heroVideoUrl'] as String? ?? '',
      updatedAt: map['updatedAt'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'eyebrow': eyebrow,
    'headline': headline,
    'subHeadline': subHeadline,
    'description': description,
    'primaryButtonText': primaryButtonText,
    'primaryButtonRoute': primaryButtonRoute,
    'secondaryButtonText': secondaryButtonText,
    'secondaryButtonRoute': secondaryButtonRoute,
    'heroImageUrl': heroImageUrl,
    'heroVideoUrl': heroVideoUrl,
    'updatedAt': updatedAt,
  };
}

/// Mirrors a single child under `homeContent/stats/{id}`.
class HomeStatModel {
  final String id;
  final String label;
  final String value;
  final String icon;
  final int sortOrder;
  final bool active;

  const HomeStatModel({
    required this.id,
    required this.label,
    required this.value,
    required this.icon,
    required this.sortOrder,
    required this.active,
  });

  /// The 4 stats currently hard-coded into HeroSection.
  static List<HomeStatModel> fallback() => const [
    HomeStatModel(
      id: 'f1',
      label: 'Years Experience',
      value: '1+',
      icon: 'calendar',
      sortOrder: 1,
      active: true,
    ),
    HomeStatModel(
      id: 'f2',
      label: 'Projects Completed',
      value: '15+',
      icon: 'briefcase',
      sortOrder: 2,
      active: true,
    ),
    HomeStatModel(
      id: 'f3',
      label: 'Technologies',
      value: '10+',
      icon: 'code',
      sortOrder: 3,
      active: true,
    ),
    HomeStatModel(
      id: 'f4',
      label: 'Client Focus',
      value: '100%',
      icon: 'heart',
      sortOrder: 4,
      active: true,
    ),
  ];

  factory HomeStatModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return HomeStatModel(
      id: id,
      label: map['label'] as String? ?? '',
      value: map['value'] as String? ?? '',
      icon: map['icon'] as String? ?? '',
      sortOrder: map['sortOrder'] as int? ?? 0,
      active: map['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'label': label,
    'value': value,
    'icon': icon,
    'sortOrder': sortOrder,
    'active': active,
  };
}
