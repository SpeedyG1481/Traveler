import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:traveler/audio/audio_controller.dart';
import 'package:traveler/data/images.dart';
import 'package:traveler/language/language.dart';
import 'package:traveler/language/language_enum.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _valueSound = 0;
  double _valueMusic = 0;

  @override
  void initState() {
    super.initState();
    AudioController.getMusicVolume().then((value) {
      setState(() {
        _valueMusic = value * 100;
      });
    });
    AudioController.getSoundVolume().then((value) {
      setState(() {
        _valueSound = value * 100;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: getBody(),
    );
  }

  getBody() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        padding: EdgeInsets.all(
          10,
        ),
        height: height / 1.5,
        width: width / 1.25,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(
            .85,
          ),
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    Language.musicSound,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                  SizedBox(
                    height: 7.5,
                  ),
                  Expanded(
                    child: SleekCircularSlider(
                      initialValue: _valueMusic,
                      appearance: CircularSliderAppearance(
                        customColors: CustomSliderColors(
                          shadowColor: Colors.blue,
                          progressBarColors: [
                            Colors.red,
                            Colors.orange,
                            Colors.green,
                            Colors.green
                          ],
                          dotColor: Colors.white,
                          trackColor: Colors.grey,
                        ),
                      ),
                      max: 100,
                      onChangeEnd: (double value) {
                        AudioController.setMusicVolume(value / 100);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    Language.sfxSound,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                  SizedBox(
                    height: 7.5,
                  ),
                  Expanded(
                    child: SleekCircularSlider(
                      initialValue: _valueSound,
                      appearance: CircularSliderAppearance(
                        customColors: CustomSliderColors(
                          shadowColor: Colors.blue,
                          progressBarColors: [
                            Colors.red,
                            Colors.orange,
                            Colors.green,
                            Colors.green
                          ],
                          dotColor: Colors.white,
                          trackColor: Colors.grey,
                        ),
                      ),
                      max: 100,
                      onChangeEnd: (double value) {
                        AudioController.setSoundVolume(value / 100);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            Language.changeLanguage(LanguageEnum.tr_TR);
                          });
                        },
                        child: Image(
                          image: Images.trTR,
                          height: 100,
                        ),
                      ),
                      if (LanguageEnum.tr_TR == Language.languageEnum)
                        Icon(
                          MdiIcons.checkBold,
                          size: 30,
                          color: Colors.green,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            Language.changeLanguage(LanguageEnum.en_US);
                          });
                        },
                        child: Image(
                          image: Images.enUS,
                          height: 100,
                        ),
                      ),
                      if (LanguageEnum.en_US == Language.languageEnum)
                        Icon(
                          MdiIcons.checkBold,
                          size: 30,
                          color: Colors.green,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
