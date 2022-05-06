import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/services/login_info.dart';

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
    // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
    //   final user = Provider.of<LoginInfo>(context, listen: false);
    //   final currentUser2FA = FirebaseFirestore.instance
    //       .collection('2fa-status')
    //       .where('userId', isEqualTo: user.id);
    //   currentUser2FA.snapshots().listen((querySnapshot) {
    //     if (querySnapshot != null) {
    //       debugPrint('Entry found.');
    //       debugPrint(Provider.of<LoginInfo>(context, listen: false)
    //           .doubleAuthenticated
    //           .toString());
    //       querySnapshot.docChanges.forEach((change) {
    //         context.read<LoginInfo>().isDoubleAuthenticated(context);
    //       });

    //       debugPrint(Provider.of<LoginInfo>(context, listen: false)
    //           .doubleAuthenticated
    //           .toString());
    //     }
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LoginInfo>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('2FA'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
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
                  context.read<LoginInfo>().isDoubleAuthenticated(context);
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
                title: Text(
                  documentData['userId'],
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),
                subtitle: Text(documentData['2fa-enabled'].toString(),
                    style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
