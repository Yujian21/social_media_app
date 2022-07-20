import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../components/email_field.dart';
import '../components/glass_morphism.dart';
import '../components/password_field.dart';
import '../services/authentication_info.dart';
import '../theme/style.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Declaration of email and password variables
    String email = '';
    String password = '';

    // Empty fields validation
    bool validateFields(String email, String password) {
      if (email == "") {
        return false;
      }

      if (password == "") {
        return false;
      }
      return true;
    }

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

    return Scaffold(
      body: Row(
        children: [
          // The decorative section (Inclusive of the logo and the background
          // effect)
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
          // The sign in section (Inclusive of the title, email, and
          // password fields)
          Expanded(
            child: Center(
              child: SizedBox(
                width: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Sign in',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    EmailField(onChanged: (value) {
                      email = value;
                    }),
                    const SizedBox(
                      height: 15,
                    ),
                    PasswordField(
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),

                    // Sign in button
                    ElevatedButton(
                        onPressed: () {
                          validateFields(email, password)
                              ? context
                                  .read<AuthenticationInfo>()
                                  .firebaseSignIn(
                                    context,
                                    email,
                                    password,
                                    () => _generateAlertDialog(
                                        context,
                                        'Incorrect email and/or password',
                                        'Please double-check the email and password, to ensure that they are correct.'),
                                    () => _generateAlertDialog(
                                        context,
                                        'Invalid email',
                                        'Please double-check the email, to ensure that it is in the correct format.'),
                                  )
                              : _generateAlertDialog(context, 'Empty fields',
                                  'Please ensure that the email and password fields are not empty.');
                        },
                        child: const Text('Sign in')),
                    const SizedBox(
                      height: 15,
                    ),

                    // Sign up button
                    TextButton(
                        onPressed: () {
                          context.go('/sign-up');
                        },
                        child: const Text('New here? Create an account.'))
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
