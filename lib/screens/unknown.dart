import 'package:flutter/material.dart';
import '../theme/theme.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Text(
        '404',
        style: AppTheme.custom.textTheme.headline1,
      ),
    ));
  }
}
