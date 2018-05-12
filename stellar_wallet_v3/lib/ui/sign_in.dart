import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stellar_wallet_v3/data/Account.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/ui/WalletListSignIn.dart';
import 'package:stellar_wallet_v3/util/Auth.dart';
import 'package:stellar_wallet_v3/util/Comms.dart';
import 'package:stellar_wallet_v3/util/Printer.dart';
import 'package:stellar_wallet_v3/util/SharedPrefs.dart';
import 'package:stellar_wallet_v3/util/constants.dart';
import 'package:stellar_wallet_v3/util/encrypt_encrypt.dart';

//TODO - remove hard coded source account - put it into RemoteConfig
const ACCOUNT_ID = "GDDW5XOQCSRBCHLD4DPZB52F67TWJWTNEQJD4REW27ZFCDFVV7TMWIQM",
    SECRET = "SBJGQ5FYIBJPCIM7FK5E4MIYSLRUOQ3QIU3DTQFE7EATJVQP6MLXXY47";

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseDatabase fb = FirebaseDatabase.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var block1 =
      'Thank you for downloading our wallet app. This app will allow you to send and receive payments ';
  var block2 =
      'Please tap the round button to start creating your account on the Stellar blockchain';
  Wallet mWallet;
  String fcmToken;
  BuildContext ctx;
  Communications comms = new Communications();
  var title;
  var instruction = "Press the button to start";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final bool debug = Constants.debug;

  Future _prepareWallet(String cachedToken) async {
    mWallet.fcmToken = cachedToken;
    Communications comms = Communications();
    Account acct = await comms.getAccount(ACCOUNT_ID);
    assert(acct != null);

    mWallet.sourceSeed = SECRET;
    mWallet.sequenceNumber = acct.sequence;
    mWallet.debug = debug;

    mWallet.stringDate = new DateTime.now().toIso8601String();
    mWallet.date = new DateTime.now().millisecondsSinceEpoch;
    await _addWallet();
  }

  // ignore: missing_return
  Future<Wallet> _findExistingWallet(FirebaseUser user) async {
    final qReference =
        fb.reference().child("wallets").orderByChild('uid').equalTo(user.uid);
    var snapshot = await qReference.once();
    if (snapshot != null) {
      Map maps = snapshot.value;
      if (maps == null) {
        mWallet = null;
        return null;
      }
      maps.forEach((key, value) {
        var walletID = value['walletID'];
        print('########################## walletID = $walletID');
        print('_LoginPageState._findExistingWallet key $key value  $value');
        // Map<dynamic, dynamic> map = value;
        var id = value['walletIF'];
        print("walletID: $id");
        try {
          mWallet = new Wallet.fromJson(value);
          assert(mWallet != null);
          mWallet.walletID = key;
          print('++++++++++ existing wallet found: ${mWallet.walletID}');
          print(mWallet.toJson());
        } catch (e) {
          print(e);
          return null;
        }

        return mWallet;
      });
    } else {
      print('&&&&&&&&&&&&&&&&&&&&&&&& wallet not found, returning null');
      return null;
    }
  }

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
      duration: new Duration(minutes: 3),
    ));
  }

  Future<Wallet> _addWallet() async {
    P.mprint(widget, '_addWallet .......................');
    P.mprint(widget, mWallet.toJson().toString());
    P.mprint(widget,
        "adding wallet to Firebase to kick off serverless function that creates a Stellar account");
    final mainReference = fb.reference().child("wallets");
    await mainReference.push().set(mWallet.toJson()).catchError((error) {
      print(error);
      _showSnak('Failed to add wallet to Firebase');
    });
    print('_LoginPageState._addWallet -  wallet added to firebase');
    var user = await _auth.currentUser();
    DataSnapshot shot =
        await mainReference.orderByChild('uid').equalTo(user.uid).once();
    print('_LoginPageState._addWallet ############# we have a wallet!! : ${shot
        .value}');
    Map map = shot.value;
    print('_LoginPageState._addWallet  map has ${map.length}');
    bool isNavigated = false;
    map.forEach((key, value) {
      mWallet = new Wallet.fromJSON(value);
      mWallet.walletID = key;

      print('_LoginPageState._addWallet - wallet created from json ....${key}');
      var ref = mainReference.child(key);
      ref.onChildChanged.listen((event) async {
        print(
            '_LoginPageState._addWallet - onChildChanged .....${event.snapshot.key}  ${event.snapshot.value}');
        if (!isNavigated) {
          var snapshot = await ref.once();
          mWallet = new Wallet.fromJSON(snapshot.value);
          if (mWallet.success) {
            mWallet.walletID = snapshot.key;
            await SharedPrefs.saveWallet(mWallet);
            isNavigated = true;
            Navigator.popAndPushNamed(context, '/account');
          } else {
            _showSnak("Wallet  creation failed. Please try again");
          }
        }
      });
    });

    return mWallet;
  }

  _encrypt() async {
    mWallet = await EncryptionUtil.encryptSeed(mWallet);
    print('_LoginPageState._encrypt wallet  encrypted :: ${mWallet.toJson()}');
  }

  @override
  initState() {
    super.initState();
    _checkIfDebugVersion();
  }

  static const platform1 = const MethodChannel('com.oneconnect.wallet/auth');
  static const platform2 = const MethodChannel('com.oneconnect.wallet/debug');

  Future<FirebaseUser> _getAuth() async {
    print('_LoginPageState._getAuth ... getting auth');
    var authUtil = new MyAuth();
    FirebaseUser user = await authUtil.signInWithGoogle();
    var cachedToken = await SharedPrefs.getFCMToken();
    if (user != null) {
      print(
          '_LoginPageState._getAuth - signInWithGoogle complete. authed: ${user
              .displayName}');
      // check if wallet exists
      await _findExistingWallet(user);
      if (mWallet != null) {
        mWallet.fcmToken = cachedToken;

        if (mWallet.isEncrypted == null || !mWallet.isEncrypted) {
          await _encrypt();
          await SharedPrefs.saveWallet(mWallet);
        } else {
          await SharedPrefs.saveWallet(mWallet);
          assert(mWallet.walletID != null);
          final mainReference =
              fb.reference().child("wallets").child(mWallet.walletID);
          mainReference.set(mWallet.toJson()).then((result) {
            print(
                '------_LoginPageState._getAuth--------------> updated fcmToken on existing wallet in firebase');
          });
        }
        Navigator.popAndPushNamed(context, '/account');
      } else {
        mWallet = new Wallet.create();
        mWallet.email = user.email;
        mWallet.name = user.displayName;
        mWallet.url = user.photoUrl;
        mWallet.uid = user.uid;
        _prepareWallet(cachedToken);
      }
    }
    return null;
  }

  void listenToWallet() {}

