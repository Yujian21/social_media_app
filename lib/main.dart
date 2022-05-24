import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/screens/edit_profile.dart';
import 'package:social_media_app/screens/home.dart';
import 'package:social_media_app/screens/profile.dart';
import 'package:social_media_app/screens/search.dart';
import 'package:social_media_app/screens/search_profile.dart';
import 'package:social_media_app/screens/settings.dart';
import 'package:social_media_app/screens/sign_in.dart';
import 'package:social_media_app/screens/sign_up.dart';
import 'package:social_media_app/screens/two_factor_authentication.dart';
import 'package:social_media_app/screens/unknown.dart';
import 'package:social_media_app/services/authentication_info.dart';
import 'package:social_media_app/services/user_info.dart';
import 'theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

final authenticationInfo = AuthenticationInfo();
final userInfo = UserInfo();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The default Firebase app, functioning as the social media app's backend
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCdTdOWtzqPCqi-1kukoCRqiIWzub35UH0",
          authDomain: "final-year-project-web.firebaseapp.com",
          projectId: "final-year-project-web",
          storageBucket: "final-year-project-web.appspot.com",
          messagingSenderId: "524211821767",
          appId: "1:524211821767:web:758076922520b0e5d4b2e2",
          measurementId: "G-5ZF6WT8R2J"));

  // Additional Firebase app, dedicated to Biothenticator
  await Firebase.initializeApp(
      name: 'biothenticator',
      options: const FirebaseOptions(
          apiKey: "AIzaSyBuzf_3ma6U5KmT1_kcnCi1H5gFVoIaVBQ",
          appId: "1:1042114986164:web:469beb30795f86b4a917e1",
          messagingSenderId: "1042114986164",
          projectId: "biometrics-40713"));

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider<AuthenticationInfo>.value(
          value: authenticationInfo),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late final GoRouter goRouter = GoRouter(
        refreshListenable: authenticationInfo,
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
          GoRoute(
            path: '/settings',
            builder: (BuildContext context, GoRouterState state) =>
                const SettingsPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (BuildContext context, GoRouterState state) =>
                const ProfilePage(),
          ),
          GoRoute(
            path: '/edit-profile',
            builder: (BuildContext context, GoRouterState state) =>
                const EditProfilePage(),
          ),
          GoRoute(
              path: '/search',
              builder: (BuildContext context, GoRouterState state) =>
                  const SearchPage(),
              routes: [
                GoRoute(
                  name: 'search-profile',
                  path: ':name',
                  builder: (BuildContext context, GoRouterState state) {
                    final name = state.params['name'];
                    return SearchProfilePage(name: name);
                  },
                )
              ]),
        ],
        redirect: (state) {
          // The declaration of authentication state variables,
          // obtained via the Provider architecture, which may then be used for
          // redirecting users
          final signedIn = authenticationInfo.signedIn;
          final doubleAuthenticated = authenticationInfo.doubleAuthenticatedAlt;
          final doubleAuthenticationActivated =
              authenticationInfo.doubleAuthenticationActivatedAlt;

          // Debugging statement
          debugPrint('Boolean for logged in status in redirect: ' +
              signedIn.toString());

          // The declaration of paths in which the user is or may be
          // headed towards
          final signingIn = state.subloc == '/sign-in';
          final signingUp = state.subloc == '/sign-up';
          final verifying2FA = state.subloc == '/2fa';

          // If the current user is signed out, and is headed towards neither
          // the sign in page nor the sign up page, have them redirected
          // to the former page
          if (!signedIn) {
            return signingIn
                ? null
                : signingUp
                    ? null
                    : '/sign-in';
          }

          /* From this point forward, it is established that the current user is
           already signed in */

          // If the current user has 2FA enabled and is still on the sign in
          // page, have them redirected to the 2FA page
          if (doubleAuthenticationActivated) {
            debugPrint('Double authentication activated');
            if (!doubleAuthenticated) {
              return signingIn
                  ? '/2fa'
                  : verifying2FA
                      ? null
                      : '/2fa';
            }

            if (verifying2FA && doubleAuthenticated) {
              debugPrint('Is signed in and is double authenticated');
              return '/';
            }
          }

          // If the current user is still on the sign in page or the sign up
          // page , have them redirected to the home page
          if (signingIn || signingUp) {
            return '/';
          }

          /* If the current user satisfies all of the aforementioned conditions:
                (i)   Signed in
                (ii)  Has 2FA enabled, but is already authenticated OR
                      does not have 2FA enabled at all
            Then, he/she may head over to any page as they wish, except for the 
            sign in page, the sign up page, or the 2FA page
          */
          return null;
        },
        // If the route provided is not found, have the curretn user redirected
        // to the unknown page (404)
        errorBuilder: (context, state) => const UnknownPage());
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.custom,
      routerDelegate: goRouter.routerDelegate,
      routeInformationParser: goRouter.routeInformationParser,
    );
  }
}
