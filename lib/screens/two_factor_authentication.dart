import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication_info.dart';
import '../theme/style.dart';
import '../components/pin_field.dart';

class TwoFactorAuthenticationPage extends StatefulWidget {
  const TwoFactorAuthenticationPage({Key? key}) : super(key: key);

  @override
  State<TwoFactorAuthenticationPage> createState() =>
      _TwoFactorAuthenticationPageState();
}

class _TwoFactorAuthenticationPageState
    extends State<TwoFactorAuthenticationPage> {
  // Initialize variable to store 2FA attempt document ID
  String? authDocID;

  // Initialize controllers to accept fallback PIN
  final TextEditingController _fieldOne = TextEditingController();
  final TextEditingController _fieldTwo = TextEditingController();
  final TextEditingController _fieldThree = TextEditingController();
  final TextEditingController _fieldFour = TextEditingController();
  final TextEditingController _fieldFive = TextEditingController();
  final TextEditingController _fieldSix = TextEditingController();

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
          children: [
            CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(appThemeTertiary)),
          ],
        )),
      );
    } else {
      return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: biothenticatorFirestore
              .collection('2fa-status')
              .doc(FirebaseAuth.instance.currentUser!.uid)
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
                  children: [
                    CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(appThemeTertiary)),
                    const Text("Loading"),
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
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Please authenticate via Biothenticator',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                        const Icon(
                          Icons.screen_lock_portrait_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        PinInput(_fieldOne, true),
                        PinInput(_fieldTwo, false),
                        PinInput(_fieldThree, false),
                        PinInput(_fieldFour, false),
                        PinInput(_fieldFive, false),
                        PinInput(_fieldSix, false)
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          var pin = _fieldOne.text +
                              _fieldTwo.text +
                              _fieldThree.text +
                              _fieldFour.text +
                              _fieldFive.text +
                              _fieldSix.text;
                          if (pin.length == 6) {
                            await biothenticatorFirestore
                                .collection('2fa-status')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .get()
                                .then((documentSnapshot) {
                              if (documentSnapshot['fallbackPin'] == pin) {
                                final docRef = FirebaseFirestore.instance
                                    .collection('2fa-status')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('attempts')
                                    .doc(authDocID);

                                FirebaseFirestore.instance
                                    .runTransaction((transaction) async {
                                  transaction.update(
                                      docRef, {'isAuthenticated': true});
                                }).then(
                                  (_) {},
                                  onError: (e) =>
                                      debugPrint("Error updating document $e"),
                                );

                                // Update local double authentication state
                                context
                                    .read<AuthenticationInfo>()
                                    .isDoubleAuthenticated(context);

                                // Update and log the attempt on Biothenticator's Firestore
                                context
                                    .read<AuthenticationInfo>()
                                    .logAttempt(user.userId, snapshot);
                              } else {
                                debugPrint('incorrect pin');
                              }
                            });
                          } else {
                            debugPrint('invalid pin');
                          }
                        },
                        child: const Text('Authenticate')),
                  ],
                );
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
