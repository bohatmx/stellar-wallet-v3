import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stellar_wallet_v3/data/Account.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/ui/account_details.dart';
import 'package:stellar_wallet_v3/ui/sign_in.dart';
import 'package:stellar_wallet_v3/ui/wallet_list.dart';
import 'package:stellar_wallet_v3/ui/widgets/bag.dart';
import 'package:stellar_wallet_v3/util/printer.dart';
import 'package:stellar_wallet_v3/util/shared_prefs.dart';
import 'package:stellar_wallet_v3/util/themes.dart';

void main() => runApp(new TheApp());

class TheApp extends StatefulWidget {
  @override
  _TheAppState createState() => new _TheAppState();
  static _TheAppState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_TheAppState>());
}

Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);

class _TheAppState extends State<TheApp> {
  ThemeData themeData;
  Account account;
  Wallet wallet;

  @override
  initState() {
    super.initState();
    P.mprint(widget,
        "@@@@@@@@@@@@ ----------------------- initState - getting theme ...");
    _getTheme();
    _getWallet();
  }

  updateTheme(int index) async {
    setState(() {
      print("setState: ############## setting Theme with index: $index");
      themeData = MyThemes.getTheme(index);
    });
  }

  _getTheme() async {
    int index = await SharedPrefs.getThemeIndex();
//    if (index != null) {
//      setState(() {
//        themeData = MyThemes.getTheme(0);
//      });
//      return null;
//    }
    if (index == null) {
      index = rand.nextInt(14);
      SharedPrefs.saveThemeIndex(index);
    } else {
      P.mprint(widget, "......cached theme index is: $index");
    }

    setState(() {
      print("setState: ############## setting Theme with index: $index");
      themeData = MyThemes.getTheme(index);
    });
  }

  void _getWallet() async {
    print('getting  wallet in main.dart -------------------------------------');
    wallet = await SharedPrefs.getWallet();
    if (wallet != null) {
      wallet.printDetails();
    }
  }

  Widget _getWidget() {
    if (wallet != null) {
      return new AccountDetails();
    } else {
      return new LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new BagWidget(
      refreshRequired: true,
      account: account,
      wallet: wallet,
      child: new MaterialApp(
        title: 'OCT Wallet',
        debugShowCheckedModeBanner: false,
        theme: themeData,
        home: _getWidget(),
        routes: <String, WidgetBuilder>{
          '/account': (BuildContext context) => new AccountDetails(),
          '/wallets': (BuildContext context) => new WalletList(),
          '/login': (BuildContext context) => new LoginPage(),
        },
      ),
    );
  }
}
