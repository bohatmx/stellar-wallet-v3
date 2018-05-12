import 'package:flutter/material.dart';

class P {
  static void mprint(Widget widget, String message) {
    var name = widget.toString();
    print('$name ##  $message');
  }
}