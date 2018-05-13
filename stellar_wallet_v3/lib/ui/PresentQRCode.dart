import 'dart:async';
import 'dart:math';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/util/printer.dart';
import 'package:stellar_wallet_v3/util/shared_prefs.dart';

class PresentQRCode extends StatefulWidget {
  @override
  _PresentQRCodeState createState() => new _PresentQRCodeState();
}

BuildContext ctx;
enum PlayerState { stopped, playing, paused }

class _PresentQRCodeState extends State<PresentQRCode>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Wallet wallet;
  String barcodeData, accountID;
  AnimationController controller;
  Animation<double> animation;
  String paymentMessage;
  Duration duration;
  Duration position;

  @override
  initState() {
    super.initState();
    //_configMessaging();

    controller = new AnimationController(
        duration: new Duration(milliseconds: 1000), vsync: this);
    animation = new CurvedAnimation(parent: controller, curve: Curves.easeIn);
    animation.addListener(() {
      this.setState(() {});
    });
    animation.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _showSnak("Hey, show this QR code to payer");
      }
    });

    _getWallet();
    _showDialog();
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  AudioPlayer audioPlayer;
  String localFilePath;
  PlayerState playerState = PlayerState.stopped;
  bool isMuted;
  var rand = new Random(new DateTime.now().millisecondsSinceEpoch);

  void _showSnak(String message) {
    print("trying to show snackBar ...");
    if (_scaffoldKey.currentState == null) {
      return;
    }
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        message,
        style: new TextStyle(color: Colors.yellow),
      ),
      duration: new Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        elevation: 8.0,
        title: new Text("OneConnect Payments",
            style: new TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal)),
        bottom: new PreferredSize(
          preferredSize: const Size.fromHeight(130.0),
          child: new Theme(
            data: Theme.of(context).copyWith(accentColor: Colors.white),
            child: new Padding(
              padding: new EdgeInsets.only(bottom: 5.0),
              child: new Column(
                children: <Widget>[
                  new Padding(
                    padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: new Text(
                      "Send Me Money",
                      style: new TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0),
                    ),
                  ),
                  new Center(
                    child: new Column(
                      children: <Widget>[
                        new Padding(
                          padding: new EdgeInsets.only(left: 10.0, top: 10.0),
                          child: new Padding(
                            padding: const EdgeInsets.only(
                                left: 40.0, right: 40.0, bottom: 10.0),
                            child: new Text(
                              accountID == null ? "" : accountID,
                              style: new TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: new Column(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.all(10.0),
            child: new Center(
              child: new Card(
                elevation: 8.0,
                child: new Column(
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 8.0, bottom: 10.0),
                      child: new Text(
                        amount == null ? '' : amount,
                        style: new TextStyle(
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Raleway',
                            fontSize: 40.0,
                            color: Colors.teal),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(left: 60.0),
                      child: new QrImage(
                        data: barcodeData,
                        size: 240.0,
                        version: 4,
                        padding: new EdgeInsets.only(bottom: 40.0, top: 10.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        elevation: 28.0,
        onPressed: _showDialog,
        tooltip: 'Increment',
        child: new Icon(FontAwesomeIcons.qrcode),
      ),
    );
  }

  Future _getWallet() async {
    wallet = await SharedPrefs.getWallet();
    barcodeData = wallet.walletID;
    accountID = wallet.accountID;
    controller.forward();
  }

  String amount;

  void _showDialog() async {
    await showDialog<String>(
      context: context,
      child: new _SystemPadding(
        child: new AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                child: new Text(
                  'Required Amount',
                  style: new TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
              new Expanded(
                child: new TextField(
                  autofocus: true,
                  onChanged: _onTextChanged,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                      labelText: 'Amount', hintText: '100.00'),
                  style: new TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
              )
            ],
          ),
          actions: <Widget>[
            new FlatButton(
                child: const Text('DONE'),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ],
        ),
      ),
    );
  }

  void _onTextChanged(String value) {
    P.mprint(
        widget, '_onTextChanged ................:::::::::::: value: $value');
    if (value == null || value.isEmpty) {
      return;
    }
    var amt = double.parse(value);
    if (amt != null && amt > 0) {
      controller.reset();
      setState(() {
        amount = value;
        barcodeData = wallet.walletID + '@' + amount;
        P.mprint(widget, 'barcodedata inside setState: $barcodeData');
      });
    }
  }
}

class PaymentReceived {
  String name, amount;
  bool success;

  PaymentReceived({this.name, this.amount, this.success});
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.viewInsets,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
