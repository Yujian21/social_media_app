import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostInfo {
  Future savePost(String? content) async {
    await FirebaseFirestore.instance.collection("posts").add({
      'content': content,
      'creator': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
