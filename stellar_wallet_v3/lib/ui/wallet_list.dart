import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/data/Wallets.dart';
import 'package:stellar_wallet_v3/ui/account_details.dart';
import 'package:stellar_wallet_v3/ui/payment_widget.dart';
import 'package:stellar_wallet_v3/ui/widgets/wallet_widget.dart';
import 'package:stellar_wallet_v3/util/file_util.dart';
import 'package:stellar_wallet_v3/util/printer.dart';
import 'package:stellar_wallet_v3/util/shared_prefs.dart';
import 'package:stellar_wallet_v3/util/snackbar_util.dart';

class WalletList extends StatefulWidget {
  @override
  _WalletListState createState() => new _WalletListState();
  static _WalletListState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_WalletListState>());
}

class _WalletListState extends State<WalletList> with TickerProviderStateMixin {
  List<Wallet> wallets;
  Wallet myWallet;
  BuildContext ctx;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final reference = FirebaseDatabase.instance.reference().child('wallets');
  final wRef = FirebaseDatabase.instance.reference().child('wallets');
  AnimationController controller;
  Animation<double> actionAnimation;
  @override
  initState() {
    super.initState();
    P.mprint(
        widget, "************ initState, getting myWallet and all wallets");

    _getMyWallet();
    _getWallets();
    controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    controller.addStatusListener((listener) {
      if (listener == AnimationStatus.forward) {
        print('_LoginPageState.initState  ######### forward');
      }
      if (listener == AnimationStatus.reverse) {
        print('_LoginPageState.initState  ######### reverse');
      }
      if (listener == AnimationStatus.completed) {
        print('_LoginPageState.initState ######### completed ');
      }
      if (listener == AnimationStatus.dismissed) {
        print('_LoginPageState.initState ######### dismissed');
      }
    });
  }

  _getMyWallet() async {
    myWallet = await SharedPrefs.getWallet();
    P.mprint(widget, "@@@@@@@@@@ my wallet");
    P.mprint(widget, myWallet.toJson().toString());
  }

  _refreshWallets() async {
    AppSnackbar.showSnackbarWithProgressIndicator(
        context: context,
        scaffoldKey: _scaffoldKey,
        message: 'Refreshing friends and wallet keys ...',
        textColor: Colors.yellow,
        backgroundColor: Colors.black);

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
        controller.reset();
        controller.forward();
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
    AppSnackbar.showSnackbarWithProgressIndicator(
        context: context,
        scaffoldKey: _scaffoldKey,
        message: 'Loading saved friends and wallet keys',
        textColor: Colors.white,
        backgroundColor: Colors.grey.shade600);
    var w = await FileUtil.getWallets();
    if (w == null || w.isEmpty) {
      _refreshWallets();
      return;
    }
    w.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      wallets = w;
      count = wallets.length;
      controller.reset();
      controller.forward();
    });
  }

  void receiveResult(PaymentResult result) {
    P.mprint(widget, '@@@@@@@@@@@@@@@@@@@@ receivePaymentResult .....');
    if (AccountDetails.of(ctx) != null) {
      AccountDetails.of(ctx).refresh();
    }
    var x = 'Payment of ${result.amount}  XLM has been made to: ${result.name}';
    AppSnackbar.showSnackbarWithAction(
        context: context,
        scaffoldKey: _scaffoldKey,
        message: x,
        textColor: Colors.white,
        backgroundColor: Colors.black,
        actionLabel: "Done");
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButtonAnimator: new FAB(controller),
    );
  }
}
