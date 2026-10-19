/// Mirrors `testimonialSubmissions/{id}`: a testimonial a client submitted
/// through an invite link. Never public; the admin reviews it and, if
/// approved, it is copied into `testimonials/`.
class TestimonialSubmissionModel {
  final String id;
  final String inviteToken;
  final String clientName;
  final String clientRole;
  final String company;
  final String projectName;
  final String quote;
  final int rating;
  final String status;
  final String testimonialId;
  final int createdAt;
  final int reviewedAt;

  const TestimonialSubmissionModel({
    required this.id,
    required this.inviteToken,
    required this.clientName,
    required this.clientRole,
    required this.company,
    required this.projectName,
    required this.quote,
    required this.rating,
    required this.status,
    required this.testimonialId,
    required this.createdAt,
    required this.reviewedAt,
  });

  bool get isPending => status == SubmissionStatuses.pending;

  factory TestimonialSubmissionModel.fromMap(String id, Map<dynamic, dynamic> map) {
    int toInt(dynamic v) => v is num ? v.round() : 0;
    return TestimonialSubmissionModel(
      id: id,
      inviteToken: map['inviteToken']?.toString() ?? '',
      clientName: map['clientName']?.toString() ?? '',
      clientRole: map['clientRole']?.toString() ?? '',
      company: map['company']?.toString() ?? '',
      projectName: map['projectName']?.toString() ?? '',
      quote: map['quote']?.toString() ?? '',
      rating: toInt(map['rating']).clamp(1, 5),
      status: SubmissionStatuses.normalize(map['status']?.toString()),
      testimonialId: map['testimonialId']?.toString() ?? '',
      createdAt: toInt(map['createdAt']),
      reviewedAt: toInt(map['reviewedAt']),
    );
  }

  TestimonialSubmissionModel copyWith({String? status, String? testimonialId}) {
    return TestimonialSubmissionModel(
      id: id,
      inviteToken: inviteToken,
      clientName: clientName,
      clientRole: clientRole,
      company: company,
      projectName: projectName,
      quote: quote,
      rating: rating,
      status: status ?? this.status,
      testimonialId: testimonialId ?? this.testimonialId,
      createdAt: createdAt,
      reviewedAt: reviewedAt,
    );
  }

  String get roleLine =>
      [clientRole, company].where((e) => e.trim().isNotEmpty).join(' · ');
}

class SubmissionStatuses {
  SubmissionStatuses._();
  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';
  static const all = [pending, approved, rejected];

  static String normalize(String? v) {
    final value = v?.trim().toLowerCase() ?? '';
    return all.contains(value) ? value : pending;
  }

  static String label(String v) {
    switch (normalize(v)) {
      case approved:
        return 'Approved';
      case rejected:
        return 'Rejected';
      default:
        return 'Pending';
    }
  }
}
