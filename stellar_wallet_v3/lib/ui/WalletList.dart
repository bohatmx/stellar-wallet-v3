import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/data/Wallets.dart';
import 'package:stellar_wallet_v3/ui/PaymentWidget.dart';
import 'package:stellar_wallet_v3/ui/cccount_details.dart';
import 'package:stellar_wallet_v3/ui/widgets/WalletWidget.dart';
import 'package:stellar_wallet_v3/util/FileUtil.dart';
import 'package:stellar_wallet_v3/util/Printer.dart';
import 'package:stellar_wallet_v3/util/SharedPrefs.dart';

class WalletList extends StatefulWidget {
  @override
  _WalletListState createState() => new _WalletListState();
  static _WalletListState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_WalletListState>());
}

class _WalletListState extends State<WalletList> {
  List<Wallet> wallets;
  Wallet myWallet;
  BuildContext ctx;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final reference = FirebaseDatabase.instance.reference().child('wallets');
  final wRef = FirebaseDatabase.instance.reference().child('wallets');
  @override
  initState() {
    super.initState();
    P.mprint(
        widget, "************ initState, getting myWallet and all wallets");

    _getMyWallet();
    _getWallets();
  }

  _getMyWallet() async {
    myWallet = await SharedPrefs.getWallet();
    P.mprint(widget, "@@@@@@@@@@ my wallet");
    P.mprint(widget, myWallet.toJson().toString());
  }

  _refreshWallets() async {
    _showSnackbar("Refreshing friends and wallet keys");

    P.mprint(widget,
        "############### refreshing  wallets from Firebase I .........");
    //TODO filter list - now reads in ALL wallets from Firebase
    wRef.keepSynced(true);

    wRef.once().then((snapshot) {
      Map data = snapshot.value;
      print(data);

      print(data);
      wallets = new List<Wallet>();
      data.forEach((key, value) {
        Wallet w = new Wallet.fromJSON(value);

        if (w.walletID == myWallet.walletID) {
          print('-------- ignore ' + w.walletID);
        } else {
          wallets.add(w);
        }
      });

      var ws = new Wallets.create();
      ws.wallets = wallets;

      FileUtil.saveWallets(ws);
      wallets.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        count = wallets.length;
      });
    });
  }

  _fix(Wallet w) async {
    w.isEncrypted = true;
    var ref = FirebaseDatabase.instance
        .reference()
        .child('wallets')
        .child(w.walletID);
    ref.set(w.toJson());
    print(
        '_WalletListState._refreshWallets - wallet isEncrypted set to true for:  ${w.walletID}');
  }

  _getWallets() async {
    _showSnackbar("Loading friends and wallet keys");
    var w = await FileUtil.getWallets();
    if (w == null || w.isEmpty) {
      _refreshWallets();
      return;
    }
    w.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      wallets = w;
      count = wallets.length;
    });
  }

  void receiveResult(PaymentResult result) {
    P.mprint(widget, '@@@@@@@@@@@@@@@@@@@@ receivePaymentResult .....');
    if (AccountDetails.of(ctx) != null) {
      AccountDetails.of(ctx).refresh();
    }
    var x =
        'Payment of ' + result.amount + ' XLM has been made to: ' + result.name;
    _showSnackbar(x);
  }

  int count;
  @override
  Widget build(BuildContext context) {
    ctx = context;
    var bot = new PreferredSize(
      child: new Theme(
        data: Theme.of(context).copyWith(accentColor: Colors.white),
        child: new Row(
          children: <Widget>[],
        ),
      ),
      preferredSize: const Size.fromHeight(20.0),
    );
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        bottom: bot,
        title: new Row(
          children: <Widget>[
            new Text(
              "Friends and Wallets",
              style: new TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
            new Padding(
              padding: new EdgeInsets.only(left: 30.0),
              child: new Text(
                count == null ? '0' : '$count',
                style: new TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Raleway',
                ),
              ),
            ),
          ],
        ),
      ),

      body: new Column(
        children: <Widget>[
          new Flexible(
            child: new ListView.builder(
                itemCount: wallets == null ? 0 : wallets.length,
                itemBuilder: (BuildContext context, int index) {
                  return new WalletWidget(
                      wallets.elementAt(index), _scaffoldKey);
                }),
          ),
        ],
      ),

      floatingActionButton: new FloatingActionButton(
        onPressed: _refreshWallets,
        tooltip: 'Refresh',
        child: new Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _showSnackbar(String message) {
    P.mprint(widget, "trying to show snackBar ...");
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
}
