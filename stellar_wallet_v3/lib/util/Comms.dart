import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:stellar_wallet_v3/data/Account.dart';
import 'package:stellar_wallet_v3/data/Record.dart';

class Communications {
  static const URL_PREFIX = "https://horizon-testnet.stellar.org/";

  Future<Account> getAccount(String accountID) async {
    assert(accountID != null);
    String url = URL_PREFIX + "accounts/" + accountID;
    print("account url: " + url);
    var httpClient = new HttpClient();

    Account acct;

    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var statusCode = response.statusCode;
    print("Stellar HTTP status code: $statusCode");
    if (response.statusCode == HttpStatus.OK) {
      var jx = await response.transform(utf8.decoder).join();
      Map data = json.decode(jx);
      acct = new Account.fromJson(data);
      print("****** Stellar Account from network: $data");
    } else {
      var code = response.statusCode;
      var msg = 'Bad Stellar HTTP status code: $code';
      print(msg);
      throw (msg);
    }

    return acct;
  }

  static const LIMIT = 200;
  static const ORDER = "desc";

  Future<dynamic> getPayments(String accountID) async {
    //GET https://horizon-testnet.stellar.org/payments?limit=5&order=desc
    Map map = new Map();
    map["order"] = "desc";
    map["limit"] = 1000;

    assert(accountID != null);
    var url =
        URL_PREFIX + "accounts/$accountID/payments?limit=$LIMIT&order=$ORDER";
    print("payments url: " + url);
    var httpClient = new HttpClient();

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      var statusCode = response.statusCode;
      print("getPayments Stellar HTTP status code: $statusCode");
      if (response.statusCode == HttpStatus.OK) {
        var jsonData = await response.transform(utf8.decoder).join();
//        var s = jsonData.replaceAll(",", ",\n");
//        print('Communications.getPayments  jsondata: $s');
        Map data = json.decode(jsonData);
//        print('Communications.getPayments data: $data');
//        var links = data['_links'];
        var emb = data['_embedded'];

//        print('links $links');
//        print('emb $emb');

        List list = emb['records'];
        List<Record> records = new List();
        list.forEach((val) {
          var mLinks = new List();
          Map links = val['_links'];
          links.forEach((key, val) {
            var mlink = new StellarLink(key, val['href']);
            mLinks.add(mlink);
//            print('mlink: ${mlink.printInfo()}');
          });
          try {
            var rec = new Record.fromJson(val);
            rec.mLinks = mLinks;
            records.add(rec);
//            print(rec.toJson());
          } catch (e) {
            print('%%%%%%%%% ERROR');
          }
        });
        return records;
      } else {
        return null;
      }
    } catch (exception) {
      return exception;
    }
  }
}
