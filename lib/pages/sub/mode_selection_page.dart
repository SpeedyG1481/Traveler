import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:traveler/data/constants.dart';
import 'package:traveler/data/health_system.dart';
import 'package:traveler/data/images.dart';
import 'package:traveler/language/language.dart';
import 'package:traveler/pages/main_page.dart';
import 'package:traveler/pages/sub/market_page.dart';
import 'package:traveler/play_modes/single_player_build_prediction.dart';

class ModeSelectionPage extends StatefulWidget {
  final ParentMainPageState mainPage;

  const ModeSelectionPage(this.mainPage);

  @override
  _ModeSelectionPageState createState() {
    return _ModeSelectionPageState();
  }
}

class _ModeSelectionPageState extends State<ModeSelectionPage> {
  Timer timer;

  @override
  void dispose() {
    if (timer != null) timer.cancel();
    timer = null;
    super.dispose();
  }

  @override
  void initState() {
    loadTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  void loadTimer() {
    if (timer == null)
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {});
      });
  }

  getBody() {
    double width = MediaQuery.of(context).size.width;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            height: 55,
            width: width,
            decoration: BoxDecoration(
              color: Color(0xffD0F3F7),
            ),
            child: Row(
              children: [
                Image(
                  image: Images.hearth,
                ),
                SizedBox(
                  width: 7.5,
                ),
                Expanded(
                  flex: 4,
                  child: FutureBuilder(
                    future: HealthSystem.countOfHealth(),
                    builder: (BuildContext context, AsyncSnapshot<int> data) {
                      if (!data.hasData) {
                        return SpinKitFadingFour(
                          color: Color(0xff1683DB),
                        );
                      }

                      return LiquidLinearProgressIndicator(
                        value: data.data / HealthSystem.maxHealth,
                        valueColor: AlwaysStoppedAnimation(
                          Color(
                            0xff1683DB,
                          ),
                        ),
                        backgroundColor: Colors.transparent,
                        borderColor: Color(0xff1683DB),
                        borderWidth: 3.5,
                        direction: Axis.horizontal,
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 25,
                ),
                FutureBuilder(
                  future: HealthSystem.lastTime(),
                  builder: (BuildContext context, AsyncSnapshot<String> data) {
                    if (!data.hasData) {
                      return SpinKitFadingFour(
                        color: Color(0xff1683DB),
                      );
                    }
                    String strData = data.data;
                    if (strData == Constants.fullOverText) {
                      return IconButton(
                        onPressed: () {
                          HealthSystem.fillHealth();
                        },
                        icon: Icon(
                          MdiIcons.refreshCircle,
                          color: Color(0xff1683DB),
                          size: 33,
                        ),
                      );
                    }

                    return Text(
                      data.data,
                      style: TextStyle(
                        color: Color(
                          0xff1683DB,
                        ),
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                      ),
                    );
                  },
                ),
                SizedBox(
                  width: 25,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      market();
                    },
                    child: Image(
                      image: Images.market,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (await HealthSystem.canPlay()) {
                        HealthSystem.play();
                        Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => SinglePlayerBuildPrediction(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      } else {
                        Fluttertoast.showToast(msg: Language.noHealthForGame);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 35,
                      ),
                      height: 50,
                      width: width / 1.5,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: Images.bigButton, fit: BoxFit.fill),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              Language.singlePlayer,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.5,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image(
                              image: Images.singleUser,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      Fluttertoast.showToast(
                        msg: Language.warningMultiplayerComingSoon,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 35,
                      ),
                      height: 50,
                      width: width / 1.5,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: Images.bigButton, fit: BoxFit.fill),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              Language.multiPlayer,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.5,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image(
                              image: Images.multiUser,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void market() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => MarketPage(),
      ),
    );
  }
}
