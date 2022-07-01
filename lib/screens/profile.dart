import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../theme/style.dart';
import '../services/user_info.dart' as user_info;
import '../components/side_menu.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Instantiate the User Info class, to use the get user info method
  user_info.UserInfo userInfo = user_info.UserInfo();

  // Initialize the variable for the profile image
  PlatformFile? uploadFile;

  @override
  Widget build(BuildContext context) {
    // This page will obtain information on the current user, which will become
    // obtainable via the Provider architecture
    return MultiProvider(
        providers: [
          StreamProvider<UserModel?>(
              create: (_) =>
                  userInfo.getUserInfo(FirebaseAuth.instance.currentUser!.uid),
              initialData: null)
        ],
        child: Builder(
          builder: (BuildContext context) {
            BuildContext rootContext = context;
            // Using the profile information obtained from the
            // Provider architecture, show the profile image and the name/username
            final userProfile = Provider.of<UserModel?>(rootContext);

            // If the current user's profile is not fully loaded, show a
            // circular progress indicator
            return userProfile == null
                ? Scaffold(
                    body: Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                appThemeTertiary))))
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
                          // The current user's profile image
                          Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Column(children: [
                                  Stack(children: <Widget>[
                                    Provider.of<UserModel?>(rootContext)!
                                            .profileImageUrl
                                            .toString()
                                            .isEmpty
                                        ? CircleAvatar(
                                            radius: 125,
                                            backgroundColor: appThemeSecondary,
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            ),
                                          )
                                        : CircleAvatar(
                                            radius: 125,
                                            backgroundImage: NetworkImage(
                                                Provider.of<UserModel?>(
                                                        rootContext)!
                                                    .profileImageUrl
                                                    .toString()),
                                          ),
                                  ]),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  // The current user's name/username
                                  Text(Provider.of<UserModel?>(rootContext)!
                                      .name
                                      .toString()),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  // The edit/update profile button
                                  ElevatedButton(
                                      onPressed: () {
                                        GoRouter.of(context)
                                            .go('/edit-profile');
                                      },
                                      child: const Text('Edit profile')),
                                ]),
                              ))
                        ])));
          },
        ));
  }
}
