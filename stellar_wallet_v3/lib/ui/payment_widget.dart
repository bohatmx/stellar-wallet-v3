import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stellar_wallet_v3/data/Account.dart';
import 'package:stellar_wallet_v3/data/Payment.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/ui/account_details.dart';
import 'package:stellar_wallet_v3/util/comms.dart';
import 'package:stellar_wallet_v3/util/constants.dart';
import 'package:stellar_wallet_v3/util/encrypt_encrypt.dart';
import 'package:stellar_wallet_v3/util/printer.dart';
import 'package:stellar_wallet_v3/util/shared_prefs.dart';

class MakePayment extends StatefulWidget {
  final Wallet wallet;
  final String amount;
  MakePayment(this.wallet, this.amount);

  @override
  _PaymentWidgetState createState() => new _PaymentWidgetState();
}

const bool DEBUGGING = true;
BuildContext ctx;

class _PaymentWidgetState extends State<MakePayment>
    with TickerProviderStateMixin {
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
  AnimationController controller;
  Animation<double> animation;

  @override
  initState() {
    super.initState();
    P.mprint(widget,
        '******************************** initState *********************');
    controller = new AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = new Tween(begin: 0.0, end: 72.0).animate(controller);
    controller.forward();
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
    FocusScope.of(context).requestFocus(new FocusNode());
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
    _showSnackWithBusy("Submitting payment. Please wait");

    if (myWallet.fcmToken == null) {
      var _firebaseMessaging = new FirebaseMessaging();
      myWallet.fcmToken = await _firebaseMessaging.getToken();
      if (myWallet.fcmToken == null) {
        print('_PaymentWidgetState._submitPayment FCM token missing');
      }
      SharedPrefs.saveWallet(myWallet);
    }
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
        success: false,
        date: new DateTime.now().millisecondsSinceEpoch,
        stringDate: new DateTime.now().toIso8601String(),
        debug: debug);

    P.mprint(widget, "submitting following payment ..............");
    payment.printDetails();

    //check if accountID node exists, write one if not
    //push payment to accountID node
    DatabaseReference acctRef =
        fb.reference().child('payments').child(myWallet.accountID);
    print(
        '_PaymentWidgetState._submitPayment #############  acctRef: ${acctRef.reference().path}');
    Query query = await acctRef.limitToLast(2);
    var snap1 = await query.once();
    if (snap1 != null && snap1.value != null) {
      Map map = snap1.value;
      print(
          '_PaymentWidgetState._submitPayment after limit, list: ${map.length}');
      print(
          '_PaymentWidgetState._submitPayment account key: ${snap1.key} value ${snap1.value}');
    } else {
      print(
          '_PaymentWidgetState._submitPayment account node: NOT FOUND - will add one');
      await acctRef.set(myWallet.accountID);
    }

    print(
        '_PaymentWidgetState._submitPayment - pushing payment to account node');
    await acctRef.push().set(payment.toJson()).catchError((e) {
      print(
          '_PaymentWidgetState._submitPayment ERROR pushing payment  to account node');
      _showSnackbar('Payment failed. Please try again later');
    });
    Query query2 = await acctRef.limitToLast(1);
    var s = await query2.once();
    Map m = s.value;
    m.forEach((key, value) {
      print('_PaymentWidgetState._submitPayment should be most recent: $value');
      _listenForPayments(key);
    });
  }

  DatabaseReference payRef, recRef;

  _listenForPayments(String key) async {
    if (myWallet == null || myWallet.accountID == null) {
      print(
          '_PaymentWidgetState._listenForReceipts - wallet or accountID is null');
      return null;
    }
    print('_PaymentWidgetState._listenForPayments - listen for payments ....');
    payRef =
        fb.reference().child('payments').child(myWallet.accountID).child(key);
    print(
        '_PaymentWidgetState._listenForPayments payRef: ${payRef.reference().path}');
    bool haveDataAlready = false;
    payRef.onChildChanged.listen((event) async {
      print('_PaymentWidgetState._listenForPayments payRef.onChildChanged - '
          'a payment has been MADE, maybe, should check success flag, '
          'refresh account and payments');
      print(
          '_PaymentWidgetState._listenForPayments - map: ${event.snapshot.value}');
      if (!haveDataAlready) {
        haveDataAlready = true;
        var snap = await payRef.once();
        print('_PaymentWidgetState._listenForPayments - latest version: ${snap
                .value}');
        Map mm = snap.value;
        var payment = new Payment.fromJSON(mm);
        assert(payment != null);
        bool success = payment.success;
        if (success) {
          _showSnackbarOK('${payment.amount} XLM has been paid OK');
        } else {
          _showSnackbar('Payment has failed');
        }
      }
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

  void _showSnackbarOK(String message) {
    if (_scaffoldKey.currentState == null) {
      return;
    }
    _scaffoldKey.currentState.hideCurrentSnackBar();
    snackbar = new SnackBar(
      content: new Row(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Icon(Icons.done),
          ),
          new Text(
            message,
            style: new TextStyle(color: Colors.white),
          ),
        ],
      ),
      duration: new Duration(minutes: 5),
      backgroundColor: Colors.teal.shade700,
      action: SnackBarAction(
        label: 'Done',
        onPressed: () {
          Navigator.pop(context);
        },
      ),
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

  void _showSnackWithBusy(String message) {
    print("trying to show snackBar ...");
    if (_scaffoldKey.currentState == null) {
      return;
    }
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Row(
        children: <Widget>[
          new CircularProgressIndicator(
            strokeWidth: 2.0,
            backgroundColor: Theme.of(context).accentColor,
          ),
          Text(
            message,
            style: new TextStyle(color: Colors.yellow),
          ),
        ],
      ),
      duration: new Duration(minutes: 5),
    ));
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
                    fontSize: 24.0),
              ),
            ),
          ),
        ),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Card(
          elevation: 4.0,
          child: new ListView(
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
                              child: new AnimatedAvatar(
                                payeeUrl: payeeUrl,
                                animation: animation,
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
                              top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
                          child: new TextField(
                            keyboardType: TextInputType.number,
                            maxLength: 24,
                            controller:
                                reqAmount == '0.00' ? null : _controller,
                            decoration: new InputDecoration(
                              labelText: 'Amount to Pay',
                            ),
                            onChanged: _onTextChanged,
                            style: new TextStyle(
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Raleway',
                                fontSize: 24.0,
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
        ),
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

class AnimatedAvatar extends AnimatedWidget {
  final String payeeUrl;
  final String url =
      "https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/profilePictures%2Fblack_woman.jpg?alt=media&token=2858261a-db84-40af-a5a0-fd311d5723b5";

  AnimatedAvatar({Key key, this.payeeUrl, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return new Center(
      child: new Container(
        margin: new EdgeInsets.symmetric(vertical: 10.0),
        height: animation.value,
        width: animation.value,
        child: new CircleAvatar(
          backgroundImage: new NetworkImage(payeeUrl == null ? url : payeeUrl),
          radius: 36.0,
          backgroundColor: Colors.black,
        ),
      ),
    );
  }
}
