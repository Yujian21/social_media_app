import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/theme/style.dart';
import '../services/user_info.dart' as user_Info;
import '../components/side_menu.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  user_Info.UserInfo userInfo = user_Info.UserInfo();
  PlatformFile? uploadFile;
  @override
  Widget build(BuildContext context) {
    // ----------------------------------------------------------------------------------------------------------------------------------------------------
    //
    // The following functions are used to generate the widget components for the edit profile page
    //
    // ----------------------------------------------------------------------------------------------------------------------------------------------------

    // Sized boxes (White spaces)
    Widget _generateSizedBox() {
      return const SizedBox(
        height: 15,
      );
    }

    // ----------------------------------------------------------------------------------------------------------------------------------------------------
    //
    // End of widget generation functions
    //
    // ----------------------------------------------------------------------------------------------------------------------------------------------------

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
            final userProfile = Provider.of<UserModel?>(rootContext);

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
                          const Expanded(
                            flex: 1,
                            child: SideMenu(),
                          ),
                          Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Column(children: [
                                  Stack(children: <Widget>[
                                    CircleAvatar(
                                      radius: 125,
                                      backgroundImage: NetworkImage(
                                          Provider.of<UserModel?>(rootContext)!
                                              .profileImageUrl
                                              .toString()),
                                    ),
                                  ]),
                                  _generateSizedBox(),
                                  Text(Provider.of<UserModel?>(rootContext)!
                                      .name
                                      .toString()),
                                  _generateSizedBox(),
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
