import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/email_field.dart';
import '../components/glass_morphism.dart';
import '../components/password_field.dart';
import '../services/authentication_info.dart';
import '../theme/style.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Email and password variables declaration
    String email = '';
    String password = '';

    // ----------------------------------------------------------------------------------------------------------------------------------------------------
    //
    // The following functions are used to generate the widget components for the sign in page
    //
    // ----------------------------------------------------------------------------------------------------------------------------------------------------

    // Alert dialog
    Future<dynamic> _generateAlertDialog(
        BuildContext context, String title, String content) {
      return showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                backgroundColor: appThemeSecondary,
                title: Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                ),
                content: Text(content),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ));
    }

    // Email text field
    Widget _generateEmailField() {
      return EmailField(onChanged: (value) {
        email = value;
      });
    }

    // Password text field
    Widget _generatePasswordField() {
      return PasswordField(
        onChanged: (value) {
          password = value;
        },
      );
    }

    // Sized boxes (White spaces)
    Widget _generateSizedBox() {
      return const SizedBox(
        height: 15,
      );
    }

    // Page title
    Widget _generateTitle() {
      return Text(
        'Sign up',
        style: Theme.of(context).textTheme.headline1,
      );
    }

    // ----------------------------------------------------------------------------------------------------------------------------------------------------
    //
    // End of widget generation functions
    //
    // ----------------------------------------------------------------------------------------------------------------------------------------------------

    return Scaffold(
      body: Row(
        children: [
          Expanded(
              child: Stack(alignment: Alignment.center, children: [
            Container(
              decoration: BoxDecoration(color: appThemePrimary),
            ),
            Icon(
              Icons.blur_on_sharp,
              size: 650,
              color: Colors.white.withOpacity(0.1),
            ),
            const GlassMorphism(
              blur: 5.0,
              opacity: 0.3,
              child: Icon(
                Icons.fingerprint_outlined,
                size: 75,
                color: Colors.white,
              ),
            ),
          ])),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _generateTitle(),
                    _generateSizedBox(),
                    _generateEmailField(),
                    _generateSizedBox(),
                    _generatePasswordField(),
                    _generateSizedBox(),
                    // Sign up button
                    ElevatedButton(
                        onPressed: () async {
                          context.read<AuthenticationInfo>().firebaseSignUp(
                              email,
                              password,
                              () => _generateAlertDialog(
                                  context,
                                  'Invalid email',
                                  'The email that has been provided is invalid.'),
                              () => _generateAlertDialog(
                                  context,
                                  'Weak password',
                                  'The password provided is too weak.'),
                              () => _generateAlertDialog(
                                  context,
                                  'Account already exists',
                                  'This email is already in use by another account.'));
                        },
                        child: const Text('Sign up')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
