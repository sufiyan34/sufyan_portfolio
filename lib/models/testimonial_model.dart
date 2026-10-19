/// Mirrors `testimonials/{testimonialId}` in Firebase Realtime Database.
class TestimonialModel {
  final String id;
  final String clientName;
  final String clientRole;
  final String company;
  final String projectName;
  final String quote;
  final int rating;
  final String avatarUrl;
  final bool featured;
  final bool published;

  /// `client` = submitted by the client through a private invite link,
  /// `admin` = added manually from the admin panel.
  final String source;

  /// True when the admin changed the client's wording while approving.
  final bool quoteEdited;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;

  const TestimonialModel({
    required this.id,
    required this.clientName,
    required this.clientRole,
    required this.company,
    required this.projectName,
    required this.quote,
    required this.rating,
    required this.avatarUrl,
    required this.featured,
    required this.published,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.source = TestimonialSources.admin,
    this.quoteEdited = false,
  });

  factory TestimonialModel.empty() => const TestimonialModel(
    id: '',
    clientName: '',
    clientRole: '',
    company: '',
    projectName: '',
    quote: '',
    rating: 5,
    avatarUrl: '',
    featured: false,
    published: true,
    sortOrder: 0,
    createdAt: 0,
    updatedAt: 0,
  );

  TestimonialModel copyWith({
    String? id,
    String? clientName,
    String? clientRole,
    String? company,
    String? projectName,
    String? quote,
    int? rating,
    String? avatarUrl,
    bool? featured,
    bool? published,
    String? source,
    bool? quoteEdited,
    int? sortOrder,
    int? createdAt,
    int? updatedAt,
  }) {
    return TestimonialModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      clientRole: clientRole ?? this.clientRole,
      company: company ?? this.company,
      projectName: projectName ?? this.projectName,
      quote: quote ?? this.quote,
      rating: rating ?? this.rating,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      featured: featured ?? this.featured,
      published: published ?? this.published,
      source: source ?? this.source,
      quoteEdited: quoteEdited ?? this.quoteEdited,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TestimonialModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return TestimonialModel(
      id: id,
      clientName: map['clientName']?.toString() ?? '',
      clientRole: map['clientRole']?.toString() ?? '',
      company: map['company']?.toString() ?? '',
      projectName: map['projectName']?.toString() ?? '',
      quote: map['quote']?.toString() ?? '',
      rating: _toInt(map['rating'], fallback: 5).clamp(1, 5),
      avatarUrl: map['avatarUrl']?.toString() ?? '',
      featured: map['featured'] == true,
      published: map['published'] is bool
          ? map['published'] as bool
          : map['published']?.toString().toLowerCase() != 'false',
      source: map['source']?.toString() == TestimonialSources.client
          ? TestimonialSources.client
          : TestimonialSources.admin,
      quoteEdited: map['quoteEdited'] == true,
      sortOrder: _toInt(map['sortOrder']),
      createdAt: _toInt(map['createdAt']),
      updatedAt: _toInt(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'clientName': clientName,
    'clientRole': clientRole,
    'company': company,
    'projectName': projectName,
    'quote': quote,
    'rating': rating,
    'avatarUrl': avatarUrl,
    'featured': featured,
    'published': published,
    'source': source,
    'quoteEdited': quoteEdited,
    'sortOrder': sortOrder,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  /// Shown as a "Verified client" badge on the public site: the client
  /// submitted it themselves and the wording wasn't changed.
  bool get isVerifiedClient =>
      source == TestimonialSources.client && !quoteEdited;

  /// "CTO · Acme" style subtitle, skipping whichever parts are empty.
  String get roleLine =>
      [clientRole, company].where((e) => e.trim().isNotEmpty).join(' · ');

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class TestimonialSources {
  TestimonialSources._();
  static const client = 'client';
  static const admin = 'admin';
}
