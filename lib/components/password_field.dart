import 'package:flutter/material.dart';

import '../theme/style.dart';

// ignore: must_be_immutable
class PasswordField extends StatefulWidget {
  ValueChanged<String> onChanged;

  PasswordField({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: TextFormField(
          onChanged: widget.onChanged,
          obscureText: !passwordVisible,
          decoration: InputDecoration(
            hintText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(
                passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white54,
              ),
              onPressed: () {
                setState(() => passwordVisible = !passwordVisible);
              },
            ),
          )),
      data: Theme.of(context).copyWith(
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: appThemePrimary,
            ),
      ),
    );
  }
}
