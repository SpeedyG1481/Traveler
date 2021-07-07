import 'package:animated_widgets/animated_widgets.dart';
import 'package:animated_widgets/widgets/translation_animated.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:traveler/audio/audio_controller.dart';
import 'package:traveler/data/audio_files.dart';
import 'package:traveler/data/images.dart';
import 'package:traveler/language/language.dart';
import 'package:traveler/pages/sub/first_main_page.dart';

class ParentMainPage extends StatefulWidget {
  @override
  ParentMainPageState createState() => ParentMainPageState();
}

class ParentMainPageState extends State<ParentMainPage> {
  DateTime currentBackPressTime;

  Widget body;
  double offset = -1000;

  changeBody(Widget body) {
    setState(() {
      this.body = body;
      if (body is ParentMainPageState)
        offset = -1000;
      else
        offset = -offset;
    });
  }

  @override
  void initState() {
    AudioController.playBackgroundMusic(AudioFiles.MenuBackground);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Images.menuBackground,
                fit: BoxFit.cover,
              ),
            ),
            child: getAnimatedWidget(),
          ),
        ),
      ),
    );
  }

  getAnimatedWidget() {
    return TranslationAnimatedWidget.tween(
      enabled: true,
      duration: Duration(milliseconds: 335),
      translationDisabled: Offset(offset, 0),
      translationEnabled: Offset(0, 0),
      child: OpacityAnimatedWidget.tween(
        enabled: true,
        opacityDisabled: 1,
        opacityEnabled: 1,
        child: body != null ? body : FirstMainPage(this),
      ),
    );
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();

    if (this.body != null && !(this.body is FirstMainPage)) {
      changeBody(FirstMainPage(this));
      return Future.value(false);
    }

    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 3)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: Language.exitTwoTap);
      return Future.value(false);
    }
    return Future.value(true);
  }
}
