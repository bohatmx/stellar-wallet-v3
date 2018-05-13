import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayer/audioplayer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stellar_wallet_v3/contracts/contracts.dart';
import 'package:stellar_wallet_v3/data/Account.dart';
import 'package:stellar_wallet_v3/data/Payment.dart';
import 'package:stellar_wallet_v3/data/PaymentFailed.dart';
import 'package:stellar_wallet_v3/data/Record.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/ui/payment_list.dart';
import 'package:stellar_wallet_v3/ui/present_qrcode.dart';
import 'package:stellar_wallet_v3/ui/sign_in.dart';
import 'package:stellar_wallet_v3/ui/widgets/title_component.dart';
import 'package:stellar_wallet_v3/util/comms.dart';
import 'package:stellar_wallet_v3/util/encrypt_encrypt.dart';
import 'package:stellar_wallet_v3/util/printer.dart';
import 'package:stellar_wallet_v3/util/shared_prefs.dart';

class AccountDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _AccountDetailsState();
  }

  static _AccountDetailsState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_AccountDetailsState>());
}

FirebaseDatabase fb = FirebaseDatabase.instance;
final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

class _AccountDetailsState extends State<AccountDetails>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  Account account;
  Wallet wallet;
  AccountPresenter presenter;
  Communications comms = new Communications();
  BuildContext ctx;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String name;
  Image image;
  String balance;
  String paymentMessage;
  NetworkImage _profileImage = new NetworkImage(
      "https://firebasestorage.googleapis.com/v0/b/blockchaindev-e50c8.appspot.com/o/profilePictures%2Fblack_woman.jpg?alt=media&token=2858261a-db84-40af-a5a0-fd311d5723b5");
  double btnOpacity;

  AnimationController controller;
  Animation<double> actionAnimation;

  @override
  initState() {
    P.mprint(widget,
        "######################## ......... initState .... configure Cloud Messaging and get fresh Account");
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    controller.addStatusListener((listener) {
      if (listener == AnimationStatus.forward) {
        print('_AccountDetailsState.initState  ######### forward');
      }
      if (listener == AnimationStatus.reverse) {
        print('_AccountDetailsState.initState  ######### reverse');
      }
      if (listener == AnimationStatus.completed) {
        print('_AccountDetailsState.initState ######### completed ');
      }
      if (listener == AnimationStatus.dismissed) {
        print('_AccountDetailsState.initState ######### dismissed');
      }
    });

    _configMessaging();
    initAudioPlayer();
    _profileImage.resolve(new ImageConfiguration()).addListener((_, __) {
      if (mounted) {
        setState(() {});
      }
    });

    _checkSignedIn();
    refresh();
  }

  //AppLifecycleState _notification;
  List<Record> records;
  int paymentType = 1;
  Record lastPayment;
  bool isReceived = false;

  void _getPayments() async {
    print('_AccountDetailsState._getPayments ..................... #########');
    records = await comms.getPayments(wallet.accountID);
    if (records != null && records.isNotEmpty) {
      var list = new List<Record>();
      records.forEach((rec) {
        if (rec.type == 'payment') {
          list.add(rec);
        }
      });

      records = list;
      var cnt = records.length;
      P.mprint(widget, '====================> found payment records: $cnt');
      if (records.isNotEmpty) {
        lastPayment = records.elementAt(0);
        P.mprint(
            widget,
            'lastPayment ${lastPayment.amount} to ${lastPayment
                .to} from ${lastPayment.from}');

        setState(() {
          count = '${records.length}';
          titleWidget = new TitleComponent(_scaffoldKey, records);
          if (wallet.accountID == lastPayment.to) {
            isReceived = true;
            P.mprint(
                widget, '############# RECEIVED PAYMENT flag: $isReceived');
            paymentType = 2;
          } else {
            P.mprint(widget, '############# MADE PAYMENT flag: $isReceived');
            isReceived = false;
            paymentType = 1;
          }
        });
        controller.forward();
        if (controller.isCompleted) {
          print(
              '_AccountDetailsState.build I forward - controller.isCompleted #################');
          controller.reverse();
          if (controller.isCompleted) {
            print(
                '_AccountDetailsState.build II reverse - controller.isCompleted #################');
          }
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('didChangeAppLifecycleState: $state');
    var x = state.toString();
    print('state: $x');
  }

  void _checkSignedIn() async {
    print('_AccountDetailsState._checkSignedIn **********************');
    wallet = await SharedPrefs.getWallet();
    if (wallet == null || wallet.accountID == null) {
      setState(() {
        btnOpacity = 1.0;
      });
    } else {
      setState(() {
        btnOpacity = null;
      });
      if (wallet.password == null) {
        _encrypt(wallet);
      }
      //_getCachedAccount();
    }
  }

  /// user is not authenticated yet, starting auth process
  Future _startLogin() async {
    var result = await Navigator.push(
      ctx,
      new MaterialPageRoute(builder: (context) => new LoginPage()),
    );
    P.mprint(widget, '@@@@@@@@@@@@@@@@ back from login, result: $result');
    setState(() {
      btnOpacity = null;
    });
    _showSnackbar('Waiting for Stellar Payments Network ....');
  }

  _encrypt(Wallet w) async {
    await EncryptionUtil.encryptSeed(w);
    refresh();
  }

  DatabaseReference payRef, recRef;

  void _configMessaging() async {
    P.mprint(widget,
        "========================== configMessaging ========== starting _firebaseMessaging config shit");
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        P.mprint(widget,
            "onMessage, AccountDetails: expecting wallet, payment or error mesage via FCM:\n: $message");
        var messageType = message["messageType"];
        if (messageType == "PAYMENT") {
          P.mprint(widget,
              "AccountDetails Receiving PAYMENT message )))))))))))))))))))))))))))))))))");
          Map map = json.decode(message["json"]);
          var payment = new Payment.fromJson(map);
          assert(payment != null);
          P.mprint(widget, "received payment, details below");
          payment.printDetails();
          receivedPayment(payment);
        }

        if (messageType == "PAYMENT_ERROR") {
          P.mprint(widget,
              "AccountDetails Receiving PAYMENT_ERROR message ################");
          Map map = json.decode(message["json"]);
          PaymentFailed paymentFailed = new PaymentFailed.fromJson(map);
          assert(paymentFailed != null);
          P.mprint(widget, paymentFailed.toJson().toString());
          P.mprint(widget,
              "What do we do now, Boss? payment error, Chief ....maybe show a snackbar?");

          _showSnackbar("Payment failed, try again later. Sorry!");
        }
      },
      onLaunch: (Map<String, dynamic> message) {
        P.mprint(widget, "onLaunch...............wtf?: $message");
      },
      onResume: (Map<String, dynamic> message) {
        P.mprint(widget, "onResume................wtf?: $message");
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));

    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    _firebaseMessaging.getToken().then((String token) async {
      assert(token != null);
      var oldToken = await SharedPrefs.getFCMToken();
      if (token != oldToken) {
        SharedPrefs.saveFCMToken(token);
        if (wallet != null && wallet.walletID != null) {
          wallet.fcmToken = token;
          await SharedPrefs.saveWallet(wallet);
          final mainReference = fb.reference().child("wallets");
          var ref = mainReference.child(wallet.walletID).child('fcmToken');
          await ref.set(token);
          print(
              '_AccountDetailsState._configMessaging ########  wallet fcmToken updated !!');
        }
      }
    }).catchError((e) {
      print('_AccountDetailsState._configMessaging ERROR fcmToken update');
    });
  }

  void receivedPayment(Payment p) {
    P.mprint(
        widget,
        '===============> receivedPayment === ${p.amount} destination: ${p
            .destinationAccount}');
    refresh();
    _playSound();
    _showSnackbar("Payment message received");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    audioPlayer.stop();
    super.dispose();
  }

  AudioPlayer audioPlayer;
  String localFilePath;
  PlayerState playerState = PlayerState.stopped;
  bool isMuted;
  Duration duration;
  Duration position;

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();

    audioPlayer.setDurationHandler((d) => setState(() {
          duration = d;
        }));

    audioPlayer.setPositionHandler((p) => setState(() {
          position = p;
        }));

    audioPlayer.setCompletionHandler(() {
      onComplete();
      setState(() {
        position = duration;
      });
    });

    audioPlayer.setErrorHandler((msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future _playSound() async {
    final file = new File('${(await getTemporaryDirectory()).path}/drama.mp3');
    await file.writeAsBytes((await _loadAsset()).buffer.asUint8List());
    final result = await audioPlayer.play(file.path, isLocal: true);
    if (result == 1) setState(() => playerState = PlayerState.playing);
  }

  Future<ByteData> _loadAsset() async {
    var path;
    var index = rand.nextInt(5);
    switch (index) {
      case 0:
        path = 'assets/pin.mp3';
        break;
      case 1:
        path = 'assets/glass.mp3';
        break;
      case 20:
        path = 'assets/ting.mp3';
        break;
      case 3:
        path = 'assets/coins.mp3';
        break;
      case 4:
        path = 'assets/flyby.mp3';
        break;
      case 5:
        path = 'assets/drama.mp3';
        break;
      default:
        path = 'assets/coins.mp3';
        break;
    }
    print('loading asset $path ----------------');
    return await rootBundle.load(path);
  }

  Future pause() async {
    final result = await audioPlayer.pause();
    if (result == 1) setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    final result = await audioPlayer.stop();
    if (result == 1)
      setState(() {
        playerState = PlayerState.stopped;
        position = new Duration();
      });
  }

  Future mute(bool muted) async {
    final result = await audioPlayer.mute(muted);
    if (result == 1)
      setState(() {
        isMuted = muted;
      });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  bool refreshNeeded = false;

  void startWalletList() {
    Navigator.pushNamed(ctx, "/wallets");
  }

  String _getCurrency() {
    if (account == null) return "";
    if (account.balances.elementAt(0).asset_type == "native") {
      return "XLM";
    } else {
      return account.balances.elementAt(0).asset_type;
    }
  }

  String _getBalance() {
    if (account == null) return "0.00";

    final d = double.parse(account.balances.elementAt(0).balance);
    var fmt = new NumberFormat("###,##0.00");
    var bal =
        fmt.format(d); //fmt.format(account.balances.elementAt(0).balance);
    P.mprint(widget, 'Current XLM balance: $d shortened to: $bal');
    return bal;
  }

  void refresh() async {
    P.mprint(widget,
        '----------- refreshing account -------------------------------------');
    _showSnackbarWithBusy("Loading account detail");
    try {
      wallet = await SharedPrefs.getWallet();
      if (wallet != null) {
        if (wallet.accountID != null) {
          account = await comms.getAccount(wallet.accountID);
          print(account.toJson().toString());
          SharedPrefs.saveAccount(account);
          _scaffoldKey.currentState.hideCurrentSnackBar();
        }
        setState(() {
          name = wallet.name;
          btnOpacity = null;
          P.mprint(widget, "name: $name has been set in setState()");
        });
        _getPayments();
      }
    } catch (e) {
      P.mprint(widget, "Houston, we have a problem $e");
      _showSnackbar('Unexpected error, may be network related');
    }
  }

  SnackBar snackBar;
  Random rand = new Random(new DateTime.now().millisecondsSinceEpoch);

  void _showSnackbar(String message) {
    print('_AccountDetailsState._showSnackbar - trying to show snackBar ..."');
    if (_scaffoldKey.currentState == null) {
      print(
          '_AccountDetailsState._showSnackbar _scaffoldKey.currentState == null - no snackbar possible');
      return;
    }
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        message,
        style: new TextStyle(color: Colors.white),
      ),
      duration: new Duration(seconds: 30),
    ));
  }

  void _showSnackbarWithBusy(String message) {
    print('_AccountDetailsState._showSnackbar - trying to show snackBar ..."');
    if (_scaffoldKey.currentState == null) {
      print(
          '_AccountDetailsState._showSnackbar _scaffoldKey.currentState == null - no snackbar possible');
      return;
    }
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Row(
        children: <Widget>[
          new CircularProgressIndicator(
            strokeWidth: 3.0,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          Text(
            message,
            style: new TextStyle(color: Colors.white),
          ),
        ],
      ),
      duration: new Duration(seconds: 30),
    ));
  }

  Future _finish(int index) async {
    await SharedPrefs.saveThemeIndex(index);
    Navigator.pop(context);
    _showSnackbar('Please close the app and restart to see new theme');
  }

  Future<Null> _showThemeDialog() async {
    switch (await showDialog<Null>(
      context: context,
      child: new SimpleDialog(
        title: const Text(
          'Select Theme, Close and Restart',
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        children: <Widget>[
          new SimpleDialogOption(
            onPressed: () {
              _finish(0);
            },
            child: const Text(
              'Indigo',
              style: const TextStyle(
                  color: Colors.indigo,
                  fontSize: 20.0,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w900),
            ),
          ),
          new SimpleDialogOption(
            onPressed: () {
              _finish(12);
            },
            child: const Text(
              'Pink',
              style: const TextStyle(
                  color: Colors.pink,
                  fontSize: 20.0,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w900),
            ),
          ),
          new SimpleDialogOption(
            onPressed: () {
              _finish(1);
            },
            child: const Text(
              'Teal',
              style: const TextStyle(
                  color: Colors.teal,
                  fontSize: 20.0,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w900),
            ),
          ),
          new SimpleDialogOption(
            onPressed: () {
              _finish(2);
            },
            child: const Text(
              'Deep Orange',
              style: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 20.0,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w900),
            ),
          ),
          new SimpleDialogOption(
            onPressed: () {
              _finish(3);
            },
            child: const Text(
              'Deep Purple',
              style: const TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 20.0,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w900),
            ),
          ),
          new SimpleDialogOption(
            onPressed: () {
              _finish(4);
            },
            child: const Text(
              'Blue Grey',
              style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 20.0,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w900),
            ),
          ),
          new SimpleDialogOption(
            onPressed: () {
              _finish(5);
            },
            child: const Text(
              'Blue',
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 20.0,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w900),
            ),
          ),
          new SimpleDialogOption(
            onPressed: () {
              _finish(6);
            },
            child: const Text(
              'Brown',
              style: const TextStyle(
                  color: Colors.brown,
                  fontSize: 20.0,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w900),
            ),
          ),
          new SimpleDialogOption(
            onPressed: () {
              _finish(7);
            },
            child: const Text(
              'Amber',
              style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 20.0,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w900),
            ),
          ),
          new SimpleDialogOption(
            onPressed: () {
              _finish(8);
            },
            child: const Text(
              'Cyan',
              style: const TextStyle(
                  color: Colors.cyan,
                  fontSize: 20.0,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w900),
            ),
          ),
          new SimpleDialogOption(
            onPressed: () {
              _finish(14);
            },
            child: const Text(
              'Lime',
              style: const TextStyle(
                  color: Colors.lime,
                  fontSize: 20.0,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    )) {
    }
  }

  var count;
  TitleComponent titleWidget;

  @override
  Widget build(BuildContext context) {
    ctx = context;
    titleWidget = new TitleComponent(_scaffoldKey, records);

    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 8.0,
          leading: Container(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120.0),
            child: Theme(
              data: Theme.of(context).copyWith(accentColor: Colors.white),
              child: titleWidget,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.brush),
              onPressed: _showThemeDialog,
            ),
          ],
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                child: Text(
                  "Stellar Payments Network",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Raleway',
                      color: Colors.grey.shade300),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 60.0, right: 60.0, top: 10.0),
                child: Opacity(
                  opacity: 1.0,
                  child: Text(
                    account == null
                        ? "Loading Details ..."
                        : account.account_id,
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Opacity(
                  opacity: btnOpacity == null ? 1.0 : 0.3,
                  child: Card(
                    elevation: 6.0,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              left: 0.0, top: 5.0, right: 0.0, bottom: 0.0),
                          child: Text(
                            "Current Balance",
                            style: TextStyle(
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, bottom: 20.0, top: 10.0),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 12.0, right: 2.0, bottom: 12.0),
                                child: Opacity(
                                  opacity: 1.0,
                                  child: GestureDetector(
                                    onTap: _startPaymentsList,
                                    child: Text(
                                      account == null
                                          ? "Balance"
                                          : _getBalance(),
                                      style: TextStyle(
                                        fontSize: 30.0,
                                        fontFamily: 'Raleway',
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 20.0, top: 10.0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    account == null
                                        ? "Currency"
                                        : _getCurrency(),
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Last Transaction',
                          style: TextStyle(
                              color: Colors.indigo.shade200,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                          child: GestureDetector(
                            onTap: _startPaymentsList,
                            child: Row(
                              children: <Widget>[
                                Text(
                                  paymentType == 1
                                      ? 'Payment Made:'
                                      : 'Payment Received',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.normal),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: _startPaymentsList,
                                    child: Text(
                                      lastPayment == null
                                          ? 'No previous payment:'
                                          : _formatAmount(),
                                      style: _getStyle(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, bottom: 20.0, top: 10.0),
                          child: GestureDetector(
                            onTap: _startPaymentsList,
                            child: Text(
                              lastPayment == null ? '' : _formatDate(),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            child: new Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: new GestureDetector(
                                onTap: _startPaymentsList,
                                child: Chip(
                                  label: Text(
                                    'Payments',
                                    style: TextStyle(fontSize: 10.0),
                                  ),
                                  avatar: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).accentColor,
                                    child: Text(
                                      count == null ? '0' : count,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: btnOpacity == null ? 0.0 : btnOpacity,
                child: RaisedButton(
                  onPressed: _startLogin,
                  elevation: 16.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Raleway'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).primaryColor,
          elevation: 16.0,
          child: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
//              IconButton(
//                icon: Icon(FontAwesomeIcons.briefcase),
//                onPressed: () {
//                  _startPaymentsList();
//                },
//              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.qrcode),
                onPressed: () {
                  _startScan();
                },
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  refresh();
                },
              ),
            ],
          ),
        ),
        floatingActionButton: Opacity(
          opacity: btnOpacity == null ? 1.0 : 0.0,
          child: FloatingActionButton(
            elevation: 32.0,
            onPressed: () {
              startWalletList();
            },
            tooltip: 'Increment',
            child: Icon(FontAwesomeIcons.users),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButtonAnimator: FAB(controller),
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }

  String _formatAmount() {
    if (lastPayment.amount == null) {
      return '0.00';
    }
    var fmt = new NumberFormat('###,##0.00');
    var amt = double.parse(lastPayment.amount);
    return fmt.format(amt);
  }

  String _formatDate() {
    var format = new DateFormat.yMMMMEEEEd();
    var date = format.format(lastPayment.created_at);

    var formatTime = new DateFormat.Hms();
    var time = formatTime.format(lastPayment.created_at);

    return date + ' ' + time;
  }

  TextStyle _getStyle() {
    if (paymentType == 2) {
      //payment received
      return TextStyle(
        color: Colors.teal,
        fontFamily: 'Raleway',
        fontWeight: FontWeight.w900,
        fontSize: 24.0,
      );
    } else {
      if (lastPayment == null) {
        return TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.normal,
          fontSize: 14.0,
        );
      }
      //payment made
      return TextStyle(
        color: Colors.pink,
        fontFamily: 'Raleway',
        fontWeight: FontWeight.w900,
        fontSize: 24.0,
      );
    }
  }

  void _startPaymentsList() {
    P.mprint(widget, 'starting payments .....................');
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (context) => PaymentList(records, wallet)),
    );
  }

  void _startScan() {
    P.mprint(widget, 'starting to present qr code .....................');
    _getPayments();
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (context) => PresentQRCode()),
    );
  }
}

class FAB extends FloatingActionButtonAnimator {
  final AnimationController controller;

  FAB(this.controller);

  @override
  Offset getOffset({Offset begin, Offset end, double progress}) {
    if (progress == 0.0) {
      return begin;
    } else {
      return end;
    }
  }

  @override
  Animation<double> getRotationAnimation({Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: -1.0).animate(controller);
  }

  @override
  Animation<double> getScaleAnimation({Animation<double> parent}) {
    return TrainHoppingAnimation(
      Tween<double>(begin: 1.0, end: -1.0).animate(controller),
      Tween<double>(begin: -1.0, end: 1.0).animate(controller),
    );
  }
}
