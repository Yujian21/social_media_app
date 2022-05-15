import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/models/user.dart';

class AuthenticationService {
  // Create a Firebase Athentication service instance
  FirebaseAuth auth = FirebaseAuth.instance;

  // Firebase auth state changes (page refresh)
  Stream<UserModel?> get currentUser {
    auth.authStateChanges().listen((user) {
      user != null
          ? debugPrint('authStateChanged (value): ' + user.uid)
          : debugPrint('authStateChanged (value): null');
    });
    return auth
        .authStateChanges()
        .map((user) => _createUserFromFirebaseUser(user));
  }

  // Map Firebase user model to local user model
  UserModel? _createUserFromFirebaseUser(User? user) {
    if (user != null) {
      var currentUser = UserModel(id: user.uid);
      debugPrint('Local user model created!');
      debugPrint('Local user model ID: ' + currentUser.id.toString());
      return currentUser;
    }
    debugPrint('User is null.');
    return null;
  }

  // Firebase email & password authentication callback
  void firebaseSignIn(BuildContext context, String email, String password,
      Function alert) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = auth.currentUser;

      _createUserFromFirebaseUser(user);
      debugPrint('Sign in successful');
      context.go('/');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          debugPrint('No user found for that email.');
          break;
        case 'wrong-password':
          debugPrint('Wrong password provided for that user.');
          alert();
          break;
        default:
          debugPrint(e.code);
          break;
      }
    }
  }

  void firebaseSignUp(String email, String password, Function invalidEmail,
      Function weakPassword, Function emailInUse) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = FirebaseAuth.instance.currentUser;
      _createUserFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          debugPrint('The email that has been provided is invalid.');
          invalidEmail();
          break;
        case 'weak-password':
          debugPrint('The password provided is too weak.');
          debugPrint(e.message);
          weakPassword();
          break;
        case 'email-already-in-use':
          debugPrint('An account already exists for that email.');
          emailInUse();
          break;
        default:
          debugPrint(e.code);
      }
    }
  }
}
