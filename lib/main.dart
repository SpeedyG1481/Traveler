import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:traveler/data/constants.dart';
import 'package:traveler/data/iap.dart';
import 'package:traveler/pages/intro/splash_screen.dart';

FirebaseAnalytics analytics;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SystemChrome.setEnabledSystemUIOverlays([]);
  await MobileAds.instance.initialize();

  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }

  analytics = FirebaseAnalytics();
  await Firebase.initializeApp();
  IAP.canRemoveAds().then((value) {
    if (value != null) {
      Constants.canRemoveAds = value;
    }
  });

  runApp(
    MaterialApp(
      title: 'Traveler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "CrimsonPro",
        accentColor: Color(0xff1483DB),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      home: FirstSplashScreen(),
    ),
  );

}
