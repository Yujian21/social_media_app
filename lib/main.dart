import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/screens/home.dart';
import 'package:social_media_app/screens/sign_in.dart';
import 'package:social_media_app/screens/sign_up.dart';
import 'package:social_media_app/screens/two_factor_authentication.dart';
import 'package:social_media_app/screens/unknown.dart';
import 'package:social_media_app/services/login_info.dart';
import 'theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

final loginInfo = LoginInfo();

void main() async {
  const String apiKey = "AIzaSyBuzf_3ma6U5KmT1_kcnCi1H5gFVoIaVBQ";
  const String appId = "1:1042114986164:web:469beb30795f86b4a917e1";
  const String messagingSenderId = "1042114986164";
  const String projectId = "biometrics-40713";

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId));
  runApp(ChangeNotifierProvider<LoginInfo>.value(
      value: loginInfo, child: const MyApp()));

  // runApp(StreamProvider<UserModel?>.value(
  //     initialData: null,
  //     value: AuthenticationService().currentUser,
  //     child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // GoRouterGenerator goRouterGenerator = GoRouterGenerator();
    late final GoRouter goRouter = GoRouter(
        // refreshListenable:
        //     GoRouterRefreshStream(AuthenticationService().currentUser),
        refreshListenable: loginInfo,
        debugLogDiagnostics: true,
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) =>
                const HomePage(),
          ),
          GoRoute(
            path: '/sign-in',
            builder: (BuildContext context, GoRouterState state) =>
                const SignInPage(),
          ),
          GoRoute(
            path: '/sign-up',
            builder: (BuildContext context, GoRouterState state) =>
                const SignUpPage(),
          ),
          GoRoute(
            path: '/unknown',
            builder: (BuildContext context, GoRouterState state) =>
                const UnknownPage(),
          ),
          GoRoute(
            path: '/2fa',
            builder: (BuildContext context, GoRouterState state) =>
                const TwoFactorAuthenticationPage(),
          ),
        ],
        redirect: (state) {
          // The declaration of state variables, obtained via the Provider architecture,
          // which may then be used for redirecting users
          final signedIn = loginInfo.loggedIn;
          final doubleAuthenticated = loginInfo.doubleAuthenticatedAlt;
          final doubleAuthenticationActivated =
              loginInfo.doubleAuthenticationActivatedAlt;

          // Debugging statement
          debugPrint('Boolean for logged in status in redirect: ' +
              signedIn.toString());

          // The declaration of paths in which the user is or may be
          // headed towards
          final signingIn = state.subloc == '/sign-in';
          final signingUp = state.subloc == '/sign-up';
          final verifying2FA = state.subloc == '/2fa';

          // If the user is signed out, and is headed towards neither the
          // sign in page nor the sign up page, they would then be redirected
          // to the sign in former
          if (!signedIn) {
            return signingIn
                ? null
                : signingUp
                    ? null
                    : '/sign-in';
          }

          /* From this point forward, it is established that the user is
           already signed in */

          // If the user has 2FA activated and is still on the sign in page,
          // have them redirected to the 2FA page
          if (doubleAuthenticationActivated) {
            debugPrint('Double authentication activated');
            if (!doubleAuthenticated) {
              return signingIn
                  ? '/2fa'
                  : verifying2FA
                      ? null
                      : '/2fa';
            }
            // if (signingIn && !doubleAuthenticated) {
            //   debugPrint('Still in sign in and is not double authenticated');
            //   return '/2fa';
            // }

            // if (verifying2FA && !doubleAuthenticated) {
            //   debugPrint('In 2FA page and is not double authenticated');
            // }

            if (verifying2FA && doubleAuthenticated) {
              debugPrint('Is signed in and is double authenticated');
              return '/';
            }
          }

          debugPrint('Double authentication not activated');
          if (signingIn) return '/';

          // If the user is signed in but still on the sign in page,
          // send them to the home page

          // if (signingIn && !doubleAuthenticated) {
          //   return '/2fa';
          // }
          // if (signingIn && doubleAuthenticated) return '/';

          // if (verifying2FA && doubleAuthenticated) {
          //   debugPrint(doubleAuthenticated.toString() +
          //       'is logged in and is double authenticated');
          //   return '/';
          // }

          // No need to redirect at all
          return null;
        },

        //
        //
        // Method 1
        //
        //

        //   // debugPrint('Redirect');
        //   // if (user == null) {
        //   //   debugPrint('User is signed out (redirect)');
        //   //   if (signingIn) {
        //   //     debugPrint('User is signing in');
        //   //     return null;
        //   //   } else if (signingUp) {
        //   //     debugPrint('User is signing in');
        //   //     return null;
        //   //   } else {
        //   //     return '/sign-in';
        //   //   }
        //   // } else {
        //   //   if (signingIn) {
        //   //     debugPrint(
        //   //         'User is signed in but is attempting to sign in again');
        //   //     return '/';
        //   //   }
        //   //   debugPrint('User is signed in (redirect)');
        //   //   debugPrint(Provider.of<UserModel?>(context)!.id);
        //   // }
        //   // return null;

        errorBuilder: (context, state) => const UnknownPage());
    return MaterialApp.router(
      theme: AppTheme.custom,
      routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
    );
  }
}
