import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stellar_wallet_v3/supplemental/cut_corners_border.dart';
import 'package:stellar_wallet_v3/util/shared_prefs.dart';

class MyThemes {
  static List<ThemeData> themes = new List<ThemeData>();
  static Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);
  static const kShrinePink50 = const Color(0xFFFEEAE6);
  static const kShrinePink100 = const Color(0xFFFEDBD0);
  static const kShrinePink300 = const Color(0xFFFBB8AC);

  static const kShrineBrown900 = const Color(0xFF442B2D);

  static const kShrineErrorRed = const Color(0xFFC5032B);

  static const kShrineSurfaceWhite = const Color(0xFFFFFBFA);
  static const kShrineBackgroundWhite = Colors.white;

  static ThemeDatabgetShrineTheme() {
    final ThemeData _kShrineTheme = _buildShrineTheme();
  }

  static ThemeData getShrineTheme() {
    return _buildShrineTheme();
  }

  static ThemeData _buildShrineTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      accentColor: kShrineBrown900,
      primaryColor: kShrinePink100,
      buttonColor: kShrinePink100,
      scaffoldBackgroundColor: kShrineBackgroundWhite,
      cardColor: kShrineBackgroundWhite,
      textSelectionColor: kShrinePink100,
      errorColor: kShrineErrorRed,
      textTheme: _buildShrineTextTheme(base.textTheme),
      primaryTextTheme: _buildShrineTextTheme(base.primaryTextTheme),
      accentTextTheme: _buildShrineTextTheme(base.accentTextTheme),
      primaryIconTheme: base.iconTheme.copyWith(color: kShrineBrown900),
      inputDecorationTheme: InputDecorationTheme(
        border: CutCornersBorder(),
      ),
    );
  }

  static ThemeData _buildTheme(
      {Color primary,
      Color accent,
      Color btnColor,
      Color scaffoldColor,
      Color cardColor,
      Color textSelectionColor,
      Color errColor,
      Color displayColor,
      Color bodyColor,
      IconThemeData iconThemeData,
      double titleFontSize,
      double textFontSize,
      String fontFamily}) {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      accentColor: accent,
      primaryColor: primary,
      buttonColor: btnColor,
      scaffoldBackgroundColor: scaffoldColor,
      cardColor: cardColor,
      textSelectionColor: textSelectionColor,
      errorColor: errColor,
      iconTheme: iconThemeData,
//      textTheme: _buildTextTheme(
//          base: base.textTheme,
//          displayColor: displayColor,
//          bodyColor: bodyColor),
//      primaryTextTheme: _buildTextTheme(
//          base: base.primaryTextTheme,
//          displayColor: displayColor,
//          bodyColor: bodyColor,
//          titleFontSize: titleFontSize,
//          textFontSize: textFontSize,
//          fontFamily: fontFamily),
//      accentTextTheme: _buildTextTheme(
//          base: base.primaryTextTheme,
//          displayColor: displayColor,
//          bodyColor: bodyColor,
//          titleFontSize: titleFontSize,
//          textFontSize: textFontSize,
//          fontFamily: fontFamily),
      primaryIconTheme: base.iconTheme.copyWith(color: accent),
      inputDecorationTheme: InputDecorationTheme(
        border: CutCornersBorder(),
      ),
    );
  }

  static TextTheme _buildTextTheme(
      {TextTheme base,
      Color displayColor,
      Color bodyColor,
      double titleFontSize,
      double textFontSize,
      String fontFamily}) {
    return base
        .copyWith(
          headline: base.headline.copyWith(
            fontWeight: FontWeight.w500,
            fontFamily: fontFamily,
          ),
          title: base.title.copyWith(fontSize: titleFontSize),
          caption: base.caption.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: textFontSize,
            fontFamily: fontFamily,
          ),
        )
        .apply(
          fontFamily: fontFamily,
          displayColor: displayColor,
          bodyColor: bodyColor,
        );
  }

  static TextTheme _buildShrineTextTheme(TextTheme base) {
    return base
        .copyWith(
          headline: base.headline.copyWith(
            fontWeight: FontWeight.w500,
          ),
          title: base.title.copyWith(fontSize: 18.0),
          caption: base.caption.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
          ),
        )
        .apply(
          fontFamily: 'Raleway',
          displayColor: kShrineBrown900,
          bodyColor: kShrineBrown900,
        );
  }

  static ThemeData getRandomTheme() {
    themes.clear();
    loadThemes();

    int index = rand.nextInt(14);
    print("################### returning ThemeData from index $index");
    var theme = themes.elementAt(index);
    assert(theme != null);
    return theme;
  }

  static ThemeData getTheme(int index) {
    themes.clear();
    loadThemes();
    print("################### returning ThemeData from index $index");
    var theme = themes.elementAt(index);
    assert(theme != null);
    SharedPrefs.saveThemeIndex(index);
    return theme;
  }

  static const RALEWAY = 'Raleway', RUBIK = 'Rubik';
  static void loadThemes() {
    IconThemeData data = IconThemeData(color: Colors.white);
//    ThemeData f = _buildTheme(
//        fontFamily: RALEWAY,
//        primary: Colors.indigo.shade400,
//        accent: Colors.red.shade300,
//        btnColor: Colors.indigo.shade100,
//        scaffoldColor: Colors.white,
//        cardColor: kShrineBackgroundWhite,
//        textSelectionColor: Colors.red.shade800,
//        errColor: Colors.deepOrange,
//        displayColor: Colors.blue,
//        bodyColor: Colors.black,
//        titleFontSize: 20.0,
//        textFontSize: 14.0,
//        iconThemeData: data);
//
//    themes.add(f);
    ThemeData f0 = new ThemeData(
        primaryColor: Colors.indigo.shade300,
        accentColor: Colors.pink,
        iconTheme: data,
        splashColor: Colors.lightBlue);

    themes.add(f0);

    ThemeData f1 = new ThemeData(
        primaryColor: Colors.teal.shade300,
        accentColor: Colors.indigo.shade300,
        splashColor: Colors.lightBlue);
    themes.add(f1);

    ThemeData f2 = new ThemeData(
        primaryColor: Colors.deepOrange..shade300,
        accentColor: Colors.blue,
        splashColor: Colors.lightBlue);
    themes.add(f2);

    ThemeData f3 = new ThemeData(
        primaryColor: Colors.deepPurple..shade300,
        accentColor: Colors.red,
        splashColor: Colors.blue);
    themes.add(f3);

    ThemeData f4 = new ThemeData(
        primaryColor: Colors.blueGrey.shade300,
        accentColor: Colors.pink,
        splashColor: Colors.blue);
    themes.add(f4);

    ThemeData f5 = new ThemeData(
        primaryColor: Colors.blue.shade300,
        accentColor: Colors.red,
        splashColor: Colors.green);
    themes.add(f5);

    ThemeData f6 = new ThemeData(
        primaryColor: Colors.brown.shade300,
        accentColor: Colors.amber.shade900,
        splashColor: Colors.red);
    themes.add(f6);

    ThemeData f7 = new ThemeData(
        primaryColor: Colors.amber.shade300,
        accentColor: Colors.teal,
        splashColor: Colors.red);
    themes.add(f7);

    ThemeData f8 = new ThemeData(
        primaryColor: Colors.cyan.shade300,
        accentColor: Colors.purple,
        splashColor: Colors.pink);
    themes.add(f8);

    ThemeData f9 = new ThemeData(
        primaryColor: Colors.blueGrey.shade300,
        accentColor: Colors.teal.shade600,
        splashColor: Colors.blue);
    themes.add(f9);

    ThemeData f10 = new ThemeData(
        primaryColor: Colors.teal,
        accentColor: Colors.indigo,
        splashColor: Colors.lime);
    themes.add(f10);

    ThemeData f11 = new ThemeData(
        primaryColor: Colors.red.shade300,
        accentColor: Colors.indigo,
        splashColor: Colors.amber);
    themes.add(f11);

    ThemeData f12 = new ThemeData(
        primaryColor: Colors.pink.shade300,
        accentColor: Colors.teal,
        splashColor: Colors.lightBlue);
    themes.add(f12);

    ThemeData f13 = new ThemeData(
        primaryColor: Colors.brown.shade300,
        accentColor: Colors.pink,
        splashColor: Colors.blue);
    themes.add(f13);

    ThemeData f14 = new ThemeData(
        primaryColor: Colors.lime.shade300,
        accentColor: Colors.indigo,
        splashColor: Colors.yellow);
    themes.add(f14);
  }
}
