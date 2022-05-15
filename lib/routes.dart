// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:social_media_app/screens/home.dart';
// import 'package:social_media_app/screens/sign_in.dart';
// import 'package:social_media_app/screens/sign_up.dart';
// import 'package:social_media_app/screens/two_factor_authentication.dart';
// import 'package:social_media_app/screens/unknown.dart';
// import 'package:social_media_app/services/authentication_info.dart';

// class CustomGoRouter {
//   final authenticationInfo = AuthenticationInfo();
//   late final GoRouter goRouter = GoRouter(
//         refreshListenable: authenticationInfo,
//         debugLogDiagnostics: true,
//         routes: <GoRoute>[
//           GoRoute(
//             path: '/',
//             builder: (BuildContext context, GoRouterState state) =>
//                 const HomePage(),
//           ),
//           GoRoute(
//             path: '/sign-in',
//             builder: (BuildContext context, GoRouterState state) =>
//                 const SignInPage(),
//           ),
//           GoRoute(
//             path: '/sign-up',
//             builder: (BuildContext context, GoRouterState state) =>
//                 const SignUpPage(),
//           ),
//           GoRoute(
//             path: '/unknown',
//             builder: (BuildContext context, GoRouterState state) =>
//                 const UnknownPage(),
//           ),
//           GoRoute(
//             path: '/2fa',
//             builder: (BuildContext context, GoRouterState state) =>
//                 const TwoFactorAuthenticationPage(),
//           ),
//         ],
//         redirect: (state) {
//           // The declaration of state variables, obtained via the Provider architecture,
//           // which may then be used for redirecting users
//           final signedIn = authenticationInfo.signedIn;
//           final doubleAuthenticated = authenticationInfo.doubleAuthenticatedAlt;
//           final doubleAuthenticationActivated =
//               authenticationInfo.doubleAuthenticationActivatedAlt;

//           // Debugging statement
//           debugPrint('Boolean for logged in status in redirect: ' +
//               signedIn.toString());

//           // The declaration of paths in which the user is or may be
//           // headed towards
//           final signingIn = state.subloc == '/sign-in';
//           final signingUp = state.subloc == '/sign-up';
//           final verifying2FA = state.subloc == '/2fa';

//           // If the user is signed out, and is headed towards neither the
//           // sign in page nor the sign up page, they would then be redirected
//           // to the sign in former
//           if (!signedIn) {
//             return signingIn
//                 ? null
//                 : signingUp
//                     ? null
//                     : '/sign-in';
//           }

//           /* From this point forward, it is established that the user is
//            already signed in */

//           // If the user has 2FA activated and is still on the sign in page,
//           // have them redirected to the 2FA page
//           if (doubleAuthenticationActivated) {
//             debugPrint('Double authentication activated');
//             if (!doubleAuthenticated) {
//               return signingIn
//                   ? '/2fa'
//                   : verifying2FA
//                       ? null
//                       : '/2fa';
//             }

//             if (verifying2FA && doubleAuthenticated) {
//               debugPrint('Is signed in and is double authenticated');
//               return '/';
//             }
//           }

//           debugPrint('Double authentication not activated');
//           if (signingIn) return '/';

//           return null;
//         },
//         errorBuilder: (context, state) => const UnknownPage());
    
// }
