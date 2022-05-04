import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/services/login_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LoginInfo>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              user.id.toString(),
              style: const TextStyle(color: Colors.black),
            ),
            QrImage(
              data: user.userId,
              size: 200,
            ),
            ElevatedButton(
                onPressed: () {
                  context.read<LoginInfo>().firebaseSignOut();
                },
                child: const Text('Sign out'))
          ],
        ),
      ),
    );
  }
}
