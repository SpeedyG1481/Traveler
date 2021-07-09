import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveler/data/images.dart';
import 'package:traveler/language/language.dart';
import 'package:traveler/pages/main_page.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    var pageList = [
      PageViewModel(
        decoration: PageDecoration(
          bodyFlex: 1,
          imageFlex: 2,
        ),
        titleWidget: Text(
          Language.introTitle1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bodyWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                Language.introContent1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        image: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: 15.0,
          ),
          child: Image(
            image: Images.intro1,
            fit: BoxFit.cover,
          ),
        ),
      ),
      PageViewModel(
        decoration: PageDecoration(
          bodyFlex: 1,
          imageFlex: 2,
        ),
        titleWidget: Text(
          Language.introTitle2,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bodyWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                Language.introContent2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        image: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: 15.0,
          ),
          child: Image(
            image: Images.intro2,
            fit: BoxFit.cover,
          ),
        ),
      ),
      PageViewModel(
        decoration: PageDecoration(
          bodyFlex: 1,
          imageFlex: 2,
        ),
        titleWidget: Text(
          Language.introTitle3,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bodyWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                Language.introContent3,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        image: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: 15.0,
          ),
          child: Image(
            image: Images.intro3,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ];

    return SafeArea(
      child: IntroductionScreen(
        pages: pageList,
        onDone: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool("ShowIntro", true);
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(
              builder: (context) => ParentMainPage(),
            ),
            (Route<dynamic> route) => false,
          );
        },
        showSkipButton: false,
        globalBackgroundColor: Color(0xffD0F3F7),
        skip: Icon(MdiIcons.arrowRightCircle),
        next: Icon(MdiIcons.arrowRightBold),
        nextFlex: 1,
        dotsFlex: 4,
        done: Text(
          Language.done,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        dotsDecorator: DotsDecorator(
          size: Size.square(12.5),
          activeSize: Size(20.0, 12.5),
          activeColor: Color(0xff1683DB),
          color: Color(0xff1683DB).withOpacity(
            .4,
          ),
          spacing: const EdgeInsets.symmetric(horizontal: 5.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              25.0,
            ),
          ),
        ),
      ),
    );
  }
}
