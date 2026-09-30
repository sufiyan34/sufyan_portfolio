/// Firebase Realtime Database model for `hireRequests/{requestId}`.
///
/// Public clients can create a request; admin users can read/update the
/// workflow and response fields.
class HireRequestModel {
  final String id;
  final String name;
  final String company;
  final String email;
  final String phone;
  final String projectName;
  final String projectType;
  final String serviceId;
  final String serviceTitle;
  final String packageId;
  final String packageTitle;
  final String budgetRange;
  final String timeline;
  final String preferredPlatform;
  final String preferredContact;
  final String description;
  final List<String> referenceLinks;
  final List<String> attachmentUrls;
  final String status;
  final String priority;
  final String replyMessage;
  final String adminNotes;
  final double offerAmount;
  final String offerCurrency;
  final int offerDeliveryDays;
  final String offerMessage;
  final int createdAt;
  final int updatedAt;
  final int respondedAt;
  final int offerSentAt;

  const HireRequestModel({
    required this.id,
    required this.name,
    required this.company,
    required this.email,
    required this.phone,
    required this.projectName,
    required this.projectType,
    required this.serviceId,
    required this.serviceTitle,
    required this.packageId,
    required this.packageTitle,
    required this.budgetRange,
    required this.timeline,
    required this.preferredPlatform,
    required this.preferredContact,
    required this.description,
    required this.referenceLinks,
    required this.attachmentUrls,
    required this.status,
    required this.priority,
    required this.replyMessage,
    required this.adminNotes,
    required this.offerAmount,
    required this.offerCurrency,
    required this.offerDeliveryDays,
    required this.offerMessage,
    required this.createdAt,
    required this.updatedAt,
    required this.respondedAt,
    required this.offerSentAt,
  });

  factory HireRequestModel.empty() => const HireRequestModel(
    id: '',
    name: '',
    company: '',
    email: '',
    phone: '',
    projectName: '',
    projectType: '',
    serviceId: '',
    serviceTitle: '',
    packageId: '',
    packageTitle: '',
    budgetRange: '',
    timeline: '',
    preferredPlatform: '',
    preferredContact: '',
    description: '',
    referenceLinks: [],
    attachmentUrls: [],
    status: HireRequestStatuses.newRequest,
    priority: HireRequestPriorities.normal,
    replyMessage: '',
    adminNotes: '',
    offerAmount: 0,
    offerCurrency: 'PKR',
    offerDeliveryDays: 0,
    offerMessage: '',
    createdAt: 0,
    updatedAt: 0,
    respondedAt: 0,
    offerSentAt: 0,
  );

  HireRequestModel copyWith({
    String? id,
    String? name,
    String? company,
    String? email,
    String? phone,
    String? projectName,
    String? projectType,
    String? serviceId,
    String? serviceTitle,
    String? packageId,
    String? packageTitle,
    String? budgetRange,
    String? timeline,
    String? preferredPlatform,
    String? preferredContact,
    String? description,
    List<String>? referenceLinks,
    List<String>? attachmentUrls,
    String? status,
    String? priority,
    String? replyMessage,
    String? adminNotes,
    double? offerAmount,
    String? offerCurrency,
    int? offerDeliveryDays,
    String? offerMessage,
    int? createdAt,
    int? updatedAt,
    int? respondedAt,
    int? offerSentAt,
  }) {
    return HireRequestModel(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      projectName: projectName ?? this.projectName,
      projectType: projectType ?? this.projectType,
      serviceId: serviceId ?? this.serviceId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      packageId: packageId ?? this.packageId,
      packageTitle: packageTitle ?? this.packageTitle,
      budgetRange: budgetRange ?? this.budgetRange,
      timeline: timeline ?? this.timeline,
      preferredPlatform: preferredPlatform ?? this.preferredPlatform,
      preferredContact: preferredContact ?? this.preferredContact,
      description: description ?? this.description,
      referenceLinks: referenceLinks ?? this.referenceLinks,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      replyMessage: replyMessage ?? this.replyMessage,
      adminNotes: adminNotes ?? this.adminNotes,
      offerAmount: offerAmount ?? this.offerAmount,
      offerCurrency: offerCurrency ?? this.offerCurrency,
      offerDeliveryDays: offerDeliveryDays ?? this.offerDeliveryDays,
      offerMessage: offerMessage ?? this.offerMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      offerSentAt: offerSentAt ?? this.offerSentAt,
    );
  }

