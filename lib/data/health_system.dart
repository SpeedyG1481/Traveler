import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveler/data/constants.dart';
import 'package:traveler/data/func.dart';
import 'package:traveler/language/language.dart';

class HealthSystem {
  static const int maxHealth = 5;

  static Future<int> countOfHealth() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int health = preferences.getInt("Health");
    if (health == null) health = 0;
    return health;
  }

  static Future<void> removeHealth() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int health = preferences.getInt("Health");
    if (health == null) return;
    health--;
    await preferences.setInt("Health", health);
  }

  static Future<void> addHealth({int count = 1}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int health = preferences.getInt("Health");
    if (health == null) health = count;
    if (health < 0) health = 0;
    health += count;
    await preferences.setInt("Health", health);
  }

  static Future<void> setTimer() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int currentSavedTime = preferences.getInt("FillTime");
    if (currentSavedTime == null) {
      int time = (await Functions.getGMT()).millisecondsSinceEpoch;
      time += (Constants.HealthPerMinute * 60 * 1000 * maxHealth);
      await preferences.setInt("FillTime", time);
    }
  }

  static Future<bool> canPlay() async {
    return await countOfHealth() > 0;
  }

  static Future<void> play() async {
    await removeHealth();
    await setTimer();
  }

  static Future<void> resetTimer() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("FillTime");
  }

  static Future<void> fillHealth() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt("Health", maxHealth);
  }

  static Future<String> lastTime() async {
    int currentTime = (await Functions.getGMT()).millisecondsSinceEpoch;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int savedTime = preferences.getInt("FillTime");
    if (savedTime == null) {
      if ((await countOfHealth()) != maxHealth) {
        return Constants.fullOverText;
      }
      return Language.full;
    } else {
      int diff = (savedTime - currentTime);

      if (diff > 0) {
        diff ~/= 1000;
        int seconds = diff % 60;
        diff ~/= 60;
        int minutes = diff % 60;
        diff ~/= 60;

        return minutes.toInt().toString() + ":" + seconds.toInt().toString();
      } else {
        await resetTimer();
        return await lastTime();
      }
    }
  }

  static Future<bool> isFull() async {
    return await countOfHealth() == maxHealth;
  }
}
