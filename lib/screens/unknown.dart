import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/services/authentication_info.dart';
import 'package:social_media_app/theme/theme.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthenticationInfo>(context);
    return Scaffold(
        body: Center(
      child: Text(
        '404',
        style: AppTheme.custom.textTheme.headline1,
      ),
    ));
  }
}
