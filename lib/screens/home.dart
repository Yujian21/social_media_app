import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/services/post.dart';
// import 'package:social_media_app/models/user.dart';
import '../services/authentication_info.dart';
import '../components/side_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PostInfo postInfo = PostInfo();
  TextEditingController postController = TextEditingController();
  String? postContent;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthenticationInfo>(context);

    return Scaffold(
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: SideMenu(),
            ),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Form(
                      child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                          child: TextFormField(
                              controller: postController,
                              onChanged: (value) => postContent = value,
                              keyboardType: TextInputType.multiline,
                              minLines: 2,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                hintText: 'Type something...',
                              )),
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ElevatedButton(
                                onPressed: () async {
                                  postInfo
                                      .savePost(postContent)
                                      .then((_) => postController.clear());
                                },
                                child: const Text('Post')),
                          ))
                    ],
                  )),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Divider(
                      thickness: 2,
                      color: Colors.white54,
                    ),
                  ),
                  Text(
                    user.id.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
