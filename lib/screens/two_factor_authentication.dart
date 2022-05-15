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
  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthenticationInfo>(context, listen: false);

    // Firebase app dedicated to Biothenticator
    FirebaseApp biothenticator = Firebase.app('biothenticator');
    FirebaseFirestore biothenticatorFirestore =
        FirebaseFirestore.instanceFor(app: biothenticator);

    return Scaffold(
      appBar: AppBar(
        title: const Text('2FA'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: biothenticatorFirestore
            .collection('2fa-status')
            .where('userId', isEqualTo: user.userId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          if (snapshot.hasData) {
            var allDocuments = snapshot.data!.docs;
            for (var document in allDocuments) {
              dynamic documentDetails = document.data() as Map;
              if (documentDetails['isAuthenticated'] == true) {
                debugPrint('Is double authenticated');
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  // Update local double authentication state
                  context
                      .read<AuthenticationInfo>()
                      .isDoubleAuthenticated(context);

                  // Reset serverside double authentication status
                  // (Prone to change)
                  biothenticatorFirestore
                      .collection('2fa-status')
                      .doc(document.id)
                      .update({"isAuthenticated": false});
                });
              } else {
                debugPrint('Is not double authenticated');
              }
            }
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              // Document data
              Map<String, dynamic> documentData =
                  document.data()! as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.fingerprint_outlined),
                title: Text(
                  documentData['userId'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24),
                ),
                subtitle: const Text('Please authenticate via Biothenticator.'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
