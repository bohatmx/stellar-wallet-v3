import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stellar_wallet_v3/data/Account.dart';
import 'package:stellar_wallet_v3/data/Payment.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/ui/cccount_details.dart';
import 'package:stellar_wallet_v3/util/Comms.dart';
import 'package:stellar_wallet_v3/util/Printer.dart';
import 'package:stellar_wallet_v3/util/SharedPrefs.dart';
import 'package:stellar_wallet_v3/util/constants.dart';
import 'package:stellar_wallet_v3/util/encrypt_encrypt.dart';

class MakePayment extends StatefulWidget {
  final Wallet wallet;
  final String amount;
  MakePayment(this.wallet, this.amount);

  @override
  _PaymentWidgetState createState() => new _PaymentWidgetState();
}

const bool DEBUGGING = true;
BuildContext ctx;

class _PaymentWidgetState extends State<MakePayment> {
  Wallet destWallet;

  final FirebaseDatabase fb = FirebaseDatabase.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String url =
      "https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/profilePictures%2Fblack_woman.jpg?alt=media&token=2858261a-db84-40af-a5a0-fd311d5723b5";
  String amount, reqAmount;
  Wallet myWallet;
  Account account;
  String payeeUrl;
  final reference = FirebaseDatabase.instance.reference().child('payments');

  bool isSubmitting = false;
  String walletID;
  String destName, destAcct;

  @override
  initState() {
    super.initState();
    P.mprint(widget,
        '******************************** initState *********************');

    _getMyWallet();
  }

  void _getMyWallet() async {
    P.mprint(
        widget, "======= ******************** getting myWallet from cache");
    myWallet = await SharedPrefs.getWallet();
    var coms = new Communications();
    if (myWallet != null && myWallet.accountID != null) {
      account = await coms.getAccount(myWallet.accountID);
    }
  }

  void _onTextChanged(String value) {
    P.mprint(widget, "onTextChanged $value");
    amount = value;
  }

  void _ignore() {
    _showError("Payment processing is busy. Please wait");
  }

  _submitPayment() async {
    if (isSubmitting) {
      _ignore();
      return;
    }
    try {
      if (amount == null || amount.isEmpty) {
        if (reqAmount != '0.00') {
          amount = reqAmount;
        }
      }
      amount = amount.replaceAll(',', '.');
      var nAmt = double.parse(amount);
      var nBalance = double.parse(account.balances.elementAt(0).balance);
      if (nAmt + 1 > nBalance) {
        _showError('Please enter valid amount. Your balance is ' +
            account.balances.elementAt(0).balance);
        return;
      }
    } catch (e) {
      _showError('Please enter valid amount');
      return;
    }
    P.mprint(widget, "+++++++++++++++++ submitting payment $amount");
    if (amount == null || amount.isEmpty) {
      P.mprint(widget, "amount is null or empty");
      _showError('Please enter amount');
      return;
    }

    assert(destWallet != null);
    assert(myWallet != null);
    _showSnackbar("Submtting payment to Stellar Blockchain. Please wait");
    setState(() {
      isSubmitting = true;
    });

    var seed = await EncryptionUtil.decryptSeed(myWallet);

    if (seed == null) {
      P.mprint(widget, 'Failed to decrypt private key - ####### ERROR !!');
      _showSnackbar('Failed to decrypt private key ');
      return;
    }
    print('decrypted seed: $seed');
    bool debug = Constants.debug;
    Payment payment = new Payment(
        seed: seed,
        sourceAccount: myWallet.accountID,
        destinationAccount: destWallet.accountID,
        amount: amount,
        memo: 'FlutterWallet',
        toFCMToken: destWallet.fcmToken,
        fromFCMToken: myWallet.fcmToken,
        date: new DateTime.now().millisecondsSinceEpoch,
        stringDate: new DateTime.now().toIso8601String(),
        debug: debug);

    P.mprint(widget, "submitting following payment ..............");
    payment.printDetails();

    reference.push().set(payment.toJson()).then((result) {
      P.mprint(widget, "Firebase done adding payment");
      _showSnackWithAction('Payment has been sent. Wait for confirmation');
    });
  }

