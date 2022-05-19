import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  String? docId;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      docId = await Provider.of<AuthenticationInfo>(context, listen: false)
          .logAttempt();
      setState(() {
        docId;
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

    if (docId == null) {
      return const Scaffold(
        body: CircularProgressIndicator(),
      );
    } else {
      debugPrint(docId);
      debugPrint(user.userId);
      return Scaffold(
        appBar: AppBar(
          title: const Text('2FA'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: biothenticatorFirestore
              .collection('2fa-status')
              .doc(user.userId)
              .collection('attempts')
              .where(FieldPath.documentId, isEqualTo: docId.toString())
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }
            if (snapshot.hasData) {
              var documents = snapshot.data!.docs;

              if (documents != []) {
                debugPrint(documents.toString());
                debugPrint(documents[0]['isAuthenticated'].toString());

                if (documents[0]['isAuthenticated'] == true) {
                  debugPrint('Is double authenticated');
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    // Update local double authentication state
                    context
                        .read<AuthenticationInfo>()
                        .isDoubleAuthenticated(context);

                    // Add the sign in attempt to the logs
                    biothenticatorFirestore
                        .collection('2fa-status')
                        .doc(user.userId)
                        .collection('logs')
                        .doc(snapshot.data!.docs[0].id)
                        .set({
                      'isAuthenticated': true,
                      'timestamp': FieldValue.serverTimestamp()
                    });

                    // Remove the sign in attempt from the list of attempts that
                    // are actively seeking for authentication
                    Future.delayed(const Duration(seconds: 2), () {
                      biothenticatorFirestore
                          .collection('2fa-status')
                          .doc(user.userId)
                          .collection('attempts')
                          .doc(snapshot.data!.docs[0].id)
                          .delete();
                    });
                  });
                } else {
                  debugPrint('Is not double authenticated');
                }
                return const Text('Please authenticate via Biothenticator');
              }
            }
            return const Text('Something went wrong...  ;(');
          },
        ),
      );
    }
  }
}
