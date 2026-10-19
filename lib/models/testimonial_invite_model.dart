/// Mirrors `testimonialInvites/{token}`. The key IS the secret token that is
/// embedded in the private link sent to a client.
class TestimonialInviteModel {
  final String token;
  final String clientName;
  final String projectName;
  final int createdAt;
  final int expiresAt;
  final bool used;
  final int usedAt;

  const TestimonialInviteModel({
    required this.token,
    required this.clientName,
    required this.projectName,
    required this.createdAt,
    required this.expiresAt,
    required this.used,
    required this.usedAt,
  });

  bool get expired =>
      expiresAt > 0 && DateTime.now().millisecondsSinceEpoch > expiresAt;

  /// `used`, `expired` or `active`.
  String get status => used ? 'used' : (expired ? 'expired' : 'active');

  factory TestimonialInviteModel.fromMap(String token, Map<dynamic, dynamic> map) {
    int toInt(dynamic v) => v is num ? v.round() : 0;
    return TestimonialInviteModel(
      token: token,
      clientName: map['clientName']?.toString() ?? '',
      projectName: map['projectName']?.toString() ?? '',
      createdAt: toInt(map['createdAt']),
      expiresAt: toInt(map['expiresAt']),
      used: map['used'] == true,
      usedAt: toInt(map['usedAt']),
    );
  }
}
