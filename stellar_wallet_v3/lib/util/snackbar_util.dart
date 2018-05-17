import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class AppSnackbar {
  static showSnackbar(
      {@required BuildContext context,
      @required GlobalKey<ScaffoldState> scaffoldKey,
      @required String message,
      @required Color textColor,
      @required Color backgroundColor}) {
    if (scaffoldKey.currentState == null || context == null) {
      return;
    }
    scaffoldKey.currentState.hideCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        message,
        style: new TextStyle(color: textColor),
      ),
      duration: new Duration(minutes: 3),
      backgroundColor: backgroundColor,
    ));
  }

  static showSnackbarWithProgressIndicator(
      {@required BuildContext context,
      @required GlobalKey<ScaffoldState> scaffoldKey,
      @required String message,
      @required Color textColor,
      @required Color backgroundColor}) {
    if (scaffoldKey.currentState == null || context == null) {
      return;
    }
    scaffoldKey.currentState.hideCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Row(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Container(
              height: 40.0,
              width: 40.0,
              child: CircularProgressIndicator(
                strokeWidth: 4.0,
              ),
            ),
          ),
          new Text(
            message,
            style: new TextStyle(color: textColor),
          ),
        ],
      ),
      duration: new Duration(minutes: 3),
      backgroundColor: backgroundColor,
    ));
  }

  static showSnackbarWithAction(
      {@required BuildContext context,
      @required GlobalKey<ScaffoldState> scaffoldKey,
      @required String message,
      @required Color textColor,
      @required Color backgroundColor,
      @required String actionLabel}) {
    if (scaffoldKey.currentState == null || context == null) {
      return;
    }
    scaffoldKey.currentState.hideCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Row(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Container(
              height: 40.0,
              width: 40.0,
              child: Icon(Icons.person),
            ),
          ),
          new Text(
            message,
            style: new TextStyle(color: textColor),
          ),
        ],
      ),
      duration: new Duration(minutes: 3),
      backgroundColor: backgroundColor,
      action: SnackBarAction(
        label: actionLabel,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ));
  }

  static showErrorSnackbar(
      {@required BuildContext context,
      @required GlobalKey<ScaffoldState> scaffoldKey,
      @required String message,
      @required String actionLabel}) {
    if (scaffoldKey.currentState == null || context == null) {
      return;
    }
    scaffoldKey.currentState.hideCurrentSnackBar();
    var snackbar = new SnackBar(
      content: new Text(
        message,
        style: new TextStyle(color: Colors.yellow),
      ),
      duration: new Duration(minutes: 3),
      backgroundColor: Colors.red.shade900,
      action: SnackBarAction(
        label: actionLabel,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );

    scaffoldKey.currentState.showSnackBar(snackbar);
  }
}
