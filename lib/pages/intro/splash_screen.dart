import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:traveler/data/images.dart';
import 'package:traveler/language/language.dart';
import 'package:traveler/pages/intro/intro_screen.dart';
import 'package:traveler/pages/main_page.dart';

class FirstSplashScreen extends StatefulWidget {
  @override
  FirstSplashScreenState createState() => FirstSplashScreenState();
}

class FirstSplashScreenState extends State<FirstSplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SplashScreen(
        routeName: "/",
        navigateAfterFuture: autoLogin(),
        imageBackground: Images.menuBackground,
        loaderColor: Colors.white,
      ),
    );
  }

  Future<Widget> autoLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool introShowed = prefs.getBool("ShowIntro");
    await Language.loadLocale();
    await Future.delayed(
      Duration(
        seconds: 1,
        milliseconds: 500,
      ),
    );
    Widget returnWidget = ParentMainPage();
    if (introShowed == null || !introShowed) {
      returnWidget = IntroScreen();
    }
    return returnWidget;
  }
}
