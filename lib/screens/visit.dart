// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:social_media_app/models/user.dart';
// import 'package:social_media_app/theme/style.dart';
// import '../services/user_info.dart' as user_info;
// import '../components/side_menu.dart';

// class VisitPage extends StatefulWidget {
//   final UserModel user;
//   const VisitPage({Key? key, required this.user}) : super(key: key);

//   @override
//   State<VisitPage> createState() => _VisitPageState();
// }

// class _VisitPageState extends State<VisitPage> {
//   user_info.UserInfo userInfo = user_info.UserInfo();
//   PlatformFile? uploadFile;

//   @override
//   void initState() {
//     if (widget.user != null) {
//       debugPrint(widget.user.id);
//     }
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ----------------------------------------------------------------------------------------------------------------------------------------------------
//     //
//     // The following functions are used to generate the widget components for the edit profile page
//     //
//     // ----------------------------------------------------------------------------------------------------------------------------------------------------

//     // Sized boxes (White spaces)
//     Widget _generateSizedBox() {
//       return const SizedBox(
//         height: 15,
//       );
//     }

//     // ----------------------------------------------------------------------------------------------------------------------------------------------------
//     //
//     // End of widget generation functions
//     //
//     // ----------------------------------------------------------------------------------------------------------------------------------------------------

//     return MultiProvider(
//         providers: [
//           StreamProvider<UserModel?>(
//               create: (_) => userInfo.getUserInfo(widget.user.id),
//               initialData: null),
//           StreamProvider<bool?>.value(
//               value: userInfo.isFollowing(
//                   FirebaseAuth.instance.currentUser!.uid, widget.user.name),
//               initialData: false)
//         ],
//         child: Builder(
//           builder: (BuildContext context) {
//             BuildContext rootContext = context;
//             final userProfile = Provider.of<UserModel?>(rootContext);
//             final isFollowing = Provider.of<bool?>(rootContext);
//             debugPrint('am following: ' + isFollowing.toString());

//             return userProfile == null
//                 ? Scaffold(
//                     body: Center(
//                         child: CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                                 appThemeTertiary))))
//                 : Scaffold(
//                     drawer: const SideMenu(),
//                     body: SafeArea(
//                         child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                           const Expanded(
//                             flex: 1,
//                             child: SideMenu(),
//                           ),
//                           Expanded(
//                               flex: 5,
//                               child: Padding(
//                                 padding: const EdgeInsets.only(top: 16),
//                                 child: Column(children: [
//                                   Stack(children: <Widget>[
//                                     CircleAvatar(
//                                       radius: 125,
//                                       backgroundImage: NetworkImage(
//                                           Provider.of<UserModel?>(rootContext)!
//                                               .profileImageUrl
//                                               .toString()),
//                                     ),
//                                   ]),
//                                   _generateSizedBox(),
//                                   Text(Provider.of<UserModel?>(rootContext)!
//                                       .name
//                                       .toString()),
//                                   _generateSizedBox(),
//                                   if (isFollowing != null &&
//                                       isFollowing == true)
//                                     ElevatedButton(
//                                         onPressed: () {
//                                           userInfo.unfollowUser(widget.user.id);
//                                           debugPrint(isFollowing.toString());
//                                         },
//                                         child: const Text('Unfollow'))
//                                   else if (isFollowing != null &&
//                                       isFollowing == false)
//                                     ElevatedButton(
//                                         onPressed: () {
//                                           userInfo.followUser(widget.user.id);
//                                           debugPrint(isFollowing.toString());
//                                         },
//                                         child: const Text('Follow'))
//                                 ]),
//                               ))
//                         ])));
//           },
//         ));
//   }
// }
