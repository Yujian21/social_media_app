import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/utils.dart';

class UserInfo {
  Utilities utilities = Utilities();

  // Create local user model from Firebase snapshot
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

    if (uploadFile != null) {
      profileImageUrl = await utilities.uploadFile(uploadFile,
          'uploads/${FirebaseAuth.instance.currentUser!.uid}/profile/profile_picture');
    }

    if (name != '') {
      nameExists = await utilities.doesNameAlreadyExist(name);
      if (nameExists) {
        return false;
      }
    }

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

  // Search other users by username
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

  // Create a list of users from Firebase snapshot
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

  // Get the UID of a searched user by username
  Future<String?> getUid(String name) async {
    String uid = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: name)
        .get()
        .then((value) {
      debugPrint(value.docs.first.id + ' in getUID (user_info) method');
      return value.docs.first.id;
    });
    return uid;
  }

  // Get current user's following status on searched user
  Stream<bool?> isFollowing(uid, name) async* {
    // String? otherUid = await getUid(name);
    // debugPrint('is following alt: ' + otherUid.toString());
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

  // Get the searched user's profile information by username
  Stream<UserModel?> getSearchedUserInfo(name) async* {
    yield* FirebaseFirestore.instance
        .collection("users")
        .doc(await getUid(name))
        .snapshots()
        .map(userFromFirebaseSnapshot);
  }

  // Follow a user by username
  Future<void> followSearchedUser(name) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('following')
        .doc(await getUid(name))
        .set({});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(await getUid(name))
        .collection('followers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({});
  }

  // Unfollow a user by username
  Future<void> unfollowSearchedUser(name) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('following')
        .doc(await getUid(name))
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(await getUid(name))
        .collection('followers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .delete();
  }
}
