import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/services/authentication_info.dart';

class TwoFactorAuthenticationPage extends StatefulWidget {
  const TwoFactorAuthenticationPage({Key? key}) : super(key: key);

  @override
  State<TwoFactorAuthenticationPage> createState() =>
      _TwoFactorAuthenticationPageState();
}

class _TwoFactorAuthenticationPageState
    extends State<TwoFactorAuthenticationPage> {
  String? authDocID;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      authDocID = await Provider.of<AuthenticationInfo>(context, listen: false)
          .addAttempt();
      setState(() {
        authDocID;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthenticationInfo>(context, listen: false);

    // Firebase app dedicated to Biothenticator
    FirebaseApp biothenticator = Firebase.app('biothenticator');
    FirebaseFirestore biothenticatorFirestore =
        FirebaseFirestore.instanceFor(app: biothenticator);

    if (authDocID == null) {
      return Scaffold(
        body: Center(
            child: Column(
          children: const [
            CircularProgressIndicator(),
          ],
        )),
      );
    } else {
      return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: biothenticatorFirestore
              .collection('2fa-status')
              .doc(user.userId)
              .collection('attempts')
              .where(FieldPath.documentId, isEqualTo: authDocID.toString())
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  children: const [
                    CircularProgressIndicator(),
                    Text("Loading"),
                  ],
                ),
              );
            }
            if (snapshot.hasData) {
              var documents = snapshot.data!.docs;

              if (documents.isNotEmpty) {
                debugPrint(documents.toString());
                debugPrint(documents[0]['isAuthenticated'].toString());

                if (documents[0]['isAuthenticated'] == true) {
                  debugPrint('Is double authenticated');
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    // Update local double authentication state
                    context
                        .read<AuthenticationInfo>()
                        .isDoubleAuthenticated(context);

                    // Update and log the attempt on Biothenticator's Firestore
                    context
                        .read<AuthenticationInfo>()
                        .logAttempt(user.userId, snapshot);
                  });
                } else {
                  debugPrint('Is not double authenticated');
                }
                return Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Please authenticate via Biothenticator',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    const Icon(
                      Icons.screen_lock_portrait_rounded,
                      color: Colors.white,
                    )
                  ],
                ));
              } else {
                Provider.of<AuthenticationInfo>(context, listen: false)
                    .firebaseSignOut();
              }
            }
            return const Text('Something went wrong...  ;(');
          },
        ),
      );
    }
  }
}

                    // // Add the attempt to the logs
                    // biothenticatorFirestore
                    //     .collection('2fa-status')
                    //     .doc(user.userId)
                    //     .collection('logs')
                    //     .doc(snapshot.data!.docs[0].id)
                    //     .set({
                    //   'isAuthenticated': true,
                    //   'timestamp': FieldValue.serverTimestamp()
                    // });

                    // // Remove the attempt from the list of those that
                    // // are actively seeking for authentication
                    // Future.delayed(const Duration(milliseconds: 1000), () {
                    //   biothenticatorFirestore
                    //       .collection('2fa-status')
                    //       .doc(user.userId)
                    //       .collection('attempts')
                    //       .doc(snapshot.data!.docs[0].id)
                    //       .delete();
                    // });
