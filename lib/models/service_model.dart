/// Mirrors `services/{serviceId}` in Firebase Realtime Database.
///
/// The model intentionally stores an icon key instead of IconData so all
/// service content remains JSON-friendly and editable from the admin panel.
class ServiceModel {
  final String id;
  final String title;
  final String category;
  final String shortDescription;
  final String description;
  final List<String> features;
  final List<String> technologies;
  final String icon;
  final int sortOrder;
  final bool published;
  final bool featured;
  final int createdAt;
  final int updatedAt;

  const ServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.shortDescription,
    required this.description,
    required this.features,
    required this.technologies,
    required this.icon,
    required this.sortOrder,
    required this.published,
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.empty() => const ServiceModel(
        id: '',
        title: '',
        category: 'Development',
        shortDescription: '',
        description: '',
        features: [],
        technologies: [],
        icon: 'phone_android',
        sortOrder: 0,
        published: true,
        featured: false,
        createdAt: 0,
        updatedAt: 0,
      );

  ServiceModel copyWith({
    String? id,
    String? title,
    String? category,
    String? shortDescription,
    String? description,
    List<String>? features,
    List<String>? technologies,
    String? icon,
    int? sortOrder,
    bool? published,
    bool? featured,
    int? createdAt,
    int? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      features: features ?? this.features,
      technologies: technologies ?? this.technologies,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      published: published ?? this.published,
      featured: featured ?? this.featured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ServiceModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ServiceModel(
      id: id,
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Development',
      shortDescription: map['shortDescription']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      features: _stringList(map['features']),
      technologies: _stringList(map['technologies']),
      icon: map['icon']?.toString() ?? 'phone_android',
      sortOrder: _toInt(map['sortOrder']),
      published: _toBool(map['published'], fallback: true),
      featured: _toBool(map['featured'], fallback: false),
      createdAt: _toInt(map['createdAt']),
      updatedAt: _toInt(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category,
        'shortDescription': shortDescription,
        'description': description,
        'features': features,
        'technologies': technologies,
        'icon': icon,
        'sortOrder': sortOrder,
        'published': published,
        'featured': featured,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  static List<String> _stringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .map((entry) => entry.toString().trim())
          .where((entry) => entry.isNotEmpty)
          .toList();
    }
    if (value is Map) {
      return value.values
          .map((entry) => entry.toString().trim())
          .where((entry) => entry.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool _toBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return fallback;
  }
}

class ServiceCategories {
  ServiceCategories._();

  static const List<String> suggested = [
    'Mobile Development',
    'Web Development',
    'Firebase & Backend',
    'API Integration',
    'Business Systems',
    'UI/UX Implementation',
  ];
}
