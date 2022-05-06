import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/components/email_field.dart';
import 'package:social_media_app/components/glass_morphism.dart';
import 'package:social_media_app/components/password_field.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/services/authentication.dart';
import 'package:social_media_app/services/login_info.dart';
import 'package:social_media_app/theme/style.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Resgister Firebase Authentication service
    AuthenticationService _authenticationService = AuthenticationService();

    // Email and password variables declaration
    String email = '';
    String password = '';

    // ----------------------------------------------------------------------------------------------------------------------------------------------------
    //
    // The following functions are used to generate the widget components for the sign in page
    //
    // ----------------------------------------------------------------------------------------------------------------------------------------------------

    // Alert dialog
    Future<dynamic> _generateAlertDialog(BuildContext context) {
      return showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text(
                  'Incorrect password',
                  style: TextStyle(color: Colors.black38),
                ),
                content: const Text(
                    'The password does not match with that of the given email.'),
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
        'Sign in',
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
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                colorCustomDarkBlueGrandeur,
                colorCustomDarkBlueGrandeurAlt
              ])),
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

                    // Sign in button
                    ElevatedButton(
                        onPressed: () {
                          context.read<LoginInfo>().firebaseSignIn(
                              context,
                              email,
                              password,
                              () => _generateAlertDialog(context));

                          // _authenticationService.firebaseSignIn(context, email,
                          //     password, () => _generateAlertDialog(context));
                        },
                        child: const Text('Sign in')),
                    _generateSizedBox(),

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
