import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthenticationInfo extends ChangeNotifier {
  // Declare the Firestore dedicated to Biothenticator
  FirebaseFirestore biothenticatorFirestore =
      FirebaseFirestore.instanceFor(app: Firebase.app('biothenticator'));

  // Create a Firebase Authentication service instance
  FirebaseAuth auth = FirebaseAuth.instance;

  // Use the user ID as a means to keep track of sign in status
  var userId = '';
  String get id => userId;
  bool get signedIn => userId.isNotEmpty;

  /*
  
  Two-Factor Authentication (2FA) methods via Biothenticator
  
  */

  // Verify that 2FA is enabled for the current user
  bool doubleAuthenticationActivated = false;
  bool get doubleAuthenticationActivatedAlt => doubleAuthenticationActivated;

  // Verify that the current user has been double authenticated
  bool doubleAuthenticated = false;
  bool get doubleAuthenticatedAlt => doubleAuthenticated;

  // Check if current user has 2FA enabled
  Future<void> checkIsDoubleAuthenticated() async {
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
  }

  // Toggle the current user's 2FA status
  void toggleIsDoubleAuthenticated(BuildContext context) {
    doubleAuthenticated = true;
    debugPrint('Is double authenticated.');
    notifyListeners();
  }

  // Add the 2FA setup
  Future<void> addSetup() async {
    // Create the 2FA setup under the current user
    await biothenticatorFirestore
        .collection('2fa-setup')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({});
  }

  // Cancel the 2FA setup
  Future<void> cancelSetup() async {
    // Cancel the 2FA setup under the current user
    await biothenticatorFirestore
        .collection('2fa-setup')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();
  }

  // Check if a 2FA setup is ongoing
  Stream<bool?> checkSetupExists() async* {
    // Check if there exists a 2FA setup under the current user
    yield* biothenticatorFirestore
        .collection("2fa-setup")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.exists;
    });
  }

  // Add the 2FA attempt
  Future<String> addAttempt() async {
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

  Future verifyFallbackPin(String pin, String? authDocID, Function incorrectPin,
      Function invalidPin) async {
    if (pin.length == 6) {
      await biothenticatorFirestore
          .collection('2fa-status')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((documentSnapshot) {
        // If the fallback PIN is correct
        if (documentSnapshot['fallbackPin'] == pin) {
          biothenticatorFirestore
              .collection('2fa-status')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('attempts')
              .doc(authDocID)
              .update({'isAuthenticated': true});
        } else {
          incorrectPin();
        }
      });
    } else {
      invalidPin();
    }
  }

  // Parsing the Firebase User to that of the local user model, and assigning
  // the user ID, to update the sign in status
  UserModel? createUserFromFirebaseUser(User? user) {
    if (user != null) {
      var currentUser = UserModel(id: user.uid);
      userId = user.uid;

      return currentUser;
    }
    return null;
  }

  // Sign in via Firebase email & password authentication
  void firebaseSignIn(BuildContext context, String email, String password,
      Function userNotFound, Function invalidCombo) async {
    try {
      // Sign in user with email & password
      await auth.signInWithEmailAndPassword(email: email, password: password);

      // Check if 2FA has been enabled for the current user
      await checkIsDoubleAuthenticated();

      createUserFromFirebaseUser(auth.currentUser);
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
          debugPrint('Invalid email and password combination.');
          invalidCombo();
          break;
        // If the email provided is invalid
        case 'invalid-email':
          debugPrint('Invalid email and password combination.');
          invalidCombo();
          break;
        default:
          debugPrint(e.code);
          break;
      }
    }
  }

  // Sign up via Firebase email & password authentication
  void firebaseSignUp(String email, String password, Function success,
      Function invalidEmail, Function weakPassword, Function emailInUse) async {
    try {
      // Sign up user with email & password
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Store the current user in memory for further use later on
      final user = auth.currentUser;
      createUserFromFirebaseUser(auth.currentUser);

      // Reset local double authentication status to false
      doubleAuthenticationActivated = false;
      success();

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
