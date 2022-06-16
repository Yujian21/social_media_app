import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/theme/style.dart';
import '../services/user_info.dart' as user_info;
import '../components/side_menu.dart';

class SearchProfilePage extends StatefulWidget {
  final String? name;
  const SearchProfilePage({Key? key, required this.name}) : super(key: key);

  @override
  State<SearchProfilePage> createState() => _SearchProfilePageState();
}

class _SearchProfilePageState extends State<SearchProfilePage> {
  user_info.UserInfo userInfo = user_info.UserInfo();
  String? searchedUID;
  String? searchedName;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      searchedUID = await userInfo.getUid(widget.name.toString());

      setState(() {
        searchedUID;
        searchedName = widget.name.toString();
      });
    });
    super.initState();
  }

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

    debugPrint(widget.name.toString() + ' in build method');
    if (widget.name != searchedName) {
      debugPrint('widget.name is not equal to searchedName');
    } else {
      debugPrint('widget.name is equal to searchedName');
    }
    return searchedUID == null
        ? Scaffold(
            body: Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(appThemeTertiary))))
        : MultiProvider(
            providers: [
                StreamProvider<UserModel?>.value(
                    value: userInfo.getSearchedUserInfo(widget.name),
                    initialData: null),
                StreamProvider<bool?>.value(
                  value: userInfo.isFollowing(
                      FirebaseAuth.instance.currentUser!.uid, widget.name),
                  initialData: false,
                  catchError: (_, __) => null,
                )
              ],
            child: Builder(
              builder: (BuildContext context) {
                BuildContext rootContext = context;
                final userProfile = Provider.of<UserModel?>(rootContext);
                final isFollowing = Provider.of<bool?>(rootContext);
                debugPrint('am following: ' + isFollowing.toString());
                debugPrint(searchedUID.toString() + ' in builder');

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
                                        Provider.of<UserModel?>(rootContext)!
                                                    .profileImageUrl
                                                    .toString() ==
                                                ''
                                            ? Container(
                                                clipBehavior: Clip.antiAlias,
                                                width: 250,
                                                height: 250,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: appThemeTertiary),
                                                child: const Icon(
                                                  Icons.person_rounded,
                                                  color: Colors.white,
                                                ))
                                            : CircleAvatar(
                                                radius: 125,
                                                backgroundImage: NetworkImage(
                                                    Provider.of<UserModel?>(
                                                            rootContext)!
                                                        .profileImageUrl
                                                        .toString()),
                                              ),
                                      ]),
                                      _generateSizedBox(),
                                      Text(Provider.of<UserModel?>(rootContext)!
                                          .name
                                          .toString()),
                                      _generateSizedBox(),
                                      if (isFollowing != null &&
                                          isFollowing == true)
                                        ElevatedButton(
                                            onPressed: () {
                                              userInfo.unfollowSearchedUser(
                                                  widget.name);
                                              debugPrint(
                                                  isFollowing.toString());
                                            },
                                            child: const Text('Unfollow'))
                                      else if (isFollowing != null &&
                                          isFollowing == false)
                                        ElevatedButton(
                                            onPressed: () {
                                              userInfo.followSearchedUser(
                                                  widget.name);
                                              debugPrint(
                                                  isFollowing.toString());
                                            },
                                            child: const Text('Follow'))
                                    ]),
                                  ))
                            ])));
              },
            ));
  }
}
