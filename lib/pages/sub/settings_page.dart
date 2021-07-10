import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:traveler/audio/audio_controller.dart';
import 'package:traveler/data/func.dart';
import 'package:traveler/data/images.dart';
import 'package:traveler/language/language.dart';
import 'package:traveler/language/language_enum.dart';
import 'package:traveler/pages/main_page.dart';

class SettingsPage extends StatefulWidget {
  final ParentMainPageState mainPage;

  SettingsPage(this.mainPage);

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
    return SafeArea(
      child: getBody(),
    );
  }

  getBody() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Container(
            padding: EdgeInsets.all(
              10,
            ),
            height: height / 1.4,
            width: width / 1.25,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                .75,
              ),
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "Show Correct Answers",
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: FutureBuilder(
                        future: Functions.showCorrectAnswers(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return SpinKitDualRing(
                              color: Color(0xff195FA9),
                              size: 30,
                            );

                          return Checkbox(
                            value: snapshot.data,
                            fillColor: MaterialStateProperty.all(
                              Color(0xff195FA9),
                            ),
                            checkColor: Colors.white,
                            onChanged: (value) async {
                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              setState(() {
                                preferences.setBool(
                                    "ShowCorrectAnswers", value);
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
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
                                Color(0xff041323),
                                Color(0xff164F8B),
                                Color(0xff195FA9),
                                Color(0xff1C88FF),
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
                                Color(0xff041323),
                                Color(0xff164F8B),
                                Color(0xff195FA9),
                                Color(0xff1C88FF),
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
        ),
        Positioned(
          left: 10,
          top: 10,
          child: GestureDetector(
            onTap: () {
              this.widget.mainPage.changeBody(null);
            },
            child: CircleAvatar(
              radius: 22,
              child: Icon(
                MdiIcons.arrowLeftBold,
                color: Color(0xff1C88FF),
                size: 30,
              ),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
