import 'package:flutter/material.dart';
import '../theme/style.dart';

// Overall theme for the app
// (e.g., text font family, text colour, primary colour, etc.)
class AppTheme {
  static final ThemeData custom = ThemeData(
      snackBarTheme: const SnackBarThemeData(
          contentTextStyle:
              TextStyle(fontFamily: 'Montserrat', color: Colors.white54)),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white54,
        selectionColor: Colors.white54,
        selectionHandleColor: Colors.white54,
      ),
      primaryColor: appThemeSecondary,
      scaffoldBackgroundColor: appThemePrimary,
      canvasColor: appThemePrimary,
      hintColor: Colors.blueGrey[400],
      fontFamily: 'Montserrat',
      appBarTheme: AppBarTheme(color: appThemePrimary),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: appThemePrimary,
        selectedIconTheme: const IconThemeData(color: Colors.white),
        selectedItemColor: Colors.white,
      ),
      textTheme: const TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white, fontSize: 16),
          headline1: TextStyle(
            color: Colors.white,
            fontSize: 50.0,
            fontWeight: FontWeight.bold,
          ),
          headline2: TextStyle(color: Colors.white, fontSize: 24),
          headline3: TextStyle(
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
          headline6: TextStyle(
            color: Colors.white,
            fontSize: 22.5,
            fontWeight: FontWeight.bold,
          ),
          subtitle1: TextStyle(color: Colors.white),
          subtitle2: TextStyle(color: Colors.white)),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              primary: appThemeTertiary,
              textStyle: const TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
              shadowColor: appThemeSecondary,
              onPrimary: Colors.white,
              fixedSize: const Size(300, 50),
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ))),
      inputDecorationTheme: InputDecorationTheme(
          border: InputBorder.none,
          fillColor: appThemeSecondary,
          filled: true,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: appThemeSecondary)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: appThemeSecondary))),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: Colors.white,
        ),
      ));
}
