import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  Future<User> ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) return current;
    final credential = await _auth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw StateError('Anonymous sign-in failed');
    }
    return user;
  }
}




