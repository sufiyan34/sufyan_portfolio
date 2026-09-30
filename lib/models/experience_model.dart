/// Mirrors `experiences/{experienceId}` in Firebase Realtime Database.
///
/// This model is intentionally JSON-friendly so the complete timeline can be
/// managed from the admin panel without relying on Flutter-specific types.
class ExperienceModel {
  final String id;
  final String role;
  final String company;
  final String employmentType;
  final String location;
  final String startDate;
  final String endDate;
  final bool isCurrent;
  final String description;
  final List<String> achievements;
  final List<String> technologies;
  final int sortOrder;
  final bool published;
  final bool featured;
  final int createdAt;
  final int updatedAt;

  const ExperienceModel({
    required this.id,
    required this.role,
    required this.company,
    required this.employmentType,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
    required this.description,
    required this.achievements,
    required this.technologies,
    required this.sortOrder,
    required this.published,
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExperienceModel.empty() => const ExperienceModel(
        id: '',
        role: '',
        company: '',
        employmentType: 'Full-time',
        location: '',
        startDate: '',
        endDate: '',
        isCurrent: false,
        description: '',
        achievements: [],
        technologies: [],
        sortOrder: 0,
        published: true,
        featured: false,
        createdAt: 0,
        updatedAt: 0,
      );

  String get dateRange {
    final start = startDate.trim();
    final end = isCurrent ? 'Present' : endDate.trim();

    if (start.isEmpty && end.isEmpty) return '';
    if (start.isEmpty) return end;
    if (end.isEmpty) return start;
    return '$start — $end';
  }

  ExperienceModel copyWith({
    String? id,
    String? role,
    String? company,
    String? employmentType,
    String? location,
    String? startDate,
    String? endDate,
    bool? isCurrent,
    String? description,
    List<String>? achievements,
    List<String>? technologies,
    int? sortOrder,
    bool? published,
    bool? featured,
    int? createdAt,
    int? updatedAt,
  }) {
    return ExperienceModel(
      id: id ?? this.id,
      role: role ?? this.role,
      company: company ?? this.company,
      employmentType: employmentType ?? this.employmentType,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      description: description ?? this.description,
      achievements: achievements ?? this.achievements,
      technologies: technologies ?? this.technologies,
      sortOrder: sortOrder ?? this.sortOrder,
      published: published ?? this.published,
      featured: featured ?? this.featured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ExperienceModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return ExperienceModel(
      id: id,
      role: map['role']?.toString() ?? '',
      company: map['company']?.toString() ?? '',
      employmentType: map['employmentType']?.toString() ?? 'Full-time',
      location: map['location']?.toString() ?? '',
      startDate: map['startDate']?.toString() ?? '',
      endDate: map['endDate']?.toString() ?? '',
      isCurrent: _toBool(map['isCurrent'], fallback: false),
      description: map['description']?.toString() ?? '',
      achievements: _stringList(map['achievements']),
      technologies: _stringList(map['technologies']),
      sortOrder: _toInt(map['sortOrder']),
      published: _toBool(map['published'], fallback: true),
      featured: _toBool(map['featured'], fallback: false),
      createdAt: _toInt(map['createdAt']),
      updatedAt: _toInt(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'role': role,
        'company': company,
        'employmentType': employmentType,
        'location': location,
        'startDate': startDate,
        'endDate': endDate,
        'isCurrent': isCurrent,
        'description': description,
        'achievements': achievements,
        'technologies': technologies,
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

class ExperienceTypes {
  ExperienceTypes._();

  static const List<String> suggested = [
    'Full-time',
    'Part-time',
    'Freelance',
    'Contract',
    'Internship',
  ];
}
