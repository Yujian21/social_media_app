import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/feed.dart';
import '../services/post.dart';
import '../models/post.dart';
import '../components/side_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Instantiate the Post Info class, to use the get feed method
  final PostInfo postInfo = PostInfo();

  // Initialize the controller and the variables for the post
  TextEditingController postController = TextEditingController();
  String? postContent;

  @override
  Widget build(BuildContext context) {
    // This page depends on a future, which are the posts 
    // in which to populate the feed
    return FutureProvider<List<PostModel>>(
      create: (context) => postInfo.getFeed(),
      initialData: const [],
      child: Scaffold(
        drawer: const SideMenu(),
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The side menu section (Drawer)
              const Expanded(
                child: SideMenu(),
              ),
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  primary: false,
                  physics: const ScrollPhysics(),
                  child: Column(
                    children: [
                      // The post creation section 
                      // (Post content input field and submit button)
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
                      // The feed section (Containing all of the various 
                      // posts from followed users)
                      const Feed()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