  void _showSnackbar(String message) {
    P.mprint(widget, "trying to show snackBar ...");
    if (_scaffoldKey.currentState == null) {
      return;
    }
    _scaffoldKey.currentState.hideCurrentSnackBar();
    snackbar = new SnackBar(
      content: new Text(
        message,
        style: new TextStyle(color: Colors.white),
      ),
      duration: new Duration(minutes: 5),
      backgroundColor: Colors.indigo.shade800,
    );

    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  SnackBar snackbar;

  void _showSnackWithAction(String message) {
    if (_scaffoldKey.currentState == null) {
      return;
    }
    _scaffoldKey.currentState.hideCurrentSnackBar();
    snackbar = new SnackBar(
      content: new Text(
        message,
        style: new TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      action: new SnackBarAction(label: "Done", onPressed: _quitOK),
      duration: new Duration(seconds: 30),
    );

    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void _showError(String message) {
    P.mprint(widget, "trying to show snackBar ...");
    if (_scaffoldKey.currentState == null) {
      return;
    }
    var snackbar = new SnackBar(
      content: new Text(
        message,
        style: new TextStyle(color: Colors.yellow),
      ),
      duration: new Duration(minutes: 2),
      backgroundColor: Colors.red,
    );

    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void _quitOK() {
    assert(ctx != null);

    P.mprint(widget, 'PaymentWidget Navigator.pop(ctx, result)');
    try {
      AccountDetails.of(ctx).refresh();
    } catch (err) {
      print(err);
    }
    Navigator.pop(ctx);
  }

  Future _getDestinationWallet() async {
    if (destName != null) {
      P.mprint(widget, '----------- destName != null. do not go to Firebase');
      return;
    }

    DatabaseReference walletRef =
        FirebaseDatabase.instance.reference().child('wallets').child(walletID);
    P.mprint(widget, 'Getting wallet from Firebase ....');
    await walletRef.once().then((snapshot) {
      Map map = snapshot.value;
      destWallet = new Wallet.fromJson(map);
      P.mprint(
          widget, '############### Destination Wallet ####################');
      P.mprint(widget, destWallet.toJson().toString());
      setState(() {
        payeeUrl = destWallet.url;
        destName = destWallet.name;
      });
    }).catchError(_handleError);
    {
      P.mprint(widget, 'Houston, destination wallet search crashed ');
      //_showSnackbar('Unable to decode QR code');
    }
  }

  static const platform2 = const MethodChannel('com.oneconnect.wallet/debug');

  @override
  Widget build(BuildContext context) {
    ctx = context;
    destWallet = widget.wallet;
    reqAmount = widget.amount;
    if (destWallet.accountID == null) {
      walletID = destWallet.walletID;
      _getDestinationWallet();
    } else {
      destName = destWallet.name;
      payeeUrl = destWallet.url;
    }
    if (reqAmount != null) {
      _controller = new TextEditingController(text: reqAmount.trim());
    }
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(
          "OneConnect Payments",
          style: new TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
        ),
        elevation: 16.0,
        bottom: new PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: new Theme(
            data: Theme.of(context).copyWith(accentColor: Colors.white),
            child: new Padding(
              padding: new EdgeInsets.only(bottom: 10.0),
              child: new Text(
                "Make a Payment",
                style: new TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Raleway',
                    fontSize: 28.0),
              ),
            ),
          ),
        ),
      ),
      body: new ListView(
        children: <Widget>[
          new Padding(
            padding: new EdgeInsets.all(8.0),
            child: new Container(
              child: new SingleChildScrollView(
                child: new Column(
                  children: <Widget>[
                    new Row(
                      children: <Widget>[
                        new Padding(
                          padding: new EdgeInsets.all(4.0),
                          child: new CircleAvatar(
                            backgroundImage: new NetworkImage(
                                payeeUrl == null ? url : payeeUrl),
                            radius: 36.0,
                            backgroundColor: Colors.black,
                          ),
                        ),
                        new Padding(
                          padding: new EdgeInsets.all(8.0),
                          child: new Text(
                            destName == null ? "" : destName,
                            style: new TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Raleway',
                                color: Colors.indigo.shade300),
                          ),
                        ),
                      ],
                    ),
                    new Row(
                      children: <Widget>[
                        new Padding(
                          padding: const EdgeInsets.only(left: 40.0),
                          child: new Text(
                            'Amount Requested:',
                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Text(
                            reqAmount == null ? '' : reqAmount,
                            style: new TextStyle(
                              fontSize: 24.0,
                              color: Colors.teal,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    new Padding(
                      padding: new EdgeInsets.only(
                          top: 30.0, left: 30.0, right: 30.0, bottom: 20.0),
                      child: new TextField(
                        keyboardType: TextInputType.number,
                        maxLength: 28,
                        controller: reqAmount == '0.00' ? null : _controller,
                        decoration: new InputDecoration(
                          labelText: 'Amount to Pay',
                        ),
                        onChanged: _onTextChanged,
                        style: new TextStyle(
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Raleway',
                            fontSize: 36.0,
                            color: Colors.pink),
                      ),
                    ),
                    RaisedButton(
                      onPressed: isSubmitting ? null : _submitPayment,
                      elevation: 12.0,
                      splashColor: Colors.blue,
                      disabledTextColor: Colors.indigo.shade100,
                      child: new Padding(
                        padding: new EdgeInsets.all(10.0),
                        child: new Text(
                          "Send Payment",
                          style: new TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0),
                        ),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(
                        destName == null
                            ? _startFB()
                            : 'Copyright OneConnect 2018',
                        style: new TextStyle(fontSize: 10.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String dummy;

  _handleError() {}

  String _startFB() {
    _getDestinationWallet();
    return "Testing";
  }

  TextEditingController _controller;
}

class PaymentResult {
  bool success;
  String name, accountID, amount;

  PaymentResult({this.success, this.name, this.accountID, this.amount});
}
