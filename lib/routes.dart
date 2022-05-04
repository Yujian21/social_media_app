import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/screens/home.dart';
import 'package:social_media_app/screens/sign_in.dart';
import 'package:social_media_app/screens/sign_up.dart';
import 'package:social_media_app/screens/unknown.dart';

class CustomRouter {
  // final LoginState loginState;
  late final GoRouter goRouter = GoRouter(
      urlPathStrategy: UrlPathStrategy.path,
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
      ],
      redirect: (state) {
        const signedIn = false;
        final signingIn = state.subloc == '/sign-in';
        final signingUp = state.subloc == '/sign-up';

        if (!signedIn) {
          return signingIn
              ? null
              : signingUp
                  ? null
                  : '/sign-in';
        }

        // If the user is signed in but still on the login page, send them to
        // the home page
        if (signingIn) return '/';

        // No need to redirect at all
        return null;
      },
      errorBuilder: (context, state) => const UnknownPage());
}
