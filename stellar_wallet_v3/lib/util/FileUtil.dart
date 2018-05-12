import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:stellar_wallet_v3/data/Record.dart';
import 'package:stellar_wallet_v3/data/RecordsBag.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/data/Wallets.dart';

class FileUtil {
  static File jsonFile;
  static Directory dir;
  static bool fileExists;

  static Future<List<Wallet>> getWallets() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/wallety.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print("FileUtil ## file exists, reading ...");
      String string = await jsonFile.readAsString();
      Map map = json.decode(string);
      Wallets w = new Wallets.fromJson(map);
      var cnt = w.wallets.length;
      print('FileUtil ## returning wallets found: $cnt');
      return w.wallets;
    } else {
      print('FileUtil ## file does not exist. returning empty list');
      Wallets w = new Wallets.create();
      w.wallets = new List();
      return w.wallets;
    }
  }

  static Future<int> saveWallets(Wallets wallets) async {
    Map map = wallets.toJson();

    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/wallety.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print('FileUtil ## file exists ...writing wallets file');
      jsonFile.writeAsString(json.encode(map));
      print(
          'FileUtil ##  has cached list of wallets))))))))))))))))))) : ${wallets.wallets.length}');
      return 0;
    } else {
      print(
          'FileUtil ## file does not exist ...creating and writing wallets file');
      var file = await jsonFile.create();
      var x = await file.writeAsString(json.encode(map));
      print('FileUtil ## looks like we cooking with gas!' + x.path);
      return 0;
    }
  }

  static Future<List<Record>> getPayments() async {
    dir = await getApplicationDocumentsDirectory();

    jsonFile = new File(dir.path + "/payments.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print("FileUtil ## file exists, reading ...");
      String string = await jsonFile.readAsString();
      Map map = json.decode(string);
      RecordsBag w = new RecordsBag.fromJson(map);
      var cnt = w.payments.length;
      print('FileUtil ## returning payments found: $cnt');
      return w.payments;
    } else {
      print('FileUtil ## file does not exist. returning empty list');
      RecordsBag w = new RecordsBag.create();
      w.payments = new List();
      return w.payments;
    }
  }

  static Future<int> savePayments(RecordsBag payments) async {
    Map map = payments.toJson();
    dir = await getApplicationDocumentsDirectory();
    jsonFile = new File(dir.path + "/payments.json");
    fileExists = await jsonFile.exists();

    if (fileExists) {
      print('FileUtil ## file exists ...writing payments file');
      jsonFile.writeAsString(json.encode(map));
      print(
          'FileUtil ##  has cached list of payments))))))))))))))))))) : ${payments.payments.length}');
      return 0;
    } else {
      print(
          'FileUtil ## file does not exist ...creating and writing payments file');
      var file = await jsonFile.create();
      var x = await file.writeAsString(json.encode(map));
      print('FileUtil ## looks like we cooking with gas!' + x.path);
      return 0;
    }
  }
}
