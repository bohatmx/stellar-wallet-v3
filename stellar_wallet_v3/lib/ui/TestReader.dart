import 'dart:async';
import 'package:flutter/material.dart';

class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => new _ScannerState();
}

class _ScannerState extends State<Scanner> {
  Future<String> _barcodeString;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('QRCode Reader Example'),
      ),
      body: new Center(
          child: new FutureBuilder<String>(
              future: _barcodeString,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return new Text(snapshot.data != null ? snapshot.data : '');
              })),
      floatingActionButton: new FloatingActionButton(
        onPressed: _scan,
        tooltip: 'Reader the QRCode',
        child: new Icon(Icons.add_a_photo),
      ),
    );
  }

  void _scan() {
    setState(() {
//      _barcodeString = new QRCodeReader()
//          .setAutoFocusIntervalInMs(200)
//          .setForceAutoFocus(true)
//          .setTorchEnabled(true)
//          .setHandlePermissions(true)
//          .setExecuteAfterPermissionGranted(true)
//          .scan();
    });
  }
}
