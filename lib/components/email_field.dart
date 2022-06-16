import 'package:flutter/material.dart';
import '../theme/style.dart';

// ignore: must_be_immutable
class EmailField extends StatefulWidget {
  // TextEditingController controller;
  ValueChanged<String> onChanged;

  EmailField({
    Key? key,
    // required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  _EmailFieldState createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      child: TextFormField(
          onChanged: widget.onChanged,
          // controller: widget.controller,
          decoration: const InputDecoration(
            hintText: 'E-mail',
          )),
      data: Theme.of(context).copyWith(
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: appThemePrimary,
            ),
      ),
    );
  }
}
