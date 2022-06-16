import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_info.dart';
import '../theme/style.dart';
import '../models/post.dart';
import '../models/user.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  UserInfo userInfo = UserInfo();
  @override
  Widget build(BuildContext context) {
    List<PostModel> posts = Provider.of<List<PostModel>>(context);
    return ListView.builder(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return StreamBuilder(
              stream: userInfo.getUserInfo(post.creator),
              builder:
                  (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: appThemeSecondary,
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                        child: Row(
                          children: [
                            snapshot.data!.profileImageUrl != ''
                                ? CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(snapshot
                                        .data!.profileImageUrl
                                        .toString()),
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(snapshot.data!.name.toString()),
                          ],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.content.toString(),
                              style: const TextStyle(color: Colors.white)),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            post.timestamp!.toDate().toString(),
                            style: const TextStyle(color: Colors.white54),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              });
        });
  }
}
