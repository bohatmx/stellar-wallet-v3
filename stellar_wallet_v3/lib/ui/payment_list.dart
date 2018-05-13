import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stellar_wallet_v3/data/Record.dart';
import 'package:stellar_wallet_v3/data/Wallet.dart';
import 'package:stellar_wallet_v3/ui/widgets/RecordWidget.dart';
import 'package:stellar_wallet_v3/ui/widgets/bag.dart';
import 'package:stellar_wallet_v3/util/comms.dart';
import 'package:stellar_wallet_v3/util/file_util.dart';
import 'package:stellar_wallet_v3/util/printer.dart';

class PaymentList extends StatefulWidget {
  final List<Record> records;
  final Wallet wallet;

  PaymentList(this.records, this.wallet);

  @override
  // ignore: strong_mode_invalid_method_override
  _PaymentState createState() => new _PaymentState();

  static _PaymentState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<_PaymentState>());
}

class _PaymentState extends State<PaymentList> {
  List<Record> records;
  Wallet wallet;
  BuildContext ctx;
  String countMade = '0', countReceived = '0';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  initState() {
    super.initState();
  }

  BagWidget bagWidget;
  var listM = new List<Record>();
  var listR = new List<Record>();
  var listAll = new List<Record>();

  void showSheet(Record record) async {
    var wallets = await FileUtil.getWallets();
    Wallet w;
    bool isReceiving = false;
    if (record.to == wallet.accountID) {
      isReceiving = true;
    }
    if (isReceiving) {
      //find from id from wallets
      wallets.forEach((wx) {
        if (record.from == wx.accountID) {
          w = wx;
        }
      });
    } else {
      //find to id from wallets
      wallets.forEach((wx) {
        if (record.to == wx.accountID) {
          w = wx;
        }
      });
    }
    assert(w != null);
    if (isReceiving) {
      _showSnackbar("Payment received from " + w.name, Colors.white,
          Colors.teal.shade700);
    } else {
      _showSnackbar(
          "Payment made to " + w.name, Colors.white, Colors.pink.shade700);
    }
  }

  _getPayments() async {
    _showSnackbar('Load payments from Stellar Payments Network...',
        Colors.white, Colors.black);

    Communications comms = new Communications();
    records = await comms.getPayments(wallet.accountID);

    filter();
    //RecordsBag bag = new RecordsBag(records);
    //FileUtil.savePayments(bag);
    records = listAll;
    var cnt = records.length;
    P.mprint(widget, '====================> found payment records: $cnt');
    _scaffoldKey.currentState.hideCurrentSnackBar();
    try {
      setState(() {
        isFiltered = false;
        countMade = '${listM.length}';
        countReceived = '${listR.length}';
      });
    } catch (err) {
      print('Error setting state )))))))))))))');
    }
  }

  void filter() {
    listAll.clear();
    listR.clear();
    listM.clear();

    records.forEach((rec) {
      //      print(rec.toJson().toString());
      if (rec.type == 'payment') {
        listAll.add(rec);
        if (wallet.accountID == rec.to) {
          listR.add(rec);
        }
        if (wallet.accountID == rec.from) {
          listM.add(rec);
        }
      }
    });
  }

  bool isFiltered = false;
  @override
  Widget build(BuildContext context) {
    ctx = context;
    if (!isFiltered) {
      records = widget.records;
      wallet = widget.wallet;
      var count = '${records.length}';
      P.mprint(widget,
          '############ received $count payment records from somewhere ...');
      filter();
      countMade = '${listM.length}';
      countReceived = '${listR.length}';
    } else {
      isFiltered = false;
    }
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        elevation: 16.0,
        title: new GestureDetector(
            onTap: _displayAll, child: new Text('Payment Records')),
        bottom: new PreferredSize(
          child: new Theme(
            data: Theme.of(context).copyWith(accentColor: Colors.white),
            child: new Column(
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(
                      left: 40.0, bottom: 10.0, right: 30.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new Text(
                        'Payments Made:',
                        style: new TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new GestureDetector(
                          onTap: _displayMade,
                          child: new Text(
                            countMade,
                            style: new TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Raleway',
                              fontSize: 30.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.only(
                      left: 40.0, bottom: 10.0, right: 30.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      new Text(
                        'Payments Received:',
                        style: new TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new GestureDetector(
                          onTap: _displayReceived,
                          child: new Text(
                            countReceived,
                            style: new TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Raleway',
                              fontSize: 30.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          preferredSize: const Size.fromHeight(100.0),
        ),
      ),
      body: new Column(
        children: <Widget>[
          new Flexible(
            child: new ListView.builder(
                itemCount: records == null ? 0 : records.length,
                itemBuilder: (BuildContext context, int index) {
                  return new RecordWidget(
                    wallet.accountID,
                    records.elementAt(index),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        elevation: 24.0,
        onPressed: _getPayments,
        tooltip: 'Increment',
        child: new Icon(FontAwesomeIcons.briefcase),
      ),
    );
  }

  void _showSnackbar(String message, Color textColor, Color backColor) {
    P.mprint(widget, "trying to show snackBar ...");
    if (_scaffoldKey.currentState == null) {
      return;
    }
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        message,
        style: new TextStyle(color: textColor),
      ),
      duration: new Duration(seconds: 30),
      backgroundColor: backColor,
    ));
  }

  void _displayMade() {
    setState(() {
      isFiltered = true;
      records = listM;
    });
  }

  void _displayReceived() {
    setState(() {
      isFiltered = true;
      records = listR;
    });
  }

  void _displayAll() {
    setState(() {
      isFiltered = true;
      records = listAll;
    });
  }
}
