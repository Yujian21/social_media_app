import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../components/side_menu.dart';
import '../services/authentication_info.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  AuthenticationInfo authInfo = AuthenticationInfo();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<bool?>.value(
        value: authInfo.checkSetupExists(),
        initialData: false,
        catchError: (_, __) => null,
        child: Builder(
          builder: (BuildContext context) {
            BuildContext rootContext = context;
            final setupExists = Provider.of<bool?>(rootContext);
            return Scaffold(
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            setupExists!
                                ? ElevatedButton(
                                    onPressed: () async {
                                      await Provider.of<AuthenticationInfo>(
                                              context,
                                              listen: false)
                                          .cancelSetup();
                                    },
                                    child: const Text('Cancel Setup'))
                                : ElevatedButton(
                                    onPressed: () async {
                                      await Provider.of<AuthenticationInfo>(
                                              context,
                                              listen: false)
                                          .addSetup();
                                    },
                                    child: const Text('Setup Biothenticator')),
                            const SizedBox(
                              height: 10,
                            ),
                            Visibility(
                              visible: setupExists,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16)),
                                child: QrImage(
                                  data: FirebaseAuth.instance.currentUser!.uid,
                                  size: 200,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ));
          },
        ));
  }
}
