import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/util/constants.dart';
import 'package:stellar_wallet_v3/util/shared_prefs.dart';

class MyAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase fb = FirebaseDatabase.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  List<String> firstNames, lastNames;
  Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);

  Future<Wallet> signInAnonymously() async {
    print('=============== signInAnonymously ===============');
    final FirebaseUser user = await _auth.signInAnonymously();
    assert(user != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return _getRandomWallet(user);
  }

  Future<FirebaseUser> signInWithGoogle() async {
    print(
        'MyAuth.signInWithGoogle: ==================== starting sign in .... ===');
    FirebaseUser user;
    try {
      _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
        print('MyAuth.signInWithGoogle: onCurrentUserChanged ' + account.email);
      });
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      print('googleyUser from popup: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('googleAuth done ...... now authenticate with Firebase');

      user = await _auth.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    } catch (e) {
      print('&&&&&&&& Google Sign in FUCKED ^%%5#&%');
      print(e);
    }
    if (user == null) {
      print('%%%%%% ERROR - user null from Google sign in');
      return null;
    }
    print(
        "This user signed in via Google #############################: $user");
    return user;
  }

  Future processWallet(Wallet mWallet) async {
    _addWallet(mWallet);
  }

  Future<Wallet> _addWallet(Wallet mWallet) async {
    print(mWallet.toJson().toString());
    if (mWallet.seed == null) {
      print(
          "adding wallet to Firebase to kick off serverless function that creates a Stellar account");
      final mainReference = fb.reference().child("wallets");
      mainReference.push().set(mWallet.toJson()).whenComplete(() {
        print("wallet added to Firebase - waiting for FCM wallet message ....");
        mWallet.printDetails();
        SharedPrefs.saveWallet(mWallet);
        print(mWallet.toJson());
      }).catchError((error) {
        print(error);
      });
    }

    return mWallet;
  }

  Future<Wallet> _getRandomWallet(FirebaseUser user) async {
    var fullname = _getRandomName();
    var email = fullname.replaceAll(' ', '').toLowerCase() + "@email.com";

    var debug = Constants.debug;
    ;
    var wallet = new Wallet(
        uid: user.uid,
        name: fullname,
        email: email,
        debug: debug,
        date: new DateTime.now().millisecondsSinceEpoch,
        stringDate: new DateTime.now().toIso8601String());
    SharedPrefs.saveWallet(wallet);
    return wallet;
  }

  String _getRandomName() {
    load();
    rand = new Random(new DateTime.now().millisecondsSinceEpoch + 45365);
    var index1 = rand.nextInt(firstNames.length - 1);
    var fName = firstNames.elementAt(index1);

    rand = new Random(new DateTime.now().millisecondsSinceEpoch + 18988789);
    var index2 = rand.nextInt(lastNames.length - 1);
    var lName = lastNames.elementAt(index2);
    var fullname = fName + ' ' + lName;
    return fullname;
  }

  static const platform2 = const MethodChannel('com.oneconnect.wallet/debug');

  void load() {
    firstNames = new List();
    firstNames.add("Siphokazi");
    firstNames.add("Raymond");
    firstNames.add("Catherine");
    firstNames.add("Bobby");
    firstNames.add("Mmaphefo");
    firstNames.add("Portia");
    firstNames.add("Maria");
    firstNames.add("Phillippa");
    firstNames.add("Ntombi");
    firstNames.add("Fezekile");
    firstNames.add("Helen");
    firstNames.add("Mpho");
    firstNames.add("Thandeka");
    firstNames.add("Sophia");
    firstNames.add("Mmatshepo");
    firstNames.add("Nokwanda");
    firstNames.add("Nomonde");
    firstNames.add("Fiona");
    firstNames.add("Xolile");
    firstNames.add("James");
    firstNames.add("Thomas");
    firstNames.add("Lesego");
    firstNames.add("Rogers");
    firstNames.add("Motseki");
    firstNames.add("Mmathebe");
    firstNames.add("Samuel");
    firstNames.add("Rhulani");
    firstNames.add("Nothando");
    firstNames.add("Cherie");
    firstNames.add("Nana");
    firstNames.add("Zoey");
    firstNames.add("Yvonne");
    firstNames.add("Dlamani");
    firstNames.add("Pauline");
    firstNames.add("Anne");
    firstNames.add("Hlubi");
    firstNames.add("Katrina");
    firstNames.add("Ntsako");

    lastNames = new List();
    lastNames.add("Maluleke");
    lastNames.add("Nkosi");
    lastNames.add("Mhinga");
    lastNames.add("Blackwood");
    lastNames.add("Thobejane");
    lastNames.add("Smith");
    lastNames.add('Solomons');
    lastNames.add("Bergh");
    lastNames.add("Franklin");
    lastNames.add("Mathebula");
    lastNames.add("Gerryson");
    lastNames.add("Bodibe");
    lastNames.add("Maswanganyi");
    lastNames.add("Makhubela");
    lastNames.add("Baloyi");
    lastNames.add("Nkuna");
    lastNames.add("Botha");
    lastNames.add("Smith");
    lastNames.add("Gault");
    lastNames.add("Freeman");
    lastNames.add("Chauke");
    lastNames.add("Vermeulen");
    lastNames.add("Ntini");
    lastNames.add("Mngomezulu");
    lastNames.add("Renken");
    lastNames.add("Fibonacci");
  }
}
