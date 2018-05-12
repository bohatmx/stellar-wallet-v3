import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stellar_wallet_v3/util/SharedPrefs.dart';

class MyThemes {
  static List<ThemeData> themes = new List<ThemeData>();
  static Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);

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

  static void loadThemes() {
    ThemeData f = new ThemeData(
        primaryColor: Colors.indigo.shade200,
        accentColor: Colors.deepOrangeAccent,
        splashColor: Colors.red);
    themes.add(f);

    ThemeData f1 = new ThemeData(
        primaryColor: Colors.teal.shade200,
        accentColor: Colors.pink,
        splashColor: Colors.lightBlue);
    themes.add(f1);

    ThemeData f2 = new ThemeData(
        primaryColor: Colors.deepOrange..shade200,
        accentColor: Colors.blue,
        splashColor: Colors.lightBlue);
    themes.add(f2);

    ThemeData f3 = new ThemeData(
        primaryColor: Colors.deepPurple..shade200,
        accentColor: Colors.red,
        splashColor: Colors.blue);
    themes.add(f3);

    ThemeData f4 = new ThemeData(
        primaryColor: Colors.blueGrey.shade200,
        accentColor: Colors.pink,
        splashColor: Colors.blue);
    themes.add(f4);

    ThemeData f5 = new ThemeData(
        primaryColor: Colors.blue.shade200,
        accentColor: Colors.red,
        splashColor: Colors.green);
    themes.add(f5);

    ThemeData f6 = new ThemeData(
        primaryColor: Colors.brown.shade200,
        accentColor: Colors.teal,
        splashColor: Colors.red);
    themes.add(f6);

    ThemeData f7 = new ThemeData(
        primaryColor: Colors.amber.shade300,
        accentColor: Colors.teal,
        splashColor: Colors.red);
    themes.add(f7);

    ThemeData f8 = new ThemeData(
        primaryColor: Colors.cyan.shade200,
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
        primaryColor: Colors.red.shade200,
        accentColor: Colors.indigo,
        splashColor: Colors.amber);
    themes.add(f11);

    ThemeData f12 = new ThemeData(
        primaryColor: Colors.pink.shade200,
        accentColor: Colors.teal,
        splashColor: Colors.lightBlue);
    themes.add(f12);

    ThemeData f13 = new ThemeData(
        primaryColor: Colors.brown.shade200,
        accentColor: Colors.pink,
        splashColor: Colors.blue);
    themes.add(f13);

    ThemeData f14 = new ThemeData(
        primaryColor: Colors.lime.shade200,
        accentColor: Colors.indigo,
        splashColor: Colors.yellow);
    themes.add(f14);
  }
}
