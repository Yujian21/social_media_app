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
  // Initialize the variable for the 2FA attempt document ID
  String? authDocID;

  // Initialize controllers for PIN fields
  final TextEditingController _fieldOne = TextEditingController();
  final TextEditingController _fieldTwo = TextEditingController();
  final TextEditingController _fieldThree = TextEditingController();
  final TextEditingController _fieldFour = TextEditingController();
  final TextEditingController _fieldFive = TextEditingController();
  final TextEditingController _fieldSix = TextEditingController();

  // When this page loads, initiate a 2FA attempt under the current user 
  // (Creating a Firebase document)
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
    // Declare the Firestore dedicated to Biothenticator
    FirebaseApp biothenticator = Firebase.app('biothenticator');
    FirebaseFirestore biothenticatorFirestore =
        FirebaseFirestore.instanceFor(app: biothenticator);

    // If the 2FA attempt (Firebase document) has not yet fully initialized,
    // show a circular progress indicator
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
    // If the 2FA attempt (Firebase document) has fully initialized,
    // show the 2FA page. This page depends on a stream which listens to the 
    // 2FA attempt (Firebase document) which was created when this page first 
    // loaded
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
                // If the authentication attribute on the 2FA attempt
                // (Firebase document) has been set to true
                if (documents[0]['isAuthenticated'] == true) {
                  debugPrint('Is double authenticated');
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    // Update the local double authentication state
                    // (Which would subsequently redirect the user to the 
                    // home page)
                    context
                        .read<AuthenticationInfo>()
                        .isDoubleAuthenticated(context);

                    // Update and log the attempt on Biothenticator's Firestore
                    context.read<AuthenticationInfo>().logAttempt(
                        FirebaseAuth.instance.currentUser!.uid, snapshot);
                  });
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
                    // The PIN fields, to accept the fallback PIN 
                    // (Fully optional)
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
                    // The PIN submit button (Fully optional)
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
                              // If the fallback PIN is correct
                              if (documentSnapshot['fallbackPin'] == pin) {
                                final docRef = FirebaseFirestore.instance
                                    .collection('2fa-status')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('attempts')
                                    .doc(authDocID);
                                
                                // Set the authentication attribute of the 
                                // 2FA attempt (Firebase document) to true
                                FirebaseFirestore.instance
                                    .runTransaction((transaction) async {
                                  transaction.update(
                                      docRef, {'isAuthenticated': true});
                                }).then(
                                  (_) {},
                                  onError: (e) =>
                                      debugPrint("Error updating document $e"),
                                );

                                // Update the local double authentication state
                                context
                                    .read<AuthenticationInfo>()
                                    .isDoubleAuthenticated(context);

                                // Update and log the attempt on Biothenticator's Firestore
                                context.read<AuthenticationInfo>().logAttempt(
                                    FirebaseAuth.instance.currentUser!.uid,
                                    snapshot);
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
