import 'package:cloud_firestore/cloud_firestore.dart';

// The local class in which posts from (a) Firebase snapshot(s) is parsed into
class PostModel {
  final String? id;
  final String? creator;
  final String? content;
  final Timestamp? timestamp;
  DocumentReference? ref;

  PostModel(
      {this.id,
      this.creator,
      this.content,
      this.timestamp,
      this.ref});
}