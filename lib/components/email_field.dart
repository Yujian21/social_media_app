import 'package:flutter/material.dart';
import '../theme/style.dart';

// The widget for the email field
class EmailField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const EmailField({
    Key? key,
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