  factory HireRequestModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return HireRequestModel(
      id: id,
      name: _string(map['name']),
      company: _string(map['company']),
      email: _string(map['email']),
      phone: _string(map['phone']),
      projectName: _string(map['projectName']),
      projectType: _string(map['projectType']),
      serviceId: _string(map['serviceId']),
      serviceTitle: _string(map['serviceTitle']),
      packageId: _string(map['packageId']),
      packageTitle: _string(map['packageTitle']),
      budgetRange: _string(map['budgetRange']),
      timeline: _string(map['timeline']),
      preferredPlatform: _string(map['preferredPlatform']),
      preferredContact: _string(map['preferredContact']),
      description: _string(map['description']),
      referenceLinks: _stringList(map['referenceLinks']),
      attachmentUrls: _stringList(map['attachmentUrls']),
      status: HireRequestStatuses.normalize(_string(map['status'])),
      priority: HireRequestPriorities.normalize(_string(map['priority'])),
      replyMessage: _string(map['replyMessage']),
      adminNotes: _string(map['adminNotes']),
      offerAmount: _double(map['offerAmount']),
      offerCurrency: _string(map['offerCurrency']).isEmpty
          ? 'PKR'
          : _string(map['offerCurrency']),
      offerDeliveryDays: _int(map['offerDeliveryDays']),
      offerMessage: _string(map['offerMessage']),
      createdAt: _int(map['createdAt']),
      updatedAt: _int(map['updatedAt']),
      respondedAt: _int(map['respondedAt']),
      offerSentAt: _int(map['offerSentAt']),
    );
  }

  /// Full client-created payload. The repository replaces created/updated
  /// timestamps with Firebase ServerValue.timestamp when writing.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'company': company,
      'email': email,
      'phone': phone,
      'projectName': projectName,
      'projectType': projectType,
      'serviceId': serviceId,
      'serviceTitle': serviceTitle,
      'packageId': packageId,
      'packageTitle': packageTitle,
      'budgetRange': budgetRange,
      'timeline': timeline,
      'preferredPlatform': preferredPlatform,
      'preferredContact': preferredContact,
      'description': description,
      'referenceLinks': referenceLinks,
      'attachmentUrls': attachmentUrls,
      'status': HireRequestStatuses.normalize(status),
      'priority': HireRequestPriorities.normalize(priority),
      'replyMessage': replyMessage,
      'adminNotes': adminNotes,
      'offerAmount': offerAmount,
      'offerCurrency': offerCurrency,
      'offerDeliveryDays': offerDeliveryDays,
      'offerMessage': offerMessage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'respondedAt': respondedAt,
      'offerSentAt': offerSentAt,
    };
  }

  static String _string(dynamic value) => value?.toString().trim() ?? '';

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _double(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _stringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is Map) {
      return value.values
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    final single = value.toString().trim();
    return single.isEmpty ? const [] : [single];
  }
}

class HireRequestStatuses {
  HireRequestStatuses._();

  static const newRequest = 'new';
  static const reviewing = 'reviewing';
  static const contacted = 'contacted';
  static const requirementDiscussion = 'requirement_discussion';
  static const proposalSent = 'proposal_sent';
  static const negotiation = 'negotiation';
  static const approved = 'approved';
  static const inDevelopment = 'in_development';
  static const completed = 'completed';
  static const rejected = 'rejected';
  static const cancelled = 'cancelled';

  static const List<String> all = [
    newRequest,
    reviewing,
    contacted,
    requirementDiscussion,
    proposalSent,
    negotiation,
    approved,
    inDevelopment,
    completed,
    rejected,
    cancelled,
  ];

  static String normalize(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    return all.contains(normalized) ? normalized : newRequest;
  }

  static String label(String value) {
    switch (normalize(value)) {
      case reviewing:
        return 'Reviewing';
      case contacted:
        return 'Contacted';
      case requirementDiscussion:
        return 'Requirement Discussion';
      case proposalSent:
        return 'Proposal Sent';
      case negotiation:
        return 'Negotiation';
      case approved:
        return 'Approved';
      case inDevelopment:
        return 'In Development';
      case completed:
        return 'Completed';
      case rejected:
        return 'Rejected';
      case cancelled:
        return 'Cancelled';
      case newRequest:
      default:
        return 'New';
    }
  }
}

class HireRequestPriorities {
  HireRequestPriorities._();

  static const low = 'low';
  static const normal = 'normal';
  static const high = 'high';
  static const urgent = 'urgent';

  static const all = [low, normal, high, urgent];

  static String normalize(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    return all.contains(normalized) ? normalized : normal;
  }

  static String label(String? value) {
    switch (normalize(value)) {
      case low:
        return 'Low';
      case normal:
        return 'Normal';
      case high:
        return 'High';
      case urgent:
        return 'Urgent';
      default:
        return 'Normal';
    }
  }
}
