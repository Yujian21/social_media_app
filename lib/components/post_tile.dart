import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/style.dart';

// The widget for the post tile, found in the feed (home page)
class PostTile extends StatelessWidget {
  const PostTile({Key? key, required this.profileImageUrl, required this.name, required this.content, required this.timeStamp}) : super(key: key);
  final String? profileImageUrl;
  final String? name;
  final String? content;
  final Timestamp? timeStamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: appThemeSecondary, borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
            child: Row(
              children: [
                profileImageUrl != ''
                    ? CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            NetworkImage(profileImageUrl.toString()),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        size: 30,
                        color: Colors.white,
                      ),
                const SizedBox(
                  width: 10,
                ),
                Text(name.toString()),
              ],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(content.toString(),
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(
                height: 15,
              ),
              Text(
                timeStamp!.toDate().toString(),
                style: const TextStyle(color: Colors.white54),
              )
            ],
          ),
        ),
      ),
    );
  }
}
