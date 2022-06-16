import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/authentication_info.dart';
import '../theme/style.dart';

// Side menu (drawer) of the app
class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: appThemeSecondary,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: appThemeSecondary),
            child: const Icon(
              Icons.fingerprint_rounded,
              color: Colors.white54,
              size: 48,
            ),
          ),
          DrawerListTile(
            title: "Home",
            icon: Icons.house_rounded,
            onPressed: () {
              GoRouter.of(context).go('/');
            },
          ),
          DrawerListTile(
            title: "Profile",
            icon: Icons.person_rounded,
            onPressed: () {
              GoRouter.of(context).go('/profile');
            },
          ),
          DrawerListTile(
            title: "Search",
            icon: Icons.person_search,
            onPressed: () {
              GoRouter.of(context).go('/search');
            },
          ),
          DrawerListTile(
            title: "Settings",
            icon: Icons.settings,
            onPressed: () {
              GoRouter.of(context).go('/settings');
            },
          ),
          DrawerListTile(
            title: "Sign out",
            icon: Icons.logout,
            onPressed: () {
              context.read<AuthenticationInfo>().firebaseSignOut();
            },
          ),
        ],
      ),
    );
  }
}

// Items located within the side menu (drawer)
class DrawerListTile extends StatelessWidget {
  const DrawerListTile(
      {Key? key,
      required this.title,
      required this.onPressed,
      required this.icon})
      : super(key: key);

  final String title;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      horizontalTitleGap: 0.0,
      leading: Icon(icon, color: Colors.white54),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}
