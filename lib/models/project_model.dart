/// Mirrors `projects/{projectId}` in FIREBASE_DATA_STRUCTURE.md section 16.
///
/// The admin Add/Edit form (see project_form_dialog.dart) currently edits
/// the "listing" fields — the ones the client Projects grid actually shows
/// (title, shortDescription, technologies, categoryIds, coverImageUrl,
/// links). The case-study fields (fullDescription, features, challenge,
/// solution, results, gallery, role, clientName) are modeled here and kept
/// through fromMap/toMap so nothing is lost on save, ready for the
/// /project-details page when that's built.
class ProjectModel {
  final String id;
  final String title;
  final String slug;
  final String shortDescription;
  final String fullDescription;
  final List<String> categoryIds;
  final List<String> technologies;
  final List<String> features;
  final String role;
  final String challenge;
  final String solution;
  final String results;
  final String clientName;
  final int year;
  final String coverImageUrl;
  final List<String> gallery;
  final String videoUrl;
  final String githubUrl;
  final String liveUrl;

  /// 'public' | 'private' | 'case-study-only'
  final String visibility;
  final bool featured;
  final bool published;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.shortDescription,
    this.fullDescription = '',
    this.categoryIds = const [],
    this.technologies = const [],
    this.features = const [],
    this.role = '',
    this.challenge = '',
    this.solution = '',
    this.results = '',
    this.clientName = '',
    this.year = 0,
    this.coverImageUrl = '',
    this.gallery = const [],
    this.videoUrl = '',
    this.githubUrl = '',
    this.liveUrl = '',
    this.visibility = 'public',
    this.featured = false,
    this.published = true,
    this.sortOrder = 0,
    this.createdAt = 0,
    this.updatedAt = 0,
  });

  /// A blank draft for the "Add Project" form.
  factory ProjectModel.empty() => ProjectModel(
    id: '',
    title: '',
    slug: '',
    shortDescription: '',
    year: DateTime.now().year,
  );

  ProjectModel copyWith({
    String? id,
    String? title,
    String? slug,
    String? shortDescription,
    String? fullDescription,
    List<String>? categoryIds,
    List<String>? technologies,
    List<String>? features,
    String? role,
    String? challenge,
    String? solution,
    String? results,
    String? clientName,
    int? year,
    String? coverImageUrl,
    List<String>? gallery,
    String? videoUrl,
    String? githubUrl,
    String? liveUrl,
    String? visibility,
    bool? featured,
    bool? published,
    int? sortOrder,
    int? createdAt,
    int? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      shortDescription: shortDescription ?? this.shortDescription,
      fullDescription: fullDescription ?? this.fullDescription,
      categoryIds: categoryIds ?? this.categoryIds,
      technologies: technologies ?? this.technologies,
      features: features ?? this.features,
      role: role ?? this.role,
      challenge: challenge ?? this.challenge,
      solution: solution ?? this.solution,
      results: results ?? this.results,
      clientName: clientName ?? this.clientName,
      year: year ?? this.year,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      gallery: gallery ?? this.gallery,
      videoUrl: videoUrl ?? this.videoUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      liveUrl: liveUrl ?? this.liveUrl,
      visibility: visibility ?? this.visibility,
      featured: featured ?? this.featured,
      published: published ?? this.published,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProjectModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ProjectModel(
      id: id,
      title: map['title'] as String? ?? '',
      slug: map['slug'] as String? ?? '',
      shortDescription: map['shortDescription'] as String? ?? '',
      fullDescription: map['fullDescription'] as String? ?? '',
      categoryIds: _stringList(map['categoryIds']),
      technologies: _stringList(map['technologies']),
      features: _stringList(map['features']),
      role: map['role'] as String? ?? '',
      challenge: map['challenge'] as String? ?? '',
      solution: map['solution'] as String? ?? '',
      results: map['results'] as String? ?? '',
      clientName: map['clientName'] as String? ?? '',
      year: map['year'] as int? ?? 0,
      coverImageUrl: map['coverImageUrl'] as String? ?? '',
      gallery: _stringList(map['gallery']),
      videoUrl: map['videoUrl'] as String? ?? '',
      githubUrl: map['githubUrl'] as String? ?? '',
      liveUrl: map['liveUrl'] as String? ?? '',
      visibility: map['visibility'] as String? ?? 'public',
      featured: map['featured'] as bool? ?? false,
      published: map['published'] as bool? ?? true,
      sortOrder: map['sortOrder'] as int? ?? 0,
      createdAt: map['createdAt'] as int? ?? 0,
      updatedAt: map['updatedAt'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'slug': slug,
    'shortDescription': shortDescription,
    'fullDescription': fullDescription,
    'categoryIds': categoryIds,
    'technologies': technologies,
    'features': features,
    'role': role,
    'challenge': challenge,
    'solution': solution,
    'results': results,
    'clientName': clientName,
    'year': year,
    'coverImageUrl': coverImageUrl,
    'gallery': gallery,
    'videoUrl': videoUrl,
    'githubUrl': githubUrl,
    'liveUrl': liveUrl,
    'visibility': visibility,
    'featured': featured,
    'published': published,
    'sortOrder': sortOrder,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  static List<String> _stringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is Map) return value.values.map((e) => e.toString()).toList();
    return const [];
  }
}

/// Fixed set of filter categories matching the pills in the design mockup
/// (All / Flutter / Web / Firebase / Business / E-Commerce / UI-UX).
/// Used both as the admin form's category picker and the client filter row,
/// so the two always stay in sync.
class ProjectCategories {
  ProjectCategories._();

  static const List<String> all = [
    'Flutter',
    'Web',
    'Firebase',
    'Business',
    'E-Commerce',
    'UI/UX',
  ];
}
