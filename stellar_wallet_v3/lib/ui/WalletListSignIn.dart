import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/ui/widgets/WalletWidgetSignIn.dart';
import 'package:stellar_wallet_v3/util/FileUtil.dart';

class WalletListSignIn extends StatefulWidget {
  @override
  _WalletListState createState() => new _WalletListState();
  static _WalletListState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_WalletListState>());
}

class _WalletListState extends State<WalletListSignIn> {
  List<Wallet> wallets;
  Wallet myWallet;
  BuildContext ctx;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final reference = FirebaseDatabase.instance.reference().child('wallets');
  final wRef = FirebaseDatabase.instance.reference().child('wallets');
  @override
  initState() {
    super.initState();
    print("************ initState, getting myWallet and all wallets");

    _getWallets();
  }

  _refreshWallets() async {
    _showSnackbar("Refreshing friends and wallet keys");

    print("############### refreshing  wallets from Firebase I .........");
    wRef.keepSynced(true);

    wRef.once().then((snapshot) {
      Map data = snapshot.value;
//      Wallets ws = new Wallets.fromJson(data);
//      ws.wallets = new List();
//      print(data);
      wallets = new List<Wallet>();
      data.forEach((key, value) {
        Wallet w = new Wallet.fromJSON(value);
        wallets.add(w);
      });

      setState(() {
//        wallets = ws.wallets;
      });
    });
  }

  _getWallets() async {
    _showSnackbar("Loading wallets for sign in");
    var w = await FileUtil.getWallets();
    if (w == null || w.isEmpty) {
      _refreshWallets();
      return;
    }
    w.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      wallets = w;
    });
  }

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
        title: new Text("Friends and Wallets",
            style: new TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic)),
      ),

      body: new Column(
        children: <Widget>[
          new Flexible(
            child: new ListView.builder(
                itemCount: wallets == null ? 0 : wallets.length,
                itemBuilder: (BuildContext context, int index) {
                  return new WalletWidgetSignIn(
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
}
