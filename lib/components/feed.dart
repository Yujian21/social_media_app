import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/post_tile.dart';
import '../services/user_info.dart';
import '../models/post.dart';
import '../models/user.dart';
import '../theme/style.dart';

// The widget for the feed, which contains all of the relevant posts
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
                  return Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(appThemeTertiary)),
                  );
                }
                return PostTile(
                    profileImageUrl: snapshot.data!.profileImageUrl,
                    name: snapshot.data!.name,
                    content: post.content,
                    timeStamp: post.timestamp!);
              });
        });
  }
}
