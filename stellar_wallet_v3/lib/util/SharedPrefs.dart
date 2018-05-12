import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_wallet_v3/data/Account.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';

class SharedPrefs {
  static Future saveAccount(Account account) async {
    print("SharedPrefs - saving account data .........");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map jsonx = account.toJson();
    var jx = json.encode(jsonx);
    print(jx);
    prefs.setString('account', jx);
    //prefs.commit();
    print("SharedPrefs =========  account data SAVED.........");
  }

  static Future<Account> getAccount() async {
    print("SharedPrefs =========  getting cached account data.........");
    var prefs = await SharedPreferences.getInstance();
    var sting = prefs.getString('account');
    if (sting == null) {
      return null;
    }
    var jx = json.decode(sting);
    print(jx);
    Account account = new Account.fromJson(jx);
    return account;
  }

  static Future saveFCMToken(String token) async {
    print("SharedPrefs saving token ..........");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("fcm", token);
    //prefs.commit();

    print("FCM token saved in cache prefs: $token");
  }

  static Future<String> getFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("fcm");
    print("SharedPrefs - FCM token from prefs: $token");
    return token;
  }

  static Future<Wallet> getWallet() async {
    print("SharedPrefs - getting wallet data ..........");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var jx = prefs.getString('wallet');
    if (jx == null) {
      return null;
    }
    var map = json.decode(jx);
    Wallet w = new Wallet.fromJson(map);
    print("SharedPrefs - Check the details of the wallet retrieved");
    print(w.toJson());
    return w;
  }

  static Future saveWallet(Wallet wallet) async {
    print("SharedPrefs - saving wallet data .........");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map map = wallet.toJson();
    var jx = json.encode(map);

    prefs.setString("wallet", jx);
    //prefs.commit();
    print("SharedPrefs - wallet saved in local prefs....... ");
    return null;
  }

  static void saveThemeIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("themeIndex", index);
    //prefs.commit();
  }

  static Future<int> getThemeIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int index = prefs.getInt("themeIndex");
    print("=================== SharedPrefs theme index: $index");
    return index;
  }

  static void savePictureUrl(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("url", url);
    //prefs.commit();
    print('picture url saved to shared prefs');
  }

  static Future<String> getPictureUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String path = prefs.getString("url");
    print("=================== SharedPrefs url index: $path");
    return path;
  }

  static void savePicturePath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("path", path);
    //prefs.commit();
    print('picture path saved to shared prefs');
  }

  static Future<String> getPicturePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String path = prefs.getString("path");
    print("=================== SharedPrefs path index: $path");
    return path;
  }
}
