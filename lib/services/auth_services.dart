import 'package:firebase_auth/firebase_auth.dart';

import '../models/admin_model.dart';

class AuthServices {
  AuthServices._();
  static final AuthServices instance = AuthServices._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AdminModel?> login(String email, String password) async {
    try {
      final UserCredential user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // map Firebase user to AdminModel
      return AdminModel(
        uid: user.user!.uid,
        name: user.user!.displayName ?? "Admin",
        email: user.user!.email ?? email,
        imgUrl: user.user!.photoURL ?? "",
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    }
  }
  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Something went wrong");
    }
  }
}

