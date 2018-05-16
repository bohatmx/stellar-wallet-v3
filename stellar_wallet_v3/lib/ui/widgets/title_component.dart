import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stellar_wallet_v3/data/Record.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/ui/account_details.dart';
import 'package:stellar_wallet_v3/ui/payment_widget.dart';
import 'package:stellar_wallet_v3/ui/picture_grid.dart';
import 'package:stellar_wallet_v3/ui/present_qrcode.dart';
import 'package:stellar_wallet_v3/util/printer.dart';
import 'package:stellar_wallet_v3/util/shared_prefs.dart';
import 'package:zxing/zxing.dart';

class TitleComponent extends StatefulWidget {
  final List<Record> records;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  TitleComponent(this._scaffoldKey, this.records);

  @override
  _TitleComponentState createState() => new _TitleComponentState();
}

class _TitleComponentState extends State<TitleComponent> {
  Wallet wallet;
  List<Record> records;
  GlobalKey<ScaffoldState> _scaffoldKey;
  NetworkImage _profileImage = new NetworkImage(
      "https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/profilePictures%2Fblack_woman.jpg?alt=media&token=2858261a-db84-40af-a5a0-fd311d5723b5");
  bool _checkLoaded = true;
  Image image;
  var _loadImage = new AssetImage('assets/girl.png');
  BuildContext ctx;

  String amount;
  String walletName;
  double opacity = 1.0;

  @override
  initState() {
    print("......... initState .... get image url");
    super.initState();
    _getWallet();
    _profileImage.resolve(new ImageConfiguration()).addListener((_, __) {
      if (mounted) {
        setState(() {
          _checkLoaded = false;
        });
      }
    });
  }

  _getWallet() async {
    wallet = await SharedPrefs.getWallet();
    setState(() {
      walletName = wallet.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.records != null) {
      records = widget.records;
      _scaffoldKey = widget._scaffoldKey;
      if (wallet != null) {}
    } else {
      if (wallet == null) {} else {
        if (wallet.url != null) {
          _profileImage = new NetworkImage(wallet.url);
        }
      }
    }
    ctx = context;
    return new Container(
      child: new Padding(
        padding: new EdgeInsets.only(bottom: 20.0),
        child: new Column(
          children: <Widget>[
            new Padding(
              padding: new EdgeInsets.only(top: 0.0, bottom: 10.0),
              child: new GestureDetector(
                child: new Text(
                  walletName == null ? "Name Unavailable?" : walletName,
                  style: new TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                ),
                onTap: _startQRMaker,
              ),
            ),
            new Center(
              child: new Row(
                children: <Widget>[
                  new GestureDetector(
                    child: new Padding(
                      padding: new EdgeInsets.only(left: 40.0, right: 10.0),
                      child: new CircleAvatar(
                        backgroundImage:
                            _checkLoaded ? _loadImage : _profileImage,
                        radius: 36.0,
                        backgroundColor: Colors.black,
                      ),
                    ),
                    onTap: _startPictureGrid,
                  ),
                  new Opacity(
                    opacity: opacity == null ? 0.0 : opacity,
                    child: new Padding(
                      padding: new EdgeInsets.only(left: 40.0, top: 10.0),
                      child: new RaisedButton(
                        onPressed: _scanBarcode,
                        elevation: 8.0,
                        color: Theme.of(context).primaryColor,
                        child: new Text(
                          'Scan to Pay',
                          style: new TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                    child: new IconButton(
                        icon: new Icon(FontAwesomeIcons.bug),
                        onPressed: _nothing),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _startQRMaker() async {
    print("starting the camera ...");

    PaymentReceived result = await Navigator.push(
      ctx,
      new MaterialPageRoute(builder: (context) => new PresentQRCode()),
    );
    print('result from PresentQRCode $result');
    debugPrint('wtf debugPrint? result from PresentQRCode $result');
    if (result == null) return null;
    if (result.success) {
      _showSnackbar("Payment received: " + result.amount + ' XLM');
      AccountDetails.of(ctx).refresh();
    }
  }

  static const platform = const MethodChannel('com.oneconnect.wallet/scan');
  static const platformCamera =
      const MethodChannel('com.oneconnect.wallet/camera');

  Future _scanBarcode() async {
    print('############### scan starting ... ##############');
    try {
      Zxing.scan(isBeep: true, isContinuous: false).then((resultList) {
        print('_TitleComponentState._scanBarcode $resultList');
        String datax = resultList[0];
        var strings = datax.split('@');
        var walletID = strings.elementAt(0);
        amount = strings.elementAt(1);
        var reference = FirebaseDatabase.instance
            .reference()
            .child('wallets')
            .child(walletID);
        reference.once().then((snapshot) {
          Map map = snapshot.value;
          var destWallet = new Wallet.fromJSON(map);
          print(destWallet.toJson());
          _startPayment(destWallet, amount);
        });
      });
    } catch (e) {
      print(e);
      _showSnackbar('QR Code scan failed');
    }
  }

  Future _startPictureGrid() async {
    var reference = FirebaseDatabase.instance
        .reference()
        .child('wallets')
        .child(wallet.walletID);
    final url = await Navigator.push(
      ctx,
      new MaterialPageRoute(builder: (context) => new PictureGrid()),
    );
    if (url == null) {
      print('_TitleComponentState._startPictureGrid - did NOT select picture');
      return null;
    }
    setState(() {
      print('_TitleComponentState._startPictureGrid -----');
      _profileImage = new NetworkImage(url);
    });
    P.mprint(widget, url);
    P.mprint(widget, "walletID: " + wallet.walletID);
    wallet.url = url;
    SharedPrefs.saveWallet(wallet);
    P.mprint(widget, wallet.toJson().toString());
    reference.set(wallet.toJson()).then((result) {
      P.mprint(widget, "Firebase done updating wallet");
    });
  }

  void _showSnackbar(String message) {
    P.mprint(widget, "trying to show snackBar ...");
    if (_scaffoldKey.currentState == null) {
      return;
    }
    _scaffoldKey.currentState.hideCurrentSnackBar();
    var snackbar = new SnackBar(
      content: new Text(
        message,
        style: new TextStyle(color: Colors.white),
      ),
      duration: new Duration(minutes: 2),
      backgroundColor: Colors.teal.shade900,
      action: new SnackBarAction(
          label: 'Close',
          onPressed: () {
            _scaffoldKey.currentState.hideCurrentSnackBar();
          }),
    );

    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void _nothing() {}

  void _startPayment(Wallet destWallet, String amount) {
    print(
        '_TitleComponentState._startPayment to ............. ${destWallet.accountID} amount: $amount');
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (context) => MakePayment(destWallet, amount)),
    );
  }
}