//  Future _getAuth() async {
//    print('_LoginPageState._getAuth ###################################');
//    String msg;
//    try {
//      var result = await platform1.invokeMethod('auth');
//      var cachedToken = await SharedPrefs.getFCMToken();
//      print('_LoginPageState._getAuth result came back... yay!');
//      print('_LoginPageState._getAuth $result');
//      var user = await _auth.currentUser();
//      if (user != null) {
//        print(
//            '_LoginPageState._getAuth ###### YEAHHH!!! authentication worked');
//        print('_LoginPageState._getAuth ${user.toString()}');
//        //check if wallet exists
//        await _findExistingWallet(user);
//        if (mWallet != null) {
//          mWallet.fcmToken = cachedToken;
//          if (mWallet.isEncrypted == null || !mWallet.isEncrypted) {
//            await _encrypt();
//            Navigator.popAndPushNamed(context, '/account');
//          } else {
//            await SharedPrefs.saveWallet(mWallet);
//            assert(mWallet.walletID != null);
//            final mainReference =
//                fb.reference().child("wallets").child(mWallet.walletID);
//            mainReference.set(mWallet.toJson()).then((result) {
//              print(
//                  '------_LoginPageState._getAuth--------------> updated fcmToken on existing wallet in firebase');
//            });
//          }
//          Navigator.popAndPushNamed(context, '/account');
//        } else {
//          mWallet = new Wallet.create();
//          mWallet.email = user.email;
//          mWallet.name = user.displayName;
//          mWallet.url = user.photoUrl;
//          mWallet.uid = user.uid;
//          _prepareWallet(cachedToken);
//        }
//      }
//    } on PlatformException catch (e) {
//      msg = "Failed to get auth: '${e.message}'.";
//      print(msg);
//    }
//    return true;
//  }

  Future<bool> _checkIfDebugVersion() async {
    if (debug) {
      print('=========== isDebug: $debug = This is a DEBUG version');
      return true;
    } else {
      print('=========== isDebug: $debug = This is a RELEASE version');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    var bottom = PreferredSize(
      preferredSize: Size.fromHeight(90.0),
      child: Theme(
        data: Theme.of(context).copyWith(accentColor: Colors.white),
        child: Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Wallet Creation",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36.0),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "Welcome Aboard the Good Ship",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 14.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("OneConnect Payments",
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal)),
        bottom: bottom,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Card(
              elevation: 8.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Welcome to OneConnect Payment Services',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 24.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        block1,
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 18.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        block2,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20.0,
                            color: Colors.teal),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Opacity(
                opacity: debug != null ? 1.0 : 0.0,
                child: RaisedButton(
                  elevation: 8.0,
                  onPressed: _listWallets,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Select User From List',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Raleway'),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getAuth,
        tooltip: 'Authenticate',
        child: Icon(Icons.lock),
      ),
    );
  }

  void _listWallets() async {
    final FirebaseUser user = await _auth.signInAnonymously();
    print('user signed in: ${user.email}');
    Navigator.push(
      ctx,
      new MaterialPageRoute(builder: (context) => new WalletListSignIn()),
    );
  }
}
