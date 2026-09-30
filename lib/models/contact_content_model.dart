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
      };

  static String _string(dynamic value, String fallback) =>
      value is String && value.trim().isNotEmpty ? value.trim() : fallback;
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
