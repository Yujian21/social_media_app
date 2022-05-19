import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/style.dart';
import '../components/side_menu.dart';
import '../services/user_info.dart' as user_info;
import '../models/user.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  user_info.UserInfo userInfo = user_info.UserInfo();
  String search = '';
  // String uid = 'null';
  // Map<String, dynamic> uidIsFollowing = {};
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          StreamProvider<List<UserModel?>>.value(
            value: userInfo.queryByName(search),
            initialData: const [],
          ),
          // StreamProvider<bool>.value(
          //     value: userInfo.isFollowing(
          //         FirebaseAuth.instance.currentUser!.uid, uid),
          //     initialData: false)
        ],
        child: Builder(builder: (BuildContext context) {
          BuildContext rootContext = context;
          final users = Provider.of<List<UserModel?>>(rootContext);
          return users == []
              ? Scaffold(
                  body: Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(appThemeTertiary))))
              : Scaffold(
                  drawer: const SideMenu(),
                  body: SafeArea(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 1,
                          child: SideMenu(),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              Material(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 8, 16),
                                  child: SizedBox(
                                    width: 350,
                                    child: TextField(
                                      onChanged: (text) {
                                        setState(() {
                                          search = text;
                                        });
                                      },
                                      decoration: const InputDecoration(
                                          hintText: 'Search by username...'),
                                    ),
                                  ),
                                ),
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: users.length,
                                  itemBuilder: (context, index) {
                                    final user = users[index];
                                    // uidIsFollowing['$index'] = user!.id;
                                    // debugPrint(
                                    //     uidIsFollowing['$index'].toString());
                                    // uid = uidIsFollowing['$index'];
                                    // debugPrint('local uid is: ' + uid);
                                    if (FirebaseAuth
                                            .instance.currentUser!.uid !=
                                        user!.id) {
                                      return Material(
                                        child: InkWell(
                                          onTap: () {
                                            context.go('/visit-profile',
                                                extra: user);
                                            // debugPrint(
                                            //     users[index]!.id.toString());
                                            // debugPrint(
                                            //     users[index]!.name.toString());
                                            // debugPrint(
                                            //     users[index]!.email.toString());
                                            // debugPrint(users[index]!
                                            //     .profileImageUrl
                                            //     .toString());
                                            // uid = users[index]!.id.toString();
                                            // debugPrint('local var is: ' + uid);
                                          },
                                          child: Column(children: [
                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(children: [
                                                user.profileImageUrl != ''
                                                    ? CircleAvatar(
                                                        radius: 20,
                                                        backgroundImage:
                                                            NetworkImage(user
                                                                .profileImageUrl
                                                                .toString()),
                                                      )
                                                    : const Icon(Icons.person,
                                                        size: 40),
                                                const SizedBox(width: 10),
                                                Text(user.name.toString()),
                                              ]),
                                            ),
                                          ]),
                                        ),
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        }));
  }
}
