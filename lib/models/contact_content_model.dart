class ContactContentModel {
  final String eyebrow;
  final String title;
  final String subtitle;
  final String email;
  final String phone;
  final String location;
  final String workingHours;
  final String imageUrl;
  final Map<String, String> socialLinks;

  /// Where the public Contact page map is centred (defaults to Lahore).
  final double latitude;
  final double longitude;
  final double mapZoom;

  static const double defaultLatitude = 31.5204;
  static const double defaultLongitude = 74.3587;
  static const double defaultMapZoom = 13;

  const ContactContentModel({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.email,
    required this.phone,
    required this.location,
    required this.workingHours,
    required this.imageUrl,
    required this.socialLinks,
    this.latitude = defaultLatitude,
    this.longitude = defaultLongitude,
    this.mapZoom = defaultMapZoom,
  });

  factory ContactContentModel.fallback() => const ContactContentModel(
        eyebrow: 'GET IN TOUCH',
        title: 'Get In Touch',
        subtitle:
            'I’d love to hear from you. Feel free to reach out for a project, collaboration, or just a hello!',
        email: 'hello@example.com',
        phone: '+92 300 0000000',
        location: 'Lahore, Pakistan',
        workingHours: 'Mon — Fri, 9:00 AM — 6:00 PM',
        imageUrl: '',
        socialLinks: {},
      );

  factory ContactContentModel.fromMap(Map<dynamic, dynamic> map) {
    final fallback = ContactContentModel.fallback();
    final rawLinks = map['socialLinks'];
    final links = <String, String>{};
    if (rawLinks is Map) {
      for (final entry in rawLinks.entries) {
        final value = entry.value?.toString().trim() ?? '';
        if (value.isNotEmpty) links[entry.key.toString()] = value;
      }
    }

    return ContactContentModel(
      eyebrow: _string(map['eyebrow'], fallback.eyebrow),
      title: _string(map['title'], fallback.title),
      subtitle: _string(map['subtitle'], fallback.subtitle),
      email: _string(map['email'], fallback.email),
      phone: _string(map['phone'], fallback.phone),
      location: _string(map['location'], fallback.location),
      workingHours: _string(map['workingHours'], fallback.workingHours),
      imageUrl: _string(map['imageUrl'], ''),
      socialLinks: links,
      latitude: _coordinate(map['latitude'], defaultLatitude, -90, 90),
      longitude: _coordinate(map['longitude'], defaultLongitude, -180, 180),
      mapZoom: _coordinate(map['mapZoom'], defaultMapZoom, 3, 18),
    );
  }

  Map<String, dynamic> toMap() => {
        'eyebrow': eyebrow,
        'title': title,
        'subtitle': subtitle,
        'email': email,
        'phone': phone,
        'location': location,
        'workingHours': workingHours,
        'imageUrl': imageUrl,
        'socialLinks': socialLinks,
        'latitude': latitude,
        'longitude': longitude,
        'mapZoom': mapZoom,
      };

  static String _string(dynamic value, String fallback) =>
      value is String && value.trim().isNotEmpty ? value.trim() : fallback;

  /// Firebase may hand back an int, a double or a string; clamp to a sane range.
  static double _coordinate(dynamic value, double fallback, double min, double max) {
    final parsed = value is num ? value.toDouble() : double.tryParse('$value');
    if (parsed == null || parsed.isNaN) return fallback;
    return parsed.clamp(min, max).toDouble();
  }
}

class ContactMessageModel {
  final String id;
  final String name;
  final String email;
  final String subject;
  final String message;
  final String status;
  final int createdAt;
  final int updatedAt;

  const ContactMessageModel({
    required this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    this.status = 'new',
    this.createdAt = 0,
    this.updatedAt = 0,
  });

  factory ContactMessageModel.fromMap(String id, Map<dynamic, dynamic> map) {
    int toInt(dynamic v) => v is num ? v.round() : 0;
    return ContactMessageModel(
      id: id,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      subject: map['subject']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      status: ContactMessageStatuses.normalize(map['status']?.toString()),
      createdAt: toInt(map['createdAt']),
      updatedAt: toInt(map['updatedAt']),
    );
  }

  ContactMessageModel copyWith({String? status}) => ContactMessageModel(
        id: id,
        name: name,
        email: email,
        subject: subject,
        message: message,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        'status': status,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

/// Inbox states for a contact message (stored in `status`).
class ContactMessageStatuses {
  ContactMessageStatuses._();

  static const newMessage = 'new';
  static const read = 'read';
  static const replied = 'replied';
  static const archived = 'archived';

  static const List<String> all = [newMessage, read, replied, archived];

  static String normalize(String? value) {
    final v = value?.trim().toLowerCase() ?? '';
    return all.contains(v) ? v : newMessage;
  }

  static String label(String value) {
    switch (normalize(value)) {
      case read:
        return 'Read';
      case replied:
        return 'Replied';
      case archived:
        return 'Archived';
      case newMessage:
      default:
        return 'New';
    }
  }
}
