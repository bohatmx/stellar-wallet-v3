import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/ui/payment_widget.dart';
import 'package:stellar_wallet_v3/ui/wallet_list.dart';

BuildContext ctx;
final FirebaseDatabase fb = FirebaseDatabase.instance;
final bool DEBUGGING = true;

class WalletWidget extends StatelessWidget {
  final Wallet wallet;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  WalletWidget(this.wallet, this._scaffoldKey);
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
                    left: 8.0, right: 16.0, top: 8.0, bottom: 8.0),
                child: new Column(
                  children: <Widget>[
                    new GestureDetector(
                        onTap: _namePressed,
                        child: new Text(
                          wallet.name,
                          softWrap: true,
                          maxLines: 2,
                          style: new TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
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

  Future _namePressed() async {
    assert(wallet != null);
    var id = wallet.accountID;
    print("Wallet pressed, setting up Navigator and starting payment widget");
    print("Payment widget to send payment to: $id ...");

    PaymentResult result = await Navigator.push(
      ctx,
      new MaterialPageRoute(
          builder: (context) => new MakePayment(wallet, '0.00')),
    );
    print(
        'WalletWidget################### result from payment widget: $result');
    if (result == null) {
      return;
    }
    if (result.success) {
      if (WalletList.of(ctx) != null) {
        print('WalletList.of(ctx).receiveResult() about to run');
        WalletList.of(ctx).receiveResult(result);
      }
    }
  }
}
