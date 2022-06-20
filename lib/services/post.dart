import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiver/iterables.dart';
import '../models/post.dart';
import '../services/user_info.dart' as user_info;

class PostInfo {
  // Save the post created by the user
  Future savePost(String? content) async {
    await FirebaseFirestore.instance.collection("posts").add({
      'content': content,
      'creator': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Parse the post from the Firebase snapshot into 
  // the local post model
  PostModel? postFromSnapshot(DocumentSnapshot snapshot) {
    return snapshot.exists
        ? PostModel(
            id: snapshot.id,
            content: snapshot['content'] ?? '',
            creator: snapshot['creator'] ?? '',
            timestamp: snapshot['timestamp'] ?? 0,
            ref: snapshot.reference,
          )
        : null;
  }

  // Parse the list of posts from the Firebase snapshot into 
  // a list of the local post model
  List<PostModel> postListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return PostModel(
        id: doc.id,
        content: doc['content'] ?? '',
        creator: doc['creator'] ?? '',
        timestamp: doc['timestamp'] ?? 0,
        ref: doc.reference,
      );
    }).toList();
  }

  // Get the feed for the current user
  Future<List<PostModel>> getFeed() async {
    // Get the list of users that the current user is actively following
    List<String> usersFollowing = await user_info.UserInfo()
        .getUserFollowing(FirebaseAuth.instance.currentUser!.uid);
    var splitUsersFollowing = partition<dynamic>(usersFollowing, 10);
    inspect(splitUsersFollowing);
    List<PostModel> feedList = [];

    // For each user that the current user is actively following, 
    // obtain all of his/her posts, parse the posts, and add it to the feed
    for (int i = 0; i < splitUsersFollowing.length; i++) {
      inspect(splitUsersFollowing.elementAt(i));
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('creator', whereIn: splitUsersFollowing.elementAt(i))
          .orderBy('timestamp', descending: true)
          .get();

      feedList.addAll(postListFromSnapshot(querySnapshot));
    }

    // Sort the feed by the timestamps of the posts 
    feedList.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate!.compareTo(adate as Timestamp);
    });

    inspect(feedList);
    return feedList;
  }
}
