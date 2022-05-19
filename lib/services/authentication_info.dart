import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/user.dart';

class AuthenticationInfo extends ChangeNotifier {
  // Create a Firebase Authentication service instance
  FirebaseAuth auth = FirebaseAuth.instance;

// Using the user ID as a means to keep track of sign in status
  var userId = '';
  String get id => userId;
  bool get signedIn => userId.isNotEmpty;

// Verify that 2FA is enabled for the current user
  bool doubleAuthenticationActivated = false;
  bool get doubleAuthenticationActivatedAlt => doubleAuthenticationActivated;

// Verify that the current user is double authenticated
  bool doubleAuthenticated = false;
  bool get doubleAuthenticatedAlt => doubleAuthenticated;

// Toggle the current user's 2FA status
  void isDoubleAuthenticated(BuildContext context) {
    doubleAuthenticated = true;
    debugPrint('Is double authenticated.');
    notifyListeners();
  }

  // Mapping Firebase User model to that of local user model
  UserModel? createUserFromFirebaseUser(User? user) {
    if (user != null) {
      debugPrint('User is not null.');
      var currentUser = UserModel(id: user.uid);
      debugPrint('Local user model created!');
      debugPrint('Local user model ID: ' + currentUser.id.toString());
      userId = user.uid;

      return currentUser;
    }
    debugPrint('User is null.');
    return null;
  }

  Stream<UserModel?> get user {
    return auth.authStateChanges().map(createUserFromFirebaseUser);
  }

  // Firebase email & password authentication callback
  void firebaseSignIn(BuildContext context, String email, String password,
      Function userNotFound, Function incorrectPassword) async {
    try {
      // Sign in user with email & password
      await auth.signInWithEmailAndPassword(email: email, password: password);

      // Firebase app dedicated to Biothenticator
      FirebaseApp biothenticator = Firebase.app('biothenticator');
      FirebaseFirestore biothenticatorFirestore =
          FirebaseFirestore.instanceFor(app: biothenticator);

      // Store the current user in memory for further use later on
      final user = auth.currentUser;
      

      // Using the current user ID, verify if he/she has 2FA enabled
      await biothenticatorFirestore
          .collection('2fa-status')
          .where('userId', isEqualTo: user!.uid)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          debugPrint('2FA entry found');
          doubleAuthenticationActivated = true;
        }
      });

      createUserFromFirebaseUser(user);
      debugPrint('Sign in successful');
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          debugPrint('No user found for that email.');
          userNotFound();
          break;
        case 'wrong-password':
          debugPrint('Wrong password provided for that user.');
          incorrectPassword();
          break;
        default:
          debugPrint(e.code);
          break;
      }
    }
  }

  // Firebase email & password sign up callback
  void firebaseSignUp(String email, String password, Function invalidEmail,
      Function weakPassword, Function emailInUse) async {
    try {
      // Sign up user with email & password
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Store the current user in memory for further use later on
      final user = auth.currentUser;
      createUserFromFirebaseUser(user);

      // Reset local double authentication status to false
      doubleAuthenticationActivated = false;
      debugPrint('Sign up successful');

      // Create new user entry in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({"name": email, "email": email, "profileImageUrl": ''});
      notifyListeners();
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

// Firebase sign out callback
  void firebaseSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Reset all authentication state variables to their default values
      userId = '';
      doubleAuthenticated = false;
      doubleAuthenticationActivated = false;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
