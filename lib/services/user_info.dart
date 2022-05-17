import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../models/user.dart';
import '../services/utils.dart';

class UserInfo {
  Utilities utilities = Utilities();

  // Create local user model from Firebase snapshot
  UserModel? userFromFirebaseSnapshot(DocumentSnapshot? snapshot) {
    if (snapshot != null) {
      debugPrint(snapshot['name']);
      debugPrint(snapshot['email']);
      debugPrint(snapshot['profileImageUrl']);
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

  // Get current user's profile information
  Stream<UserModel?> getUserInfo(uid) {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .snapshots()
        .map(userFromFirebaseSnapshot);
  }

  // Update profile callback
  Future<void> updateProfile(
      PlatformFile? uploadFile, String name, String email) async {
    String profileImageUrl = '';

    if (uploadFile != null) {
      profileImageUrl = await utilities.uploadFile(uploadFile,
          'uploads/${FirebaseAuth.instance.currentUser!.uid}/profile/profile_picture');
    }

    Map<String, dynamic> payloadData = HashMap();

    if (name != '') {
      payloadData['name'] = name;
    }
    if (email != '') {
      payloadData['email'] = email;
    }
    if (profileImageUrl != '') {
      payloadData['profileImageUrl'] = profileImageUrl;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update(payloadData);
  }

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
}
