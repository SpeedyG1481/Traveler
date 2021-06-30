import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioController {
  static AudioPlayer musicAudioPlayer = AudioPlayer(
    playerId: "megalow_game_studio_traveler_music_audio_player",
  );
  static AudioCache musicAudioCache = AudioCache(
    fixedPlayer: musicAudioPlayer,
  );

  static AudioPlayer soundAudioPlayer = AudioPlayer(
    playerId: "megalow_game_studio_traveler_sound_audio_player",
  );
  static AudioCache soundAudioCache = AudioCache(
    fixedPlayer: soundAudioPlayer,
  );

  static void playSoundEffect(String source) async {
    if (soundAudioCache.fixedPlayer.state == PlayerState.PLAYING) {
      await soundAudioCache.fixedPlayer.stop();
    }
    soundAudioPlayer.setVolume(await getSoundVolume());
    soundAudioCache.play(source, volume: await getSoundVolume());
  }

  static void stopBackgroundMusic() async {
    if (musicAudioCache.fixedPlayer.state == PlayerState.PLAYING) {
      await musicAudioCache.fixedPlayer.stop();
    }
  }

  static void playBackgroundMusic(String source) async {
    if (musicAudioCache.fixedPlayer.state == PlayerState.PLAYING) {
      await musicAudioCache.fixedPlayer.stop();
    }

    musicAudioPlayer.setVolume(await getMusicVolume());
    await musicAudioCache.loop(source);
  }

  static Future<double> getSoundVolume() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getDouble("SoundVolume") != null
        ? preferences.getDouble("SoundVolume")
        : 1.0;
  }

  static Future<double> getMusicVolume() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getDouble("MusicVolume") != null
        ? preferences.getDouble("MusicVolume")
        : 1.0;
  }

  static void setSoundVolume(double value) async {
    await soundAudioPlayer.setVolume(value);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setDouble("SoundVolume", value);
  }

  static void setMusicVolume(double value) async {
    await musicAudioPlayer.setVolume(value);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setDouble("MusicVolume", value);
  }
}
