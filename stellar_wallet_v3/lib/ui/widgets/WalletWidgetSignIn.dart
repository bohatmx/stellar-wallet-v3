import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/util/shared_prefs.dart';

BuildContext ctx;
final FirebaseDatabase fb = FirebaseDatabase.instance;
final bool DEBUGGING = true;

class WalletWidgetSignIn extends StatelessWidget {
  final Wallet wallet;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  WalletWidgetSignIn(this.wallet, this._scaffoldKey);
  final String url =
      "https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/profilePictures%2Fblack_woman.jpg?alt=media&token=2858261a-db84-40af-a5a0-fd311d5723b5";

  @override
  Widget build(BuildContext context) {
    ctx = context;
    assert(wallet != null);

    return new Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
      child: new Card(
        child: new Column(children: <Widget>[
          new Row(
            children: <Widget>[
              new Padding(
                padding: new EdgeInsets.only(
                    left: 2.0, right: 2.0, top: 8.0, bottom: 8.0),
                child: new GestureDetector(
                  onTap: _namePressed,
                  child: new CircleAvatar(
                    backgroundImage:
                        new NetworkImage(wallet.url != null ? wallet.url : url),
                    radius: 36.0,
                    backgroundColor: Colors.black,
                  ),
                ),
              ),
              new Padding(
                padding: new EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                child: new Column(
                  children: <Widget>[
                    new GestureDetector(
                        onTap: _namePressed,
                        child: new Text(
                          wallet.name,
                          style: new TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
            ],
          ),
          new Padding(
            padding: new EdgeInsets.only(
                left: 60.0, right: 20.0, top: 0.0, bottom: 8.0),
            child: new Text(
              wallet.accountID == null
                  ? "Account Unavailable"
                  : wallet.accountID,
              style: new TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey),
            ),
          ),
        ]),
      ),
    );
  }

  FirebaseDatabase fb = FirebaseDatabase.instance;
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  Future _namePressed() async {
    print('WalletWidgetSignIn._namePressed ################################');
    assert(wallet != null);
    var token = await _firebaseMessaging.getToken();
    assert(token != null);
    SharedPrefs.saveFCMToken(token);
    print("FCM token just cached: $token");
    wallet.fcmToken = token;

    print('............saving Private Ryan ${wallet.toJson()}');
    await SharedPrefs.saveWallet(wallet);
    var ref = fb.reference().child('wallets').child(wallet.walletID);
    await ref.set(wallet.toJson());
    print('%%%%%%%% wallet updated with new token');
    Navigator.popAndPushNamed(ctx, '/account');
  }
}
