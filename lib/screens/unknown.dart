import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/services/login_info.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LoginInfo>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('404'),
        ),
        body: Center(
          child: Text(
            user != null ? user.id.toString() : 'null',
            style: TextStyle(color: Colors.black),
          ),
        ));
  }
}
