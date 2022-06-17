import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/utils.dart';

class UserInfo {
  // Instantiate a utilities class (For profile updates 
  // (e.g., upload profile image, check if name/username already exists))
  Utilities utilities = Utilities();

  // Parse a user from a Firebase snapshot to a local user model
  UserModel? userFromFirebaseSnapshot(DocumentSnapshot? snapshot) {
    if (snapshot != null) {
      return UserModel(
        id: snapshot.id,
        name: snapshot['name'] ?? '',
        profileImageUrl: snapshot['profileImageUrl'] ?? '',
        email: snapshot['email'] ?? '',
      );
    } else {
      debugPrint('Snapshot is null');
      return null;
    }
  }

  // Get a user's profile information
  Stream<UserModel?> getUserInfo(uid) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .snapshots()
        .map(userFromFirebaseSnapshot);
  }

  // Get a list of users that a user is following
  Future<List<String>> getUserFollowing(uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();

    final users = querySnapshot.docs.map((doc) => doc.id).toList();
    return users;
  }

  // Update the current user's profile information
  Future<bool?> updateProfile(PlatformFile? uploadFile, String name) async {
    String profileImageUrl = '';
    bool nameExists = false;

    // If the profile image is not null, initiate the upload task, 
    // with a specified path
    if (uploadFile != null) {
      profileImageUrl = await utilities.uploadFile(uploadFile,
          'uploads/${FirebaseAuth.instance.currentUser!.uid}/profile/profile_picture');
    }

    // If the name/username is not empty, check if it already exists 
    // in Firestore, and return the boolean
    if (name != '') {
      nameExists = await utilities.doesNameAlreadyExist(name);
      if (nameExists) {
        return false;
      }
    }

    // Depending on the information the user has chosen to update
    // (e.g., name/username and/or profile image), 
    // add the non-empty information to the payload (Map) to upload to Firestore
    Map<String, dynamic> payloadData = HashMap();

    if (name != '') {
      payloadData['name'] = name;
    }
    if (profileImageUrl != '') {
      payloadData['profileImageUrl'] = profileImageUrl;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update(payloadData);

    return true;
  }

  // Search other users by their username
  Stream<List<UserModel?>> queryByName(search) {
    return FirebaseFirestore.instance
        .collection("users")
        .orderBy("name")
        .startAt([search])
        .endAt([search + '\uf8ff'])
        .limit(10)
        .snapshots()
        .map(_userListFromQuerySnapshot);
  }

  // Parse a list of users from a Firebase snapshot into a list of 
  // local user models
  List<UserModel?> _userListFromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return UserModel(
        id: doc.id,
        name: doc['name'] ?? '',
        profileImageUrl: doc['profileImageUrl'] ?? '',
        email: doc['email'] ?? '',
      );
    }).toList();
  }

  // Get the UID of a searched user by their username
  Future<String?> getUid(String name) async {
    String uid = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: name)
        .get()
        .then((value) {
      return value.docs.first.id;
    });
    return uid;
  }

  // Get the current user's following status on the searched user
  Stream<bool?> isFollowing(uid, name) async* {
    yield* FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("following")
        .doc(await getUid(name))
        .snapshots()
        .map((snapshot) {
      return snapshot.exists;
    });
  }

  // Get the searched user's profile information by their username
  Stream<UserModel?> getSearchedUserInfo(name) async* {
    yield* FirebaseFirestore.instance
        .collection("users")
        .doc(await getUid(name))
        .snapshots()
        .map(userFromFirebaseSnapshot);
  }

  // Follow a user by their username
  Future<void> followSearchedUser(name) async {
    // Add the searched user as a document in the current user's 
    // following subcollection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('following')
        .doc(await getUid(name))
        .set({});

    // Add the current user as a document in the searched user's
    // followers subcollection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(await getUid(name))
        .collection('followers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({});
  }

  // Unfollow a user by their username
  Future<void> unfollowSearchedUser(name) async {
    // Remove the searched user in the current user's 
    // following subcollection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('following')
        .doc(await getUid(name))
        .delete();

    // Remove the current user in the searched user's     
    // followers subcollection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(await getUid(name))
        .collection('followers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();
  }
}
