/// Firebase Realtime Database model for `users/{uid}`.
///
/// `role` and `active` are authorization fields set at sign-up. The profile
/// screen only ever WRITES the editable fields (see [toEditableMap]) so it
/// can never change who is allowed into the admin area.
class AdminProfileModel {
  final String uid;
  final String email;
  final String displayName;
  final String jobTitle;
  final String phone;
  final String photoUrl;
  final String photoPublicId;
  final String role;
  final bool active;
  final int createdAt;
  final int updatedAt;

  const AdminProfileModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.jobTitle,
    required this.phone,
    required this.photoUrl,
    required this.photoPublicId,
    required this.role,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminProfileModel.empty({
    String uid = '',
    String email = '',
    String displayName = '',
  }) => AdminProfileModel(
    uid: uid,
    email: email,
    displayName: displayName,
    jobTitle: '',
    phone: '',
    photoUrl: '',
    photoPublicId: '',
    role: '',
    active: true,
    createdAt: 0,
    updatedAt: 0,
  );

  factory AdminProfileModel.fromMap(
    String uid,
    Map<dynamic, dynamic> map, {
    String fallbackEmail = '',
    String fallbackName = '',
  }) {
    String text(dynamic v) => v?.toString().trim() ?? '';
    int number(dynamic v) => v is num ? v.round() : 0;

    final email = text(map['email']);
    final name = text(map['displayName']);

    return AdminProfileModel(
      uid: uid,
      email: email.isEmpty ? fallbackEmail : email,
      displayName: name.isEmpty ? fallbackName : name,
      jobTitle: text(map['jobTitle']),
      phone: text(map['phone']),
      photoUrl: text(map['photoUrl']),
      photoPublicId: text(map['photoPublicId']),
      role: text(map['role']),
      active:
          map['active'] == true ||
          map['active']?.toString().toLowerCase() == 'true',
      createdAt: number(map['createdAt']),
      updatedAt: number(map['updatedAt']),
    );
  }

  AdminProfileModel copyWith({
    String? displayName,
    String? jobTitle,
    String? phone,
    String? photoUrl,
    String? photoPublicId,
  }) {
    return AdminProfileModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      jobTitle: jobTitle ?? this.jobTitle,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      photoPublicId: photoPublicId ?? this.photoPublicId,
      role: role,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// The ONLY fields the profile screen is allowed to write.
  Map<String, dynamic> toEditableMap() => {
    'displayName': displayName,
    'jobTitle': jobTitle,
    'phone': phone,
    'photoUrl': photoUrl,
    'photoPublicId': photoPublicId,
  };

  String get roleLabel {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return 'Super Admin';
      case 'admin':
        return 'Admin';
      case '':
        return 'Administrator';
      default:
        return role;
    }
  }
}
