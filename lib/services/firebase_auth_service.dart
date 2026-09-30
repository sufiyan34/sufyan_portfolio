import 'package:firebase_auth/firebase_auth.dart';
import 'package:sufyan_portfolio/services/realtime_db_service.dart';

/// Safe, user-facing authentication exception used by the admin UI.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

/// Firebase Authentication wrapper for the private admin area.
///
/// Authentication proves the account identity. The Realtime Database
/// `users/{uid}` record determines whether the signed-in account is allowed
/// to use the admin dashboard (`role` + `active`).
class FirebaseAuthService {
  FirebaseAuthService._();
  static final FirebaseAuthService instance = FirebaseAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw AuthException('Sign-in failed. Please try again.');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageForCode(e.code));
    }
  }

  /// Creates an admin account and its authorization profile.
  ///
  /// This is intended as a bootstrap/admin onboarding flow. Once your first
  /// admin exists, protect or remove the public sign-up route with your
  /// Firebase Security Rules / a controlled invitation flow.
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw AuthException('Account creation failed. Please try again.');
      }

      final cleanName = displayName.trim();
      if (cleanName.isNotEmpty) {
        await user.updateDisplayName(cleanName);
      }

      await RealtimeDbService.instance.set('users/${user.uid}', {
        'uid': user.uid,
        'email': user.email ?? email.trim(),
        'displayName': cleanName.isEmpty ? 'Administrator' : cleanName,
        'role': 'superAdmin',
        'active': true,
        'createdAt': RealtimeDbService.instance.serverTimestamp,
        'updatedAt': RealtimeDbService.instance.serverTimestamp,
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_signUpMessageForCode(e.code));
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Loads `users/{uid}` so admin role/access can be validated.
  Future<Map<dynamic, dynamic>?> loadProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    return RealtimeDbService.instance.readOnce('users/$uid');
  }

  String _messageForCode(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return 'Sign-in failed ($code). Please try again.';
    }
  }

  String _signUpMessageForCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled in Firebase.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return 'Account creation failed ($code). Please try again.';
    }
  }
}
