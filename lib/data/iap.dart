import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveler/data/health_system.dart';

class IAP {
  static Future<void> buyReloadQuickness() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("RemovedAds", true);
  }

  static Future<void> buyRemoveAds() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("ReloadQuicknesspp", true);
    await HealthSystem.fillHealth();
  }
}
