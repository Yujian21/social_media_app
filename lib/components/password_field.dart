import 'package:flutter/material.dart';

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
    return TextField(
        onChanged: widget.onChanged,
        obscureText: !passwordVisible,
        decoration: InputDecoration(
            fillColor: Colors.blueGrey.shade50,
            filled: true,
            hintText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() => passwordVisible = !passwordVisible);
              },
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blueGrey.shade50)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blueGrey.shade50))));
  }
}
