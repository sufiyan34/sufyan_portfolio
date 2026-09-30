/// Public About page content stored under `aboutContent` in Firebase RTDB.
///
/// The nested journey / traits / capabilities collections are intentionally
/// modeled here so the future Admin Site Management page can edit them
/// without changing the public UI contract.
class AboutContentModel {
  final String eyebrow;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String signature;
  final String availabilityLabel;
  final List<AboutJourneyItem> journey;
  final List<String> traits;
  final List<String> capabilities;
  final int updatedAt;

  const AboutContentModel({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.signature,
    required this.availabilityLabel,
    required this.journey,
    required this.traits,
    required this.capabilities,
    required this.updatedAt,
  });

  factory AboutContentModel.fallback() => const AboutContentModel(
        eyebrow: 'ABOUT ME',
        title: 'About Me',
        subtitle: 'Building useful digital products with thoughtful engineering.',
        description:
            'I am a software engineer focused on building modern, reliable, and scalable products. I care about clean code, thoughtful interfaces, and solutions that are practical for real people and real businesses.',
        imageUrl: '',
        signature: 'Sufyan',
        availabilityLabel: 'Available for Opportunities',
        journey: [
          AboutJourneyItem(
            title: 'Bachelor in Software Engineering',
            period: '2019 — 2023',
            description: 'Built a strong foundation in software engineering, systems, and application development.',
            sortOrder: 1,
          ),
          AboutJourneyItem(
            title: 'Flutter Developer',
            period: '2024 — Present',
            description: 'Designing and shipping responsive Flutter applications for web and mobile.',
            sortOrder: 2,
          ),
          AboutJourneyItem(
            title: 'Software Developer',
            period: '2023 — Present',
            description: 'Working across frontend, backend integration, APIs, Firebase, and product delivery.',
            sortOrder: 3,
          ),
          AboutJourneyItem(
            title: 'Open for Opportunities',
            period: 'Current',
            description: 'Open to meaningful product work, freelance projects, and long-term collaborations.',
            sortOrder: 4,
          ),
        ],
        traits: [
          'Clean Code',
          'Problem Solver',
          'Team Player',
          'Always Learning',
        ],
        capabilities: [
          'Mobile App Development (Flutter)',
          'Web Development',
          'Frontend & Backend Integration',
          'API Integration',
          'UI/UX Implementation',
          'Maintenance & Support',
        ],
        updatedAt: 0,
      );

  factory AboutContentModel.fromMap(Map<dynamic, dynamic> map) {
    final fallback = AboutContentModel.fallback();

    return AboutContentModel(
      eyebrow: _string(map['eyebrow'], fallback.eyebrow),
      title: _string(map['title'], fallback.title),
      subtitle: _string(map['subtitle'], fallback.subtitle),
      description: _string(map['description'], fallback.description),
      imageUrl: _string(map['imageUrl'], ''),
      signature: _string(map['signature'], fallback.signature),
      availabilityLabel: _string(
        map['availabilityLabel'],
        fallback.availabilityLabel,
      ),
      journey: _journeyList(map['journey'], fallback.journey),
      traits: _stringList(map['traits'], fallback.traits),
      capabilities: _stringList(map['capabilities'], fallback.capabilities),
      updatedAt: _int(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'eyebrow': eyebrow,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'imageUrl': imageUrl,
        'signature': signature,
        'availabilityLabel': availabilityLabel,
        'journey': {
          for (final item in journey) item.title.toLowerCase().replaceAll(' ', '_'): item.toMap(),
        },
        'traits': traits,
        'capabilities': capabilities,
        'updatedAt': updatedAt,
      };

  AboutContentModel copyWith({
    String? eyebrow,
    String? title,
    String? subtitle,
    String? description,
    String? imageUrl,
    String? signature,
    String? availabilityLabel,
    List<AboutJourneyItem>? journey,
    List<String>? traits,
    List<String>? capabilities,
    int? updatedAt,
  }) {
    return AboutContentModel(
      eyebrow: eyebrow ?? this.eyebrow,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      signature: signature ?? this.signature,
      availabilityLabel: availabilityLabel ?? this.availabilityLabel,
      journey: journey ?? this.journey,
      traits: traits ?? this.traits,
      capabilities: capabilities ?? this.capabilities,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _string(dynamic value, String fallback) =>
      value is String && value.trim().isNotEmpty ? value.trim() : fallback;

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _stringList(
    dynamic value,
    List<String> fallback,
  ) {
    if (value is List) {
      final result = value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
      return result.isEmpty ? fallback : result;
    }
    if (value is Map) {
      final result = value.values
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
      return result.isEmpty ? fallback : result;
    }
    return fallback;
  }

  static List<AboutJourneyItem> _journeyList(
    dynamic value,
    List<AboutJourneyItem> fallback,
  ) {
    if (value is List) {
      final result = <AboutJourneyItem>[];
      for (var i = 0; i < value.length; i++) {
        final raw = value[i];
        if (raw is Map) {
          result.add(
            AboutJourneyItem.fromMap(
              raw,
              fallbackSortOrder: i + 1,
            ),
          );
        }
      }
      result.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return result.isEmpty ? fallback : result;
    }

    if (value is Map) {
      final result = value.entries.map((entry) {
        final raw = Map<dynamic, dynamic>.from(entry.value as Map);
        return AboutJourneyItem.fromMap(
          raw,
          fallbackSortOrder: int.tryParse(entry.key.toString()) ?? 0,
        );
      }).toList();
      result.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return result.isEmpty ? fallback : result;
    }

    return fallback;
  }
}

class AboutJourneyItem {
  final String title;
  final String period;
  final String description;
  final int sortOrder;

  const AboutJourneyItem({
    required this.title,
    required this.period,
    required this.description,
    required this.sortOrder,
  });

  factory AboutJourneyItem.fromMap(
    Map<dynamic, dynamic> map, {
    required int fallbackSortOrder,
  }) {
    return AboutJourneyItem(
      title: (map['title'] as String? ?? '').trim(),
      period: (map['period'] as String? ?? '').trim(),
      description: (map['description'] as String? ?? '').trim(),
      sortOrder: map['sortOrder'] is num
          ? (map['sortOrder'] as num).toInt()
          : fallbackSortOrder,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'period': period,
        'description': description,
        'sortOrder': sortOrder,
      };
}
