import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../theme/style.dart';
import '../services/user_info.dart' as user_info;
import '../components/side_menu.dart';

class SearchProfilePage extends StatefulWidget {
  final String? name;
  const SearchProfilePage({Key? key, required this.name}) : super(key: key);

  @override
  State<SearchProfilePage> createState() => _SearchProfilePageState();
}

class _SearchProfilePageState extends State<SearchProfilePage> {
  // Instantiate the User Info class, to use the get UID method
  user_info.UserInfo userInfo = user_info.UserInfo();

  // Initialize the variables for the UID and name of the searched user
  String? searchedUID;
  String? searchedName;

  // Whem this page loads, get the UID of the searched user via his/her
  // name/username. Once the UID is obtained, update the state 
  // (As well as the state variables) of the page
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
    // If the UID has not yet been fully initialized, show a circular progress
    // indicator
    return searchedUID == null
        ? Scaffold(
            body: Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(appThemeTertiary))))
        :
        // This page depends on two streams, which will get the
        // searched user's info, as well as the current user's
        // following status. These values will be
        // obtainable via the Provider architecture
        MultiProvider(
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
                // Using the information obtained from the Provider architecture,
                // get the searched user's profile information and the current
                // user's following status
                final userProfile = Provider.of<UserModel?>(rootContext);
                final isFollowing = Provider.of<bool?>(rootContext);

                // If the searched user's profile is not fully loaded, show a 
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
                              const Expanded(
                                flex: 1,
                                child: SideMenu(),
                              ),
                              // The searched user's profile image
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
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      // The searched user's name/username
                                      Text(Provider.of<UserModel?>(rootContext)!
                                          .name
                                          .toString()),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      // Follow/Unfollow button
                                      // (Depends on the current user's
                                      // following status)
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
