/// Mirrors `skills/{skillId}` in Firebase Realtime Database.
///
/// Skills intentionally use an icon key rather than [IconData] so the model
/// stays JSON-friendly and can be managed completely from Firebase.
class SkillModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final int proficiency;
  final String icon;
  final int sortOrder;
  final bool published;
  final int createdAt;
  final int updatedAt;

  const SkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.proficiency,
    required this.icon,
    required this.sortOrder,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SkillModel.empty() => const SkillModel(
    id: '',
    name: '',
    category: 'Development',
    description: '',
    proficiency: 80,
    icon: 'code',
    sortOrder: 0,
    published: true,
    createdAt: 0,
    updatedAt: 0,
  );

  SkillModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    int? proficiency,
    String? icon,
    int? sortOrder,
    bool? published,
    int? createdAt,
    int? updatedAt,
  }) {
    return SkillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      proficiency: proficiency ?? this.proficiency,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      published: published ?? this.published,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SkillModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return SkillModel(
      id: id,
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Development',
      description: map['description']?.toString() ?? '',
      proficiency: _toInt(map['proficiency'], fallback: 80).clamp(0, 100),
      icon: map['icon']?.toString() ?? 'code',
      sortOrder: _toInt(map['sortOrder']),
      published: map['published'] is bool
          ? map['published'] as bool
          : map['published']?.toString().toLowerCase() != 'false',
      createdAt: _toInt(map['createdAt']),
      updatedAt: _toInt(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category,
    'description': description,
    'proficiency': proficiency,
    'icon': icon,
    'sortOrder': sortOrder,
    'published': published,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

/// Suggested categories for the admin form. Admins can also type a custom
/// category, so the database is not locked to this list.
class SkillCategories {
  SkillCategories._();

  static const List<String> suggested = [
    'Mobile',
    'Frontend',
    'Backend',
    'Database',
    'Firebase',
    'UI/UX',
    'Tools',
  ];
}
