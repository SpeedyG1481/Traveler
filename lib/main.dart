import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traveler/pages/intro/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MaterialApp(
      title: 'Traveler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "CrimsonPro",
        accentColor: Color(0xff1483DB),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FirstSplashScreen(),
    ),
  );
}
