import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:traveler/data/constants.dart';
import 'package:traveler/data/images.dart';
import 'package:traveler/language/language.dart';
import 'package:traveler/pages/main_page.dart';
import 'package:traveler/pages/sub/mode_selection_page.dart';
import 'package:traveler/pages/sub/settings_page.dart';
import 'package:traveler/pages/sub/upload_page.dart';
import 'package:url_launcher/url_launcher.dart';

class FirstMainPage extends StatefulWidget {
  final ParentMainPageState mainPage;

  const FirstMainPage(this.mainPage);

  @override
  _FirstMainPageState createState() => _FirstMainPageState();
}

class _FirstMainPageState extends State<FirstMainPage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 25,
              ),
              child: Image(
                image: Images.logo,
              ),
            ),
          ),
          Expanded(
            flex: 16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Traveler",
                  style: TextStyle(
                    fontFamily: "GrenzeGotisch",
                    fontWeight: FontWeight.w500,
                    fontSize: 65,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                button(
                  width: width / 1.60,
                  backgroundColor: Color(0xffB83B5E),
                  splashColor: Color(0xffDE4872),
                  textColor: Colors.white,
                  text: Language.playButton,
                  height: 55,
                  radius: 10,
                  small: false,
                  onTap: () {
                    if (Constants.debugMode)
                      Fluttertoast.showToast(msg: Language.debugModeError);
                    else
                      play();
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                button(
                  onTap: () {
                    promoteCity();
                  },
                  height: 50,
                  width: width / 1.9,
                  radius: 10,
                  backgroundColor: Color(0xffC84B31),
                  splashColor: Color(0xffEE593A),
                  text: Language.promoteCity,
                  textColor: Colors.white,
                ),
                SizedBox(
                  height: 15,
                ),
                button(
                  onTap: () {
                    rankings();
                  },
                  height: 50,
                  width: width / 2,
                  radius: 10,
                  backgroundColor: Color(0xffF08A5E),
                  splashColor: Color(0xffFF9C63),
                  text: Language.rankings,
                  textColor: Colors.white,
                ),
                SizedBox(
                  height: 15,
                ),
                button(
                  onTap: () {
                    settings();
                  },
                  height: 50,
                  width: width / 2.10,
                  radius: 10,
                  backgroundColor: Color(0xff0D4371),
                  splashColor: Color(0xff115997),
                  text: Language.settings,
                  textColor: Colors.white,
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  button({
    double width = 50,
    double height = 50,
    double radius = 10,
    String text = "NULL",
    Color textColor,
    Color backgroundColor,
    Color splashColor,
    Function() onTap,
    bool small = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: small ? Images.smallButton : Images.bigButton,
          fit: BoxFit.fill,
        )),
        width: width,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),
      ),
    );
  }

  void play() {
    this.widget.mainPage.changeBody(ModeSelectionPage(this.widget.mainPage));
  }

  void promoteCity() {
    this.widget.mainPage.changeBody(UploadPage(this.widget.mainPage));
  }

  void rankings() async {
    if (await canLaunch(Constants.rankingSiteUrl)) {
      await launch(
        Constants.rankingSiteUrl,
        forceSafariVC: false,
        forceWebView: false,
      );
    }
  }

  void settings() {
    this.widget.mainPage.changeBody(SettingsPage());
  }
}
