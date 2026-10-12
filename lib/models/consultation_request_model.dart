/// One reference file a visitor attached to a consultation request.
/// Stored under `consultations/{id}/attachments` as a plain map.
class ConsultationAttachment {
  final String name;
  final String url;
  final String publicId;
  final String resourceType;
  final String format;
  final int bytes;

  const ConsultationAttachment({
    required this.name,
    required this.url,
    required this.publicId,
    required this.resourceType,
    required this.format,
    required this.bytes,
  });

  factory ConsultationAttachment.fromMap(Map<dynamic, dynamic> map) {
    return ConsultationAttachment(
      name: map['name']?.toString() ?? '',
      url: map['url']?.toString() ?? '',
      publicId: map['publicId']?.toString() ?? '',
      resourceType: map['resourceType']?.toString() ?? '',
      format: map['format']?.toString() ?? '',
      bytes: map['bytes'] is num ? (map['bytes'] as num).round() : 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'url': url,
    'publicId': publicId,
    'resourceType': resourceType,
    'format': format,
    'bytes': bytes,
  };
}

/// Firebase Realtime Database model for `consultations/{consultationId}`.
///
/// The admin dashboard already reads this node (`name`, `email`,
/// `createdAt` / `updatedAt`), so those keys are kept as-is.
class ConsultationRequestModel {
  final String id;
  final String name;
  final String email;
  final String consultationType;
  final String message;

  /// `yyyy-MM-dd`, empty when the visitor didn't pick one.
  final String preferredDate;

  /// Human label such as `3:30 PM`, empty when not picked.
  final String preferredTime;
  final List<ConsultationAttachment> attachments;
  final String status;

  /// Private notes written by the admin. Never shown to visitors.
  final String adminNotes;
  final int createdAt;
  final int updatedAt;

  const ConsultationRequestModel({
    required this.id,
    required this.name,
    required this.email,
    required this.consultationType,
    required this.message,
    required this.preferredDate,
    required this.preferredTime,
    required this.attachments,
    required this.status,
    this.adminNotes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  ConsultationRequestModel copyWith({String? status, String? adminNotes}) {
    return ConsultationRequestModel(
      id: id,
      name: name,
      email: email,
      consultationType: consultationType,
      message: message,
      preferredDate: preferredDate,
      preferredTime: preferredTime,
      attachments: attachments,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ConsultationRequestModel.fromMap(
    String id,
    Map<dynamic, dynamic> map,
  ) {
    final rawAttachments = map['attachments'];
    final attachments = <ConsultationAttachment>[];
    if (rawAttachments is List) {
      for (final item in rawAttachments) {
        if (item is Map) attachments.add(ConsultationAttachment.fromMap(item));
      }
    } else if (rawAttachments is Map) {
      for (final item in rawAttachments.values) {
        if (item is Map) attachments.add(ConsultationAttachment.fromMap(item));
      }
    }

    return ConsultationRequestModel(
      id: id,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      consultationType: map['consultationType']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      preferredDate: map['preferredDate']?.toString() ?? '',
      preferredTime: map['preferredTime']?.toString() ?? '',
      attachments: attachments,
      status: ConsultationStatuses.normalize(map['status']?.toString()),
      adminNotes: map['adminNotes']?.toString() ?? '',
      createdAt: map['createdAt'] is num
          ? (map['createdAt'] as num).round()
          : 0,
      updatedAt: map['updatedAt'] is num
          ? (map['updatedAt'] as num).round()
          : 0,
    );
  }

  /// Client-created payload. The repository swaps the timestamps for
  /// Firebase `ServerValue.timestamp` when writing.
  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'consultationType': consultationType,
    'message': message,
    'preferredDate': preferredDate,
    'preferredTime': preferredTime,
    'attachments': attachments.map((item) => item.toMap()).toList(),
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}

/// Workflow states for a consultation request (stored in `status`).
class ConsultationStatuses {
  ConsultationStatuses._();

  static const newRequest = 'new';
  static const contacted = 'contacted';
  static const scheduled = 'scheduled';
  static const completed = 'completed';
  static const cancelled = 'cancelled';

  static const List<String> all = [
    newRequest,
    contacted,
    scheduled,
    completed,
    cancelled,
  ];

  static String normalize(String? value) {
    final v = value?.trim().toLowerCase() ?? '';
    return all.contains(v) ? v : newRequest;
  }

  static String label(String value) {
    switch (normalize(value)) {
      case contacted:
        return 'Contacted';
      case scheduled:
        return 'Scheduled';
      case completed:
        return 'Completed';
      case cancelled:
        return 'Cancelled';
      case newRequest:
      default:
        return 'New';
    }
  }
}
