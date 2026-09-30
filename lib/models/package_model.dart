/// Mirrors `packages/{packageId}` in Firebase Realtime Database.
///
/// The admin can assign any package to one of four visual/package tiers:
/// Silver, Gold, Platinum, or Custom.
class PackageModel {
  final String id;
  final String title;
  final String type;
  final String shortDescription;
  final String description;
  final double price;
  final String currency;
  final String pricingNote;
  final int deliveryDays;
  final int revisions;
  final List<String> features;
  final List<String> technologies;
  final int sortOrder;
  final bool published;
  final bool featured;
  final String ctaLabel;
  final int createdAt;
  final int updatedAt;

  const PackageModel({
    required this.id,
    required this.title,
    required this.type,
    required this.shortDescription,
    required this.description,
    required this.price,
    required this.currency,
    required this.pricingNote,
    required this.deliveryDays,
    required this.revisions,
    required this.features,
    required this.technologies,
    required this.sortOrder,
    required this.published,
    required this.featured,
    required this.ctaLabel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PackageModel.empty() => const PackageModel(
        id: '',
        title: '',
        type: PackageTypes.silver,
        shortDescription: '',
        description: '',
        price: 0,
        currency: 'USD',
        pricingNote: 'Fixed package',
        deliveryDays: 7,
        revisions: 2,
        features: [],
        technologies: [],
        sortOrder: 0,
        published: true,
        featured: false,
        ctaLabel: 'Choose Package',
        createdAt: 0,
        updatedAt: 0,
      );

  PackageModel copyWith({
    String? id,
    String? title,
    String? type,
    String? shortDescription,
    String? description,
    double? price,
    String? currency,
    String? pricingNote,
    int? deliveryDays,
    int? revisions,
    List<String>? features,
    List<String>? technologies,
    int? sortOrder,
    bool? published,
    bool? featured,
    String? ctaLabel,
    int? createdAt,
    int? updatedAt,
  }) {
    return PackageModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      pricingNote: pricingNote ?? this.pricingNote,
      deliveryDays: deliveryDays ?? this.deliveryDays,
      revisions: revisions ?? this.revisions,
      features: features ?? this.features,
      technologies: technologies ?? this.technologies,
      sortOrder: sortOrder ?? this.sortOrder,
      published: published ?? this.published,
      featured: featured ?? this.featured,
      ctaLabel: ctaLabel ?? this.ctaLabel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PackageModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return PackageModel(
      id: id,
      title: map['title']?.toString() ?? '',
      type: PackageTypes.normalize(map['type']?.toString()),
      shortDescription: map['shortDescription']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: _toDouble(map['price']),
      currency: map['currency']?.toString() ?? 'USD',
      pricingNote: map['pricingNote']?.toString() ?? 'Fixed package',
      deliveryDays: _toInt(map['deliveryDays'], fallback: 7),
      revisions: _toInt(map['revisions'], fallback: 2),
      features: _stringList(map['features']),
      technologies: _stringList(map['technologies']),
      sortOrder: _toInt(map['sortOrder']),
      published: _toBool(map['published'], fallback: true),
      featured: _toBool(map['featured']),
      ctaLabel: map['ctaLabel']?.toString() ?? 'Choose Package',
      createdAt: _toInt(map['createdAt']),
      updatedAt: _toInt(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'type': PackageTypes.normalize(type),
        'shortDescription': shortDescription,
        'description': description,
        'price': price,
        'currency': currency,
        'pricingNote': pricingNote,
        'deliveryDays': deliveryDays,
        'revisions': revisions,
        'features': features,
        'technologies': technologies,
        'sortOrder': sortOrder,
        'published': published,
        'featured': featured,
        'ctaLabel': ctaLabel,
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

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return fallback;
  }
}

class PackageTypes {
  PackageTypes._();

  static const silver = 'silver';
  static const gold = 'gold';
  static const platinum = 'platinum';
  static const custom = 'custom';

  static const List<String> all = [silver, gold, platinum, custom];

  static String normalize(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (all.contains(normalized)) return normalized!;
    return silver;
  }

  static String label(String type) {
    switch (normalize(type)) {
      case gold:
        return 'Gold';
      case platinum:
        return 'Platinum';
      case custom:
        return 'Custom';
      case silver:
      default:
        return 'Silver';
    }
  }

  static String descriptor(String type) {
    switch (normalize(type)) {
      case gold:
        return 'Balanced & popular';
      case platinum:
        return 'Complete & premium';
      case custom:
        return 'Built around your scope';
      case silver:
      default:
        return 'Focused essentials';
    }
  }
}
