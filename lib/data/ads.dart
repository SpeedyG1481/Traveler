import 'dart:io';

import 'package:traveler/data/constants.dart';

class Ads {
  static String testInterstitialId = "ca-app-pub-3940256099942544/1033173712";
  static String testRewardedId = "ca-app-pub-3940256099942544/5224354917";
  static String testBannerdId = "ca-app-pub-3940256099942544/6300978111";

  static String getPlayGameInterstitialId() {
    if (Constants.debugMode) {
      return testInterstitialId;
    }
    if (Platform.isIOS) {
      return "ca-app-pub-8847668020520840/7778528189";
    } else {
      return "ca-app-pub-8847668020520840/6672495925";
    }
  }

  static String getProfileInterstitialId() {
    if (Constants.debugMode) {
      return testInterstitialId;
    }

    if (Platform.isIOS) {
      return "ca-app-pub-8847668020520840/9369336673";
    } else {
      return "ca-app-pub-8847668020520840/4702499207";
    }
  }

  static String getPromoteCityInterstitialId() {
    if (Constants.debugMode) {
      return testInterstitialId;
    }

    if (Platform.isIOS) {
      return "ca-app-pub-8847668020520840/5329540383";
    } else {
      return "ca-app-pub-8847668020520840/1198723688";
    }
  }

  static String getFastLoadHealthRewardedId() {
    if (Constants.debugMode) {
      return testRewardedId;
    }
    if (Platform.isIOS) {
      return "ca-app-pub-8847668020520840/1490846654";
    } else {
      return "ca-app-pub-8847668020520840/9107087570";
    }
  }

  static String getInGameBannerId() {
    if (Constants.debugMode) {
      return testBannerdId;
    }
    if (Platform.isIOS) {
      return "ca-app-pub-8847668020520840/7289968245";
    } else {
      return "ca-app-pub-8847668020520840/6168458269";
    }
  }
}
