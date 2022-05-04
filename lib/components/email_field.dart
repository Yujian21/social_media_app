import 'package:flutter/material.dart';

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
    return TextField(
        onChanged: widget.onChanged,
        // controller: widget.controller,
        decoration: InputDecoration(
            fillColor: Colors.blueGrey.shade50,
            filled: true,
            hintText: 'E-mail',
            prefixIcon: const Icon(Icons.mail_outline),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blueGrey.shade50)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blueGrey.shade50))));
  }
}
