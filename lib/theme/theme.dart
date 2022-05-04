import 'package:flutter/material.dart';
import 'package:social_media_app/theme/style.dart';

class AppTheme {
  static final ThemeData custom = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      canvasColor: Colors.transparent,
      hintColor: Colors.blueGrey[400],
      fontFamily: 'Montserrat',
      appBarTheme: AppBarTheme(color: colorCustomLightBlue),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorCustomDarkBlue,
        selectedIconTheme: const IconThemeData(color: Colors.white),
        selectedItemColor: Colors.white,
      ),
      textTheme: TextTheme(
          bodyText1:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyText2: const TextStyle(color: Colors.white, fontSize: 16),
          headline1: TextStyle(
            color: colorCustomLightBlue,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
          headline2: const TextStyle(color: Colors.white, fontSize: 24),
          headline3: const TextStyle(
              shadows: <Shadow>[
                Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 8.0,
                    color: Colors.white),
              ],
              color: Colors.white,
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              letterSpacing: -2,
              height: 0.70),
          headline6: const TextStyle(
            color: Colors.white,
            fontSize: 22.5,
            fontWeight: FontWeight.bold,
          )),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
              shadowColor: colorCustomLightBlue,
              onPrimary: Colors.white,
              fixedSize: const Size(300, 50),
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ))),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ));
}
