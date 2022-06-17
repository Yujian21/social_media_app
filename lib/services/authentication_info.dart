import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthenticationInfo extends ChangeNotifier {
  // Create a Firebase Authentication service instance
  FirebaseAuth auth = FirebaseAuth.instance;

  // Use the user ID as a means to keep track of sign in status
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

  // Add double authentication attempt to Firestore dedicated to Biothenticator
  Future<String> addAttempt() async {
    // Declare the Firestore dedicated to Biothenticator
    FirebaseApp biothenticator = Firebase.app('biothenticator');
    FirebaseFirestore biothenticatorFirestore =
        FirebaseFirestore.instanceFor(app: biothenticator);

    // Create the 2FA attempt under the current user, with
    // additional information such as the email, the platform, and the timestamp
    DocumentReference doc = await biothenticatorFirestore
        .collection('2fa-status')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('attempts')
        .add({
      "isAuthenticated": false,
      "email": FirebaseAuth.instance.currentUser!.email,
      "platform": 'fake social media',
      "timestamp": FieldValue.serverTimestamp()
    });
    return doc.id;
  }

  // Update and log the 2FA attempt
  Future<void> logAttempt(
      String userId, AsyncSnapshot<QuerySnapshot<Object?>> snapshot) async {
    // Declare the Firestore dedicated to Biothenticator
    FirebaseApp biothenticator = Firebase.app('biothenticator');
    FirebaseFirestore biothenticatorFirestore =
        FirebaseFirestore.instanceFor(app: biothenticator);

    // Add the 2FA attempt to the logs
    biothenticatorFirestore
        .collection('2fa-status')
        .doc(userId)
        .collection('logs')
        .doc(snapshot.data!.docs[0].id)
        .set({
      'isAuthenticated': true,
      "email": FirebaseAuth.instance.currentUser!.email,
      "platform": 'fake social media',
      'timestamp': FieldValue.serverTimestamp()
    });

    // Remove the 2FA attempt from the list of attempts that
    // are still actively seeking for authentication
    Future.delayed(const Duration(milliseconds: 1000), () {
      biothenticatorFirestore
          .collection('2fa-status')
          .doc(userId)
          .collection('attempts')
          .doc(snapshot.data!.docs[0].id)
          .delete();
    });
  }

  // Parsing the Firebase User to that of the local user model, and assigning 
  // the user ID, to update the sign in status
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

  // Sign in via Firebase email & password authentication
  void firebaseSignIn(BuildContext context, String email, String password,
      Function userNotFound, Function incorrectPassword) async {
    try {
      // Sign in user with email & password
      await auth.signInWithEmailAndPassword(email: email, password: password);

      // Firebase app dedicated to Biothenticator
      FirebaseApp biothenticator = Firebase.app('biothenticator');
      FirebaseFirestore biothenticatorFirestore =
          FirebaseFirestore.instanceFor(app: biothenticator);

      // Using the current user ID, verify if he/she has 2FA enabled
      await biothenticatorFirestore
          .collection('2fa-status')
          .where(FieldPath.documentId, isEqualTo: auth.currentUser!.uid)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          debugPrint('2FA entry found');
          doubleAuthenticationActivated = true;
        } else {
          debugPrint('2FA entry not found');
        }
      });

      createUserFromFirebaseUser(auth.currentUser);
      debugPrint('Sign in successful');
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        // If the user is not found
        case 'user-not-found':
          debugPrint('No user found for that email.');
          userNotFound();
          break;
        // If the password provided is incorrect
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

  // Sign up via Firebase email & password authentication
  void firebaseSignUp(String email, String password, Function invalidEmail,
      Function weakPassword, Function emailInUse) async {
    try {
      // Sign up user with email & password
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Store the current user in memory for further use later on
      final user = auth.currentUser;
      createUserFromFirebaseUser(auth.currentUser);

      // Reset local double authentication status to false
      doubleAuthenticationActivated = false;
      debugPrint('Sign up successful');

      // Create new user entry in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({"name": email, "email": email, "profileImageUrl": ""});
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        // If the email provided is invalid
        case 'invalid-email':
          debugPrint('The email that has been provided is invalid.');
          invalidEmail();
          break;
        // If the password provided is too weak
        case 'weak-password':
          debugPrint('The password provided is too weak.');
          debugPrint(e.message);
          weakPassword();
          break;
        // If the email provided is already in use
        case 'email-already-in-use':
          debugPrint('An account already exists for that email.');
          emailInUse();
          break;
        default:
          debugPrint(e.code);
      }
    }
  }

  // Sign out via Firebase authentication
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
