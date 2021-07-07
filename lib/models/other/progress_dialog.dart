import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProggressDialog {
  final BuildContext mainContext;
  BuildContext dismissContext;
  bool isOpen = false;

  ProggressDialog({this.mainContext});

  void show({Color color = Colors.white}) {
    if (!isOpen) {
      showDialog<void>(
        context: this.mainContext,
        barrierColor: Colors.black.withOpacity(.27),
        barrierDismissible: false,
        useRootNavigator: false,
        useSafeArea: false,
        builder: (BuildContext context) {
          this.dismissContext = context;
          return SpinKitRotatingCircle(
            size: 65,
            color: color,
          );
        },
      );
      this.isOpen = true;
    }
  }

  bool hide() {
    if (!isOpen) return false;
    try {
      Navigator.of(dismissContext).pop();
      this.isOpen = false;
      return true;
    } catch (e) {
      return false;
    }
  }
}
