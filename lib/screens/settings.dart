import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/services/authentication_info.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthenticationInfo>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Column(
          children: [
            Center(
              child: Text(
                user.id.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: QrImage(
                data: user.userId,
                size: 200,
              ),
            ),
          ],
        ));
  }
}
