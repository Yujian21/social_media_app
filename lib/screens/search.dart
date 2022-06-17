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
  // Instantiate the User Info class, to use the query by name method
  user_info.UserInfo userInfo = user_info.UserInfo();

  // Initialize the variable for the search text
  String search = '';

  @override
  Widget build(BuildContext context) {
    // This page will constantly listen to the changes in the search input field,
    // and update the list of users accordingly. The list of users will be
    // obtainable via the Provider architecture
    return MultiProvider(
        providers: [
          StreamProvider<List<UserModel?>>.value(
            value: userInfo.queryByName(search),
            initialData: const [],
          ),
        ],
        child: Builder(builder: (BuildContext context) {
          BuildContext rootContext = context;
          // Using the list of users from the Provider architecture, populate
          // the list view accordingly
          final users = Provider.of<List<UserModel?>>(rootContext);

          // If the list of users has not been fully loaded yet,
          // show a circular progress indicator
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
                        // The side menu section (Drawer)
                        const Expanded(
                          flex: 1,
                          child: SideMenu(),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              // The search input field
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
                              // The list of users
                              ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: users.length,
                                  itemBuilder: (context, index) {
                                    final user = users[index];
                                    if (FirebaseAuth
                                            .instance.currentUser!.uid !=
                                        user!.id) {
                                      return Material(
                                        child: InkWell(
                                          onTap: () {
                                            context.goNamed('search-profile',
                                                params: {
                                                  'name': user.name.toString()
                                                });
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
                                                    : const Icon(
                                                        Icons.person_rounded,
                                                        size: 35,
                                                        color: Colors.white,
                                                      ),
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
