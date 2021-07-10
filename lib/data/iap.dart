import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveler/data/constants.dart';
import 'package:traveler/data/health_system.dart';
import 'package:traveler/pages/sub/market_page.dart';

class IAP {
  static Future<void> buyRemoveAds() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("RemoveAds", true);
    Constants.canRemoveAds = true;
  }

  static Future<void> buyReloadQuickness() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("ReloadQuickness", true);
    await HealthSystem.fillHealth();
  }

  static Future<bool> canReloadQuickness() async {
    if (Constants.debugMode) return true;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.containsKey("ReloadQuickness") &&
        preferences.getBool("ReloadQuickness");
  }

  static Future<bool> canRemoveAds() async {
    if (Constants.debugMode) return true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.containsKey("RemoveAds") &&
        preferences.getBool("RemoveAds");
  }

  static Future<bool> hasPurchased(String id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (id == removeAdsId) {
      return preferences.containsKey("RemoveAds") &&
          preferences.getBool("RemoveAds");
    } else if (id == reloadQuicknessId) {
      return preferences.containsKey("ReloadQuickness") &&
          preferences.getBool("ReloadQuickness");
    }

    return true;
  }
}
