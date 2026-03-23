import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // login
  Future<(String token, AppUser user)> login(
      String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user!;
    final token = await user.getIdToken();

    return (
    token!,
    AppUser(
      id: user.uid,
      email: user.email ?? '',
    )
    );
  }

  // register
  Future<(String token, AppUser user)> register(
      String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user!;
    final token = await user.getIdToken();

    return (
    token!,
    AppUser(
      id: user.uid,
      email: user.email ?? '',
    )
    );
  }

  // get current user
  Future<(String token, AppUser user)?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final token = await user.getIdToken();

    return (
    token!,
    AppUser(
      id: user.uid,
      email: user.email ?? '',
    )
    );
  }

  // logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}