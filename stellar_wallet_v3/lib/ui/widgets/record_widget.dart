import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:stellar_wallet_v3/data/Record.dart';
import 'package:stellar_wallet_v3/ui/payment_list.dart';

class RecordWidget extends StatelessWidget {
  final Record record;
  final String accountID;
  String date, time, amount;
  BuildContext ctx;

  RecordWidget(this.accountID, this.record);

  @override
  Widget build(BuildContext context) {
    ctx = context;
    var format = new DateFormat.MMMEd();
    date = format.format(record.created_at);

    var formatTime = new DateFormat.Hms();
    time = formatTime.format(record.created_at);

    var formatNum = new NumberFormat('###,##0.00');
    if (record.amount != null) {
      amount = formatNum.format(double.parse(record.amount));
    }
    var pink = Colors.pink.shade200;
    var teal = Colors.teal;
    bool isReceived = false;
    if (accountID == record.to) {
      isReceived = true;
    }
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Card(
        elevation: 4.0,
        child: new Column(
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: new Icon(FontAwesomeIcons.briefcase),
                ),
                new GestureDetector(
                  onTap: _showRealName,
                  child: new Text(
                    date,
                    style: new TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Text(
                    time,
                    style: new TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
            new Column(
              children: <Widget>[
                new Column(
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: new Text(
                        'From Account',
                        style: new TextStyle(
                            color: Colors.grey,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(
                          right: 48.0, left: 48.0, top: 10.0),
                      child: new Text(
                        record.from == null ? '' : record.from,
                        style:
                            new TextStyle(color: Colors.black, fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
                new Column(
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: new Text(
                        'To Account',
                        style: new TextStyle(
                            color: Colors.indigo.shade100,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(
                          left: 48.0, right: 48.0, top: 10.0),
                      child: new Text(
                        record.to == null ? '' : record.to,
                        style:
                            new TextStyle(color: Colors.black, fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
                new Padding(
                  padding: const EdgeInsets.only(
                      left: 48.0, right: 48.0, top: 10.0, bottom: 10.0),
                  child: new Row(
                    children: <Widget>[
                      new GestureDetector(
                        onTap: _showRealName,
                        child: new Text(
                          amount == null ? '0.00' : amount,
                          style: new TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 24.0,
                              color: isReceived ? teal : pink),
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Text(
                          'XLM',
                          style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.purple),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                new Padding(
                  padding: new EdgeInsets.only(left: 20.0, bottom: 20.0),
                  child: new PaymentInOut(accountID, record),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRealName() {
    PaymentList.of(ctx).showSheet(record);
  }
}

class PaymentInOut extends StatelessWidget {
  final String mAccountID;
  final Record record;
  bool isReceived = false;

  PaymentInOut(this.mAccountID, this.record);

  var paid = new Text(
    '****** Payment Made ******',
    style: new TextStyle(
        color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16.0),
  );
  var received = new Text(
    '****** Payment Received ******',
    style: new TextStyle(
        color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16.0),
  );

  @override
  Widget build(BuildContext context) {
    if (mAccountID == record.to) {
      isReceived = true;
    }
    return new Container(
      child: new Padding(
        padding: new EdgeInsets.only(
            left: 16.0, right: 16.0, top: 8.0, bottom: 10.0),
        child: isReceived == true ? received : paid,
      ),
    );
  }
}
