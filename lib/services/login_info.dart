import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/models/user.dart';

class LoginInfo extends ChangeNotifier {
  // Create a Firebase Athentication service instance
  FirebaseAuth auth = FirebaseAuth.instance;

// Using the user ID as a means to keep track of sign in status
  var userId = '';
  String get id => userId;
  bool get loggedIn => userId.isNotEmpty;

// Verify that 2FA is enabled for the current user
  bool doubleAuthenticationActivated = false;
  bool get doubleAuthenticationActivatedAlt => doubleAuthenticationActivated;

// Verify that the current user is double authenticated
  bool doubleAuthenticated = false;
  bool get doubleAuthenticatedAlt => doubleAuthenticated;

  void isDoubleAuthenticated(BuildContext context) {
    doubleAuthenticated = true;
    debugPrint('Is double authenticated.');
    notifyListeners();
  }

  // Mapping Firebase User model to that of local user model
  UserModel? _createUserFromFirebaseUser(User? user) {
    if (user != null) {
      var currentUser = UserModel(id: user.uid);
      debugPrint('Local user model created!');
      debugPrint('Local user model ID: ' + currentUser.id.toString());
      userId = user.uid;

      return currentUser;
    }
    debugPrint('User is null.');
    return null;
  }

  void firebaseSignIn(BuildContext context, String email, String password,
      Function alert) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = auth.currentUser;

      _createUserFromFirebaseUser(user);

      await FirebaseFirestore.instance
          .collection('2fa-status')
          .where('userId', isEqualTo: user!.uid)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          debugPrint('Entry found');
          doubleAuthenticationActivated = true;
          notifyListeners();
        }
      });
      notifyListeners();
      debugPrint('Sign in successful');
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

  void firebaseSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      userId = '';
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
